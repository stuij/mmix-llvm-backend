//===-- MMIXInstrInfo.cpp - MMIX Instruction Information ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the MMIX implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "MMIXInstrInfo.h"
#include "MMIX.h"
#include "MMIXSubtarget.h"
#include "MMIXTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "MMIXGenInstrInfo.inc"

using namespace llvm;

MMIXInstrInfo::MMIXInstrInfo() : MMIXGenInstrInfo() {}

void MMIXInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                const DebugLoc &DL, MCRegister DstReg,
                                MCRegister SrcReg, bool KillSrc) const {
  assert(MMIX::GPRRegClass.contains(DstReg, SrcReg) &&
         "Impossible reg-to-reg copy");

  BuildMI(MBB, MBBI, DL, get(MMIX::ADD_I), DstReg)
      .addReg(SrcReg, getKillRegState(KillSrc))
      .addImm(0);
}

void MMIXInstrInfo::expandLDImm(MachineBasicBlock::iterator MI) const {
  // The dest reg is dead. No use in loading the immediate.
  if (MI->getOperand(0).isDead())
    return;

  DebugLoc DL = MI->getDebugLoc();
  MachineBasicBlock *MBB = MI->getParent();

  uint64_t imm = MI->getOperand(1).getImm();
  BuildMI(*MBB, MI, DL, get(MMIX::SETH))
      .add(MI->getOperand(0))
      .addImm(imm >> 48);
  BuildMI(*MBB, MI, DL, get(MMIX::ORMH))
      .add(MI->getOperand(0))
      .addImm((imm >> 32) & 0xffff);
  BuildMI(*MBB, MI, DL, get(MMIX::ORML))
      .add(MI->getOperand(0))
      .addImm((imm >> 16) & 0xffff);
  BuildMI(*MBB, MI, DL, get(MMIX::ORL))
      .add(MI->getOperand(0))
      .addImm(imm & 0xffff);

  MBB->erase(MI);
}

bool MMIXInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  if (MI.getOpcode() == MMIX::LDI) {
    expandLDImm(MI);
    return true;
  }
  return false;
}
