//===-- MMIXMCAsmInfo.cpp - MMIX asm properties -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// This file contains the declaration of the MMIXMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCASMINFO_H
#define LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class MMIXMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit MMIXMCAsmInfo(const Triple &TargetTriple);
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCASMINFO_H
