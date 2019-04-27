//===-- MMIXAsmBackend.cpp - MMIX Assembler Backend ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MMIXFixupKinds.h"
#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/ADT/APInt.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class MMIXAsmBackend : public MCAsmBackend {
  const MCSubtargetInfo &STI;
  uint8_t OSABI;

public:
  MMIXAsmBackend(const MCSubtargetInfo &STI, uint8_t OSABI)
      : MCAsmBackend(support::big), STI(STI), OSABI(OSABI)  {}
  ~MMIXAsmBackend() override {}

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    return false;
  }

  unsigned getNumFixupKinds() const override {
    return MMIX::NumTargetFixupKinds;
  }

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override {
    const static MCFixupKindInfo Infos[MMIX::NumTargetFixupKinds] = {
      // This table *must* be in the order that the fixup_* kinds are defined in
      // MMIXFixupKinds.h.
      //
      // name                    offset bits  flags
      { "fixup_mmix_rel_16",      0,     32,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_mmix_rel_24",      0,     32,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_mmix_h",           0,     16,  0 },
      { "fixup_mmix_mh",          0,     16,  0 },
      { "fixup_mmix_ml",          0,     16,  0 },
      { "fixup_mmix_l",           0,     16,  0 }
    };

    if (Kind < FirstTargetFixupKind)
      return MCAsmBackend::getFixupKindInfo(Kind);

    assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
           "Invalid kind!");
    return Infos[Kind - FirstTargetFixupKind];
  }

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override {
    return false;
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {

    report_fatal_error("MMIXAsmBackend::relaxInstruction() unimplemented");
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

bool MMIXAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  if ((Count % 4) != 0)
    return false;

  // The canonical nop on MMIX is `SWYM` (Sympathize With Your Machine)
  for (uint64_t i = 0; i < Count; i += 4)
    OS.write("\xfd\0\0\0", 4);

  return true;
}

static uint64_t adjustFixupValue(const MCFixup &Fixup, uint64_t Value,
                                 MCContext &Ctx) {
  unsigned Kind = Fixup.getKind();
  switch (Kind) {
  default:
    llvm_unreachable("Unknown fixup kind!");
  case FK_Data_1:
  case FK_Data_2:
  case FK_Data_4:
  case FK_Data_8:
    return Value;
  case MMIX::fixup_mmix_rel_16: {
    int64_t SVal = (int64_t) Value;
    if (SVal < -262144 || SVal > 262140)
      Ctx.reportError(Fixup.getLoc(), "branch fixup value out of range");
    if (Value & 0x3)
      Ctx.reportError(Fixup.getLoc(), "branch fixup value must be 4-byte aligned");

    if (SVal < 0) {
      Value = (uint64_t)(SVal + 262144) >> 2;
      Value |= 1 << 24; // Change opcode to branch backwards
    } else {
      Value = Value >> 2;
    }
    return Value;
  }
  case MMIX::fixup_mmix_rel_24: {
    int64_t SVal = (int64_t) Value;
    if (SVal < -67108864 || SVal > 67108860)
      Ctx.reportError(Fixup.getLoc(), "jump fixup value out of range");
    if (Value & 0x3)
      Ctx.reportError(Fixup.getLoc(), "jump fixup value must be 4-byte aligned");

    if (SVal < 0) {
      Value = (uint64_t)(SVal + 67108864) >> 2;
      Value |= 1 << 24; // Change opcode to branch backwards
    } else {
      Value = Value >> 2;
    }
    return Value;
  }

  case MMIX::fixup_mmix_h:
    return Value >> 48;
  case MMIX::fixup_mmix_mh:
    return (Value >> 32) & 0xffff;
  case MMIX::fixup_mmix_ml:
    return (Value >> 16) & 0xffff;
  case MMIX::fixup_mmix_l:
    return Value & 0xffff;
  }
}

void MMIXAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                const MCValue &Target,
                                MutableArrayRef<char> Data, uint64_t Value,
                                bool IsResolved,
                                const MCSubtargetInfo *STI) const {
  MCContext &Ctx = Asm.getContext();
  MCFixupKind Kind = Fixup.getKind();
  MCFixupKindInfo Info = getFixupKindInfo(Kind);
  unsigned Offset = Fixup.getOffset();

  // For branch instructions, the branch value informs if we're dealing with a
  // forward or backwards branch. When the low bit of the instruction type
  // byte is 0, it's a forward branch, otherwise it's a backward branch.
  // Value returned from adjustFixupValue sets this bit to one in case of
  // a backwards branch. As we don't want to care here if we've been
  // passed a forward or backward branch instruction, we zero out the low bit.
  // If Value is 0, that also means this is not a backward branch, and we
  // can safely return early.
  if (Kind == static_cast<MCFixupKind>(MMIX::fixup_mmix_rel_16) ||
      Kind == static_cast<MCFixupKind>(MMIX::fixup_mmix_rel_24))
    Data[Offset] &= 0xfe;

  // Apply any target-specific value adjustments.
  Value = adjustFixupValue(Fixup, Value, Ctx);

  if (!Value)
    return; // Doesn't change encoding.

  // Shift the value into position.
  Value <<= Info.TargetOffset;

#ifndef NDEBUG
  unsigned NumBytes = (Info.TargetSize + 7) / 8;
  assert(Offset + NumBytes <= Data.size() && "Invalid fixup offset!");
#endif

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value.
  for (unsigned i = 0; i != 4; ++i) {
    unsigned Idx =  3 - i;
    Data[Offset + Idx] |= uint8_t((Value >> (i * 8)) & 0xff);
  }
}

std::unique_ptr<MCObjectTargetWriter>
MMIXAsmBackend::createObjectTargetWriter() const {
  return createMMIXELFObjectWriter(OSABI);
}

} // end anonymous namespace

MCAsmBackend *llvm::createMMIXAsmBackend(const Target &T,
                                         const MCSubtargetInfo &STI,
                                         const MCRegisterInfo &MRI,
                                         const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new MMIXAsmBackend(STI, OSABI);
}
