//===-- MMIXRegisterInfo.cpp - MMIX Register Information ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the MMIX implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "MMIXRegisterInfo.h"
#include "MMIX.h"
#include "MMIXSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"

#define GET_REGINFO_TARGET_DESC
#include "MMIXGenRegisterInfo.inc"

using namespace llvm;

MMIXRegisterInfo::MMIXRegisterInfo(unsigned HwMode)
    : MMIXGenRegisterInfo(/*Return address*/ 0,
                          /*DwarfFlavour*/ 0,
                          /*EHFlavor*/ 0,
                          /*PC*/ 0,
                          HwMode) {}

const MCPhysReg *
MMIXRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector MMIXRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  markSuperRegs(Reserved, MMIX::r254); // sp
  markSuperRegs(Reserved, MMIX::r253); // frame register
  markSuperRegs(Reserved, MMIX::r252); // tmp link register

  return Reserved;
}

const uint32_t *MMIXRegisterInfo::getNoPreservedMask() const {
  return CSR_NoRegs_RegMask;
}

void MMIXRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                           int SPAdj, unsigned FIOperandNum,
                                           RegScavenger *RS) const {
  // TODO: this implementation is a temporary placeholder which does just
  // enough to allow other aspects of code generation to be tested

  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");

  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  DebugLoc DL = MI.getDebugLoc();

  unsigned FrameReg = getFrameRegister(MF);
  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  int Offset = TFI->getFrameIndexReference(MF, FrameIndex, FrameReg);
  Offset += MI.getOperand(FIOperandNum + 1).getImm();

  assert(TFI->hasFP(MF) && "eliminateFrameIndex currently requires hasFP");

  // Offsets must be directly encoded in a 16-bit immediate field
  if (Offset < -262144 || Offset > 262140) {
    report_fatal_error(
        "Frame offsets outside of -262144 - 262140 range not supported");
  }

  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false);
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

Register MMIXRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return MMIX::r253;
}

const uint32_t *
MMIXRegisterInfo::getCallPreservedMask(const MachineFunction & /*MF*/,
                                       CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}
