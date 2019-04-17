//===-- MMIXTargetInfo.cpp - MMIX Target Implementation -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {

Target &getTheMMIXTarget() {
  static Target TheMMIXTarget;
  return TheMMIXTarget;
}
}

extern "C" void LLVMInitializeMMIXTargetInfo() {
  RegisterTarget<Triple::mmix> Y(getTheMMIXTarget(), "mmix",
                                    "MMIX", "MMIX");
}
