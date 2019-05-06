//===-- MMIXSubtarget.cpp - MMIX Subtarget Information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the MMIX specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "MMIXSubtarget.h"
#include "MMIX.h"
#include "MMIXFrameLowering.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "mmix-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "MMIXGenSubtargetInfo.inc"

void MMIXSubtarget::anchor() {}

MMIXSubtarget &MMIXSubtarget::initializeSubtargetDependencies(StringRef CPU,
                                                              StringRef FS) {
  // Determine default and user-specified characteristics
  std::string CPUName = CPU;
  if (CPUName.empty())
    CPUName = "generic-mmix";
  ParseSubtargetFeatures(CPUName, FS);
  return *this;
}

MMIXSubtarget::MMIXSubtarget(const Triple &TT, const std::string &CPU,
                             const std::string &FS, const TargetMachine &TM)
    : MMIXGenSubtargetInfo(TT, CPU, FS),
      FrameLowering(initializeSubtargetDependencies(CPU, FS)),
      InstrInfo(), RegInfo(getHwMode()), TLInfo(TM, *this) {}
