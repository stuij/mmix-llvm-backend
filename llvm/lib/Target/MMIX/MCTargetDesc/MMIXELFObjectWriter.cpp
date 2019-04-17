//===-- MMIXELFObjectWriter.cpp - MMIX ELF Writer -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

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
                              /*HasRelocationAddend*/ true) {}

MMIXELFObjectWriter::~MMIXELFObjectWriter() {}

unsigned MMIXELFObjectWriter::getRelocType(MCContext &Ctx,
                                           const MCValue &Target,
                                           const MCFixup &Fixup,
                                           bool IsPCRel) const {
  report_fatal_error("invalid fixup kind!");
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createMMIXELFObjectWriter(uint8_t OSABI) {
  return std::make_unique<MMIXELFObjectWriter>(OSABI);
}
