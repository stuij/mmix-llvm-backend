//===- MMIX.cpp ------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "InputFiles.h"
#include "Symbols.h"
#include "Target.h"
#include "lld/Common/ErrorHandler.h"
#include "llvm/Object/ELF.h"
#include "llvm/Support/Endian.h"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::support::endian;
using namespace llvm::ELF;
using namespace lld;
using namespace lld::elf;

namespace {
class MMIX final : public TargetInfo {
public:
  MMIX();
  RelExpr getRelExpr(RelType type, const Symbol &s,
                     const uint8_t *loc) const override;
  void relocateOne(uint8_t *loc, RelType type, uint64_t val) const override;
};
} // namespace

MMIX::MMIX() { noneRel = R_MMIX_NONE; }

RelExpr MMIX::getRelExpr(RelType type, const Symbol &s,
                        const uint8_t *loc) const {
  switch (type) {
  case R_MMIX_REL_16:
  case R_MMIX_REL_24:
    return R_PC;
  default:
    return R_ABS;
  }
}

void MMIX::relocateOne(uint8_t *loc, RelType type, uint64_t val) const {
  switch (type) {
  case R_MMIX_REL_16: {
    checkAlignment(loc, val, 4, type);
    int64_t sval = (int64_t) val;
    if (sval < -262144 || sval > 262140)
      error(getErrorLocation(loc) + "R_MMIX_REL_16: fixup value out of range");

    int instr = read32be(loc);
    instr &= ~0xffff;
    if (sval < 0) {
      instr |= (uint64_t)(sval + 262144) >> 2;
      instr |= 1 << 24; // Make sure of right opcode to branch backwards
    } else {
      instr |= val >> 2;
      instr &= ~(1 << 24); // Make sure of right opcode to branch forwards
    }

    write32be(loc, instr);
    break;
  }
  case R_MMIX_REL_24: {
    checkAlignment(loc, val, 4, type);
    int64_t sval = (int64_t) val;
    if (sval < -67108864 || sval > 67108860)
      error(getErrorLocation(loc) + "R_MMIX_REL_24: fixup value out of range");

    int instr = read32be(loc);
    instr &= ~0xffffff;
    if (sval < 0) {
      instr |= (uint64_t)(sval + 67108864) >> 2;
      instr |= 1 << 24; // Make sure of right opcode to branch backwards
    } else {
      instr |= val >> 2;
      instr &= ~(1 << 24); // Make sure of right opcode to branch forwards
    }

    write32be(loc, instr);
    break;
  }
  case R_MMIX_H: {
    int instr = read32be(loc);
    instr &= ~0xffff;
    instr |= val >> 48;
    write32be(loc, instr);
    break;
  }
  case R_MMIX_MH: {
    int instr = read32be(loc);
    instr &= ~0xffff;
    instr |= (val >> 32) & 0xffff;
    write32be(loc, instr);
    break;
  }
  case R_MMIX_ML: {
    int instr = read32be(loc);
    instr &= ~0xffff;
    instr |= (val >> 16) & 0xffff;
    write32be(loc, instr);
    break;
  }
  case R_MMIX_L: {
    int instr = read32be(loc);
    instr &= ~0xffff;
    instr |= val & 0xffff;
    write32be(loc, instr);
    break;
  }
  default:
    error(getErrorLocation(loc) + "unrecognized relocation " + toString(type));
  }
}

TargetInfo *elf::getMMIXTargetInfo() {
  static MMIX target;
  return &target;
}
