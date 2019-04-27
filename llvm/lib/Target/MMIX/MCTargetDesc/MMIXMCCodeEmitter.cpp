//===-- MMIXMCCodeEmitter.cpp - Convert MMIX code to machine code -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the MMIXMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MMIXFixupKinds.h"
#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");

namespace {
class MMIXMCCodeEmitter : public MCCodeEmitter {
  MMIXMCCodeEmitter(const MMIXMCCodeEmitter &) = delete;
  void operator=(const MMIXMCCodeEmitter &) = delete;
  MCContext &Ctx;

public:
  MMIXMCCodeEmitter(MCContext &ctx) : Ctx(ctx) {}

  ~MMIXMCCodeEmitter() override {}

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  /// TableGen'erated function for getting the binary encoding for an
  /// instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  /// Return binary encoding of operand. If the machine operand requires
  /// relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  unsigned getLabelOpValue(const MCInst &Inst, unsigned OpNo,
                           SmallVectorImpl<MCFixup> &Fixups,
                           const MCSubtargetInfo &SubtargetInfo,
                           MCFixupKind Kind) const;

  unsigned getHWydeOpValue(const MCInst &Inst, unsigned OpNo,
                           SmallVectorImpl<MCFixup> &Fixups,
                           const MCSubtargetInfo &SubtargetInfo) const;

  unsigned getMHWydeOpValue(const MCInst &Inst, unsigned OpNo,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &SubtargetInfo) const;

  unsigned getMLWydeOpValue(const MCInst &Inst, unsigned OpNo,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &SubtargetInfo) const;

  unsigned getLWydeOpValue(const MCInst &Inst, unsigned OpNo,
                           SmallVectorImpl<MCFixup> &Fixups,
                           const MCSubtargetInfo &SubtargetInfo) const;

  unsigned getBranchTargetOpValue(const MCInst &Inst, unsigned OpNo,
                                  SmallVectorImpl<MCFixup> &Fixups,
                                  const MCSubtargetInfo &SubtargetInfo) const;

  unsigned getJumpTargetOpValue(const MCInst &Inst, unsigned OpNo,
                                SmallVectorImpl<MCFixup> &Fixups,
                                const MCSubtargetInfo &SubtargetInfo) const;
};
} // end anonymous namespace

MCCodeEmitter *llvm::createMMIXMCCodeEmitter(const MCInstrInfo &MCII,
                                             const MCRegisterInfo &MRI,
                                             MCContext &Ctx) {
  return new MMIXMCCodeEmitter(Ctx);
}

void MMIXMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                          SmallVectorImpl<MCFixup> &Fixups,
                                          const MCSubtargetInfo &STI) const {
  uint32_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
  support::endian::write(OS, Bits, support::big);
  ++MCNumEmitted; // Keep track of the # of mi's emitted.
}

unsigned
MMIXMCCodeEmitter::getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                                     SmallVectorImpl<MCFixup> &Fixups,
                                     const MCSubtargetInfo &STI) const {

  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());

  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  llvm_unreachable("Unhandled expression!");
  return 0;
}

unsigned MMIXMCCodeEmitter::getBranchTargetOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  const MCOperand &MCOp = Inst.getOperand(OpNo);
  MCFixupKind Kind = static_cast<MCFixupKind>(MMIX::fixup_mmix_rel_16);
  Fixups.push_back(MCFixup::create(0, MCOp.getExpr(), Kind));
  return 0;
}

unsigned MMIXMCCodeEmitter::getJumpTargetOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  const MCOperand &MCOp = Inst.getOperand(OpNo);
  MCFixupKind Kind = static_cast<MCFixupKind>(MMIX::fixup_mmix_rel_24);
  Fixups.push_back(MCFixup::create(0, MCOp.getExpr(), Kind));
  return 0;
}

unsigned MMIXMCCodeEmitter::getLabelOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo, MCFixupKind Kind) const {
  const MCOperand &MCOp = Inst.getOperand(OpNo);
  if (MCOp.isImm())
    return getMachineOpValue(Inst, MCOp, Fixups, SubtargetInfo);

  Fixups.push_back(MCFixup::create(0, MCOp.getExpr(), Kind));
  return 0;
}

unsigned MMIXMCCodeEmitter::getHWydeOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  return getLabelOpValue(Inst, OpNo, Fixups, SubtargetInfo,
                         static_cast<MCFixupKind>(MMIX::fixup_mmix_h));
}

unsigned MMIXMCCodeEmitter::getMHWydeOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  return getLabelOpValue(Inst, OpNo, Fixups, SubtargetInfo,
                         static_cast<MCFixupKind>(MMIX::fixup_mmix_mh));
}

unsigned MMIXMCCodeEmitter::getMLWydeOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  return getLabelOpValue(Inst, OpNo, Fixups, SubtargetInfo,
                         static_cast<MCFixupKind>(MMIX::fixup_mmix_ml));
}

unsigned MMIXMCCodeEmitter::getLWydeOpValue(
    const MCInst &Inst, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &SubtargetInfo) const {
  return getLabelOpValue(Inst, OpNo, Fixups, SubtargetInfo,
                         static_cast<MCFixupKind>(MMIX::fixup_mmix_l));
}

#include "MMIXGenMCCodeEmitter.inc"
