//===-- MMIXELFObjectWriter.cpp - MMIX ELF Writer -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MMIXFixupKinds.h"
#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class MMIXELFObjectWriter : public MCELFObjectTargetWriter {
public:
  MMIXELFObjectWriter(uint8_t OSABI);

  ~MMIXELFObjectWriter() override;

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;
};
}

MMIXELFObjectWriter::MMIXELFObjectWriter(uint8_t OSABI)
    : MCELFObjectTargetWriter(/*Is64Bit*/ true, OSABI, ELF::EM_MMIX,
                              /*HasRelocationAddend*/ false) {}

MMIXELFObjectWriter::~MMIXELFObjectWriter() {}

unsigned MMIXELFObjectWriter::getRelocType(MCContext &Ctx,
                                           const MCValue &Target,
                                           const MCFixup &Fixup,
                                           bool IsPCRel) const {
  // Determine the type of the relocation
  switch ((unsigned)Fixup.getKind()) {
  default:
    llvm_unreachable("invalid fixup kind!");
  case FK_Data_8:
    return ELF::R_MMIX_DATA;
  case MMIX::fixup_mmix_rel_16:
    return ELF::R_MMIX_REL_16;
  case MMIX::fixup_mmix_rel_24:
    return ELF::R_MMIX_REL_24;
  case MMIX::fixup_mmix_h:
    return ELF::R_MMIX_H;
  case MMIX::fixup_mmix_mh:
    return ELF::R_MMIX_MH;
  case MMIX::fixup_mmix_ml:
    return ELF::R_MMIX_ML;
  case MMIX::fixup_mmix_l:
    return ELF::R_MMIX_L;
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createMMIXELFObjectWriter(uint8_t OSABI) {
  return std::make_unique<MMIXELFObjectWriter>(OSABI);
}
