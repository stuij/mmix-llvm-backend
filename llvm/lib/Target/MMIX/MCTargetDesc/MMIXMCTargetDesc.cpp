//===-- MMIXMCTargetDesc.cpp - MMIX Target Descriptions -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides MMIX specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "MMIXMCTargetDesc.h"
#include "MMIXInstPrinter.h"
#include "MMIXMCAsmInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "MMIXGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "MMIXGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "MMIXGenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createMMIXMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitMMIXMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createMMIXMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  // We haven't defined the return address register (rJ(ump)) yet.
  // We should get away without for now. It's normally not addressed directly.
  InitMMIXMCRegisterInfo(X, /* Return Address register */ 0);
  return X;
}

static MCAsmInfo *createMMIXMCAsmInfo(const MCRegisterInfo &MRI,
                                      const Triple &TT,
                                      const MCTargetOptions &Options) {
  return new MMIXMCAsmInfo(TT);
}

static MCSubtargetInfo *createMMIXMCSubtargetInfo(const Triple &TT,
                                                  StringRef CPU, StringRef FS) {
  std::string CPUName = CPU;
  if (CPUName.empty())
    CPUName = "generic-mmix";
  return createMMIXMCSubtargetInfoImpl(TT, CPUName, FS);
}

static MCInstPrinter *createMMIXMCInstPrinter(const Triple &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI) {
  return new MMIXInstPrinter(MAI, MII, MRI);
}

extern "C" void LLVMInitializeMMIXTargetMC() {
  TargetRegistry::RegisterMCAsmInfo(getTheMMIXTarget(),
                                    createMMIXMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(getTheMMIXTarget(),
                                      createMMIXMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(getTheMMIXTarget(),
                                    createMMIXMCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(getTheMMIXTarget(),
                                       createMMIXAsmBackend);
  TargetRegistry::RegisterMCCodeEmitter(getTheMMIXTarget(),
                                        createMMIXMCCodeEmitter);
  TargetRegistry::RegisterMCSubtargetInfo(getTheMMIXTarget(),
                                          createMMIXMCSubtargetInfo);
  TargetRegistry::RegisterMCInstPrinter(getTheMMIXTarget(),
                                        createMMIXMCInstPrinter);
}
