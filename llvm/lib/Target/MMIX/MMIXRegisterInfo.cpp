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


static unsigned getRegOpForImmOpVariant(unsigned Opcode) {
  switch (Opcode) {
  // loads
  case MMIX::LDB_I:
    return MMIX::LDB_R;
  case MMIX::LDBU_I:
    return MMIX::LDBU_R;
  case MMIX::LDW_I:
    return MMIX::LDW_R;
  case MMIX::LDWU_I:
    return MMIX::LDWU_R;
  case MMIX::LDT_I:
    return MMIX::LDT_R;
  case MMIX::LDTU_I:
    return MMIX::LDTU_R;
  case MMIX::LDO_I:
    return MMIX::LDO_R;
  // stores
  case MMIX::STB_I:
    return MMIX::STB_R;
  case MMIX::STW_I:
    return MMIX::STW_R;
  case MMIX::STT_I:
    return MMIX::STT_R;
  case MMIX::STO_I:
    return MMIX::STO_R;
  case MMIX::ADD_I:
    return MMIX::ADD_R;
  default:
    llvm_unreachable("Invalid opcode");
  }
}

void MMIXRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                           int SPAdj, unsigned FIOperandNum,
                                           RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");

  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();
  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  unsigned FrameReg;
  int Offset =
      getFrameLowering(MF)->getFrameIndexReference(MF, FrameIndex, FrameReg) +
      MI.getOperand(FIOperandNum + 1).getImm();

  assert(MF.getSubtarget().getFrameLowering()->hasFP(MF) &&
         "eliminateFrameIndex currently requires hasFP");

  if (MI.getOpcode() == MMIX::ADD_I && Offset < 0 && isInt<8>(Offset)) {
    MI.setDesc(TII->get(MMIX::SUB_I));
    MI.getOperand(FIOperandNum + 1).ChangeToImmediate(-Offset);
  } else if (Offset < 0) {
    MI.setDesc(TII->get(getRegOpForImmOpVariant(MI.getOpcode())));
    unsigned Reg = MRI.createVirtualRegister(&MMIX::GPRRegClass);

    BuildMI(*MI.getParent(), II, DL, TII->get(MMIX::LDI), Reg)
        .addImm(Offset);

    MI.getOperand(FIOperandNum + 1)
        .ChangeToRegister(Reg, /*isDef=*/false, /*isImp=*/false,
                          /*isKill=*/true);
  } else {
    MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
  }

  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false);
}

Register MMIXRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return MMIX::r253;
}

const uint32_t *
MMIXRegisterInfo::getCallPreservedMask(const MachineFunction & /*MF*/,
                                       CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}
