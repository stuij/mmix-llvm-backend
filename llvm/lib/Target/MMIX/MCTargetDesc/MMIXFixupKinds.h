//===-- MMIXFixupKinds.h - MMIX Specific Fixup Entries --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXFIXUPKINDS_H
#define LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

#undef MMIX

namespace llvm {
namespace MMIX {
enum Fixups {
  // fixup_mmix_rel_16 - pc-relative 16-bit fixup for the branch instructions
  fixup_mmix_rel_16 = FirstTargetFixupKind,
  // fixup_mmix_rel_24 - pc-relative 24-bit fixup for the JMP instruction
  fixup_mmix_rel_24,
  // fixup_mmix_h - absolute 16-bit high byte fixup for the relevant
  // immediate wyde instructions: SETH, INCH, ORH, ANDNH
  fixup_mmix_h,
  // fixup_mmix_h - absolute 16-bit middle high byte fixup for the relevant
  // immediate wyde instructions: SETMH, INCMH, ORMH, ANDNMH
  fixup_mmix_mh,
  // fixup_mmix_h - absolute 16-bit middle low byte fixup for the relevant
  // immediate wyde instructions: SETML, INCML, ORML, ANDNML
  fixup_mmix_ml,
  // fixup_mmix_h - absolute 16-bit low byte fixup for the relevant
  // immediate wyde instructions: SETL, INCL, ORL, ANDNL
  fixup_mmix_l,
  // fixup_mmix_invalid - used as a sentinel and a marker, must be last fixup
  fixup_mmix_invalid,
  NumTargetFixupKinds = fixup_mmix_invalid - FirstTargetFixupKind
};
} // end namespace MMIX
} // end namespace llvm

#endif
