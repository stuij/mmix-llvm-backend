//===-- MMIX.h - Top-level interface for MMIX -----------------*- C++ --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in th LLVM
// MMIX back-end.
//
//===---------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MMIX_MMIX_H
#define LLVM_LIB_TARGET_MMIX_MMIX_H

#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class MMIXTargetMachine;
class MCInst;
class MachineInstr;

void LowerMMIXMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI);

FunctionPass *createMMIXISelDag(MMIXTargetMachine &TM);
}

#endif
