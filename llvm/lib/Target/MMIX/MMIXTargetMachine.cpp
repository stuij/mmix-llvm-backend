//===-- MMIXTargetMachine.cpp - Define TargetMachine for MMIX -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Implements the info about MMIX target spec.
//
//===----------------------------------------------------------------------===//

#include "MMIX.h"
#include "MMIXTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

extern "C" void LLVMInitializeMMIXTarget() {
  RegisterTargetMachine<MMIXTargetMachine> Y(getTheMMIXTarget());
}

static std::string computeDataLayout(const Triple &TT) {
  return "E"     // Big endian
      "-m:e"     // ELF name mangling
      "-p:64:64" // 64 bit pointers, 64 bit aligned
      "-i64:64"  // 64 bit integers, 64 bit aligned
      "-n64"     // 64bit native integer width
      "-S64";    // 64 bit natural stack alignment
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

MMIXTargetMachine::MMIXTargetMachine(const Target &T, const Triple &TT,
                                     StringRef CPU, StringRef FS,
                                     const TargetOptions &Options,
                                     Optional<Reloc::Model> RM,
                                     Optional<CodeModel::Model> CM,
                                     CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT), TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<TargetLoweringObjectFileELF>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
class MMIXPassConfig : public TargetPassConfig {
public:
  MMIXPassConfig(MMIXTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  MMIXTargetMachine &getMMIXTargetMachine() const {
    return getTM<MMIXTargetMachine>();
  }

  bool addInstSelector() override;
};
}

TargetPassConfig *MMIXTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new MMIXPassConfig(*this, PM);
}

bool MMIXPassConfig::addInstSelector() {
  addPass(createMMIXISelDag(getMMIXTargetMachine()));

  return false;
}
