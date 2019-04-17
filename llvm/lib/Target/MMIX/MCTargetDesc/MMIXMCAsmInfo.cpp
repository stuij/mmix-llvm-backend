//=====-- MMIXMCAsmInfo.h - MMIX asm properties -----------*- C++ -*--====//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the MMIXMCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "MMIXMCAsmInfo.h"
#include "llvm/ADT/Triple.h"
using namespace llvm;

void MMIXMCAsmInfo::anchor() {}

MMIXMCAsmInfo::MMIXMCAsmInfo(const Triple &TT) {
  IsLittleEndian = false;
  UseIntegratedAssembler = true;
  CodePointerSize = CalleeSaveStackSlotSize = 8;
  // Use '%' as comment string only for comments on their own line;
  // MMIXAL doesn't need comment escapes for inline comments, as the characters
  // from the third tab onwards on a line are assumed to be comments
  CommentString = "%";
  AlignmentIsInBytes = false;
  SupportsDebugInformation = true;
}
