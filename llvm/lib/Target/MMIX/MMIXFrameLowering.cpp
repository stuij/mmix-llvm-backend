//===-- MMIXFrameLowering.cpp - MMIX Frame Information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the MMIX implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "MMIXFrameLowering.h"
#include "MMIXSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

bool MMIXFrameLowering::hasFP(const MachineFunction &MF) const { return true; }

// Determines the size of the frame and maximum call frame size.
void MMIXFrameLowering::determineFrameLayout(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const MMIXRegisterInfo *RI = STI.getRegisterInfo();

  // Get the number of bytes to allocate from the FrameInfo.
  uint64_t FrameSize = MFI.getStackSize();

  // Get the alignment.
  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

  // Get the maximum call frame size of all the calls.
  uint64_t MaxCallFrameSize = MFI.getMaxCallFrameSize();

  // If we have dynamic alloca then MaxCallFrameSize needs to be aligned so
  // that allocations will be aligned.
  if (MFI.hasVarSizedObjects())
    MaxCallFrameSize = alignTo(MaxCallFrameSize, StackAlign);

  // Update maximum call frame size.
  MFI.setMaxCallFrameSize(MaxCallFrameSize);

  // Include call frame size in total.
  if (!(hasReservedCallFrame(MF) && MFI.adjustsStack()))
    FrameSize += MaxCallFrameSize;

  // Make sure the frame is aligned.
  FrameSize = alignTo(FrameSize, StackAlign);

  // Update frame info.
  MFI.setStackSize(FrameSize);
}

void MMIXFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI,
                                  const DebugLoc &DL, unsigned DestReg,
                                  unsigned SrcReg, int64_t Val,
                                  MachineInstr::MIFlag Flag) const {
  const MMIXInstrInfo *TII = STI.getInstrInfo();

  if (DestReg == SrcReg && Val == 0)
    return;

  if (Val >=0 && Val <= 0xFF)
    BuildMI(MBB, MBBI, DL, TII->get(MMIX::ADD_I), DestReg)
        .addReg(SrcReg)
        .addImm(Val)
        .setMIFlag(Flag);
  else if (Val < 0 && Val >= -0xFF)
    BuildMI(MBB, MBBI, DL, TII->get(MMIX::SUB_I), DestReg)
        .addReg(SrcReg)
        .addImm(-Val)
        .setMIFlag(Flag);
  else
    report_fatal_error("adjustReg cannot yet handle adjustments >8 bits "
                       "or negative values");
}

// Returns the register used to hold the frame pointer.
static unsigned getFPReg(const MMIXSubtarget &STI) { return MMIX::r253; }

// Returns the register used to hold the stack pointer.
static unsigned getSPReg(const MMIXSubtarget &STI) { return MMIX::r254; }

static size_t getCalleeSavedSize(const std::vector<CalleeSavedInfo> &CSI,
                                    const TargetRegisterInfo *TRI) {
  size_t Size = 0;
  for (const CalleeSavedInfo &CI : CSI) {
    unsigned Reg = CI.getReg();
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);

    if (MMIX::GPRRegClass.hasSubClassEq(RC))
      Size += 1;
    else if (MMIX::SRRegClass.hasSubClassEq(RC))
      Size += 2;
    else
      llvm_unreachable("Unknown callee saved size information for register class");
  }
  return Size;
}

void MMIXFrameLowering::emitPrologue(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  if (!hasFP(MF)) {
    report_fatal_error(
        "emitPrologue doesn't support framepointer-less functions");
  }

  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineBasicBlock::iterator MBBI = MBB.begin();

  unsigned FPReg = getFPReg(STI);
  unsigned SPReg = getSPReg(STI);

  // Debug location must be unknown since the first debug location is used
  // to determine the end of the prologue.
  DebugLoc DL;

  // Determine the correct frame layout
  determineFrameLayout(MF);

  // FIXME (note copied from Lanai): This appears to be overallocating.  Needs
  // investigation. Get the number of bytes to allocate from the FrameInfo.
  uint64_t StackSize = MFI.getStackSize();

  // Early exit if there is no need to allocate on the stack
  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  // Allocate space on the stack if necessary.
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, -StackSize, MachineInstr::FrameSetup);

  // The frame pointer is callee-saved, and code has been generated for us to
  // save it to the stack. We need to skip over the storing of callee-saved
  // registers as the frame pointer must be modified after it has been saved
  // to the stack, not before.
  size_t CalleeSavedSize = getCalleeSavedSize(
      MFI.getCalleeSavedInfo(), MF.getSubtarget().getRegisterInfo());
  std::advance(MBBI, CalleeSavedSize);

  // Generate new FP.
  adjustReg(MBB, MBBI, DL, FPReg, SPReg, StackSize, MachineInstr::FrameSetup);
}


void MMIXFrameLowering::emitEpilogue(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  if (!hasFP(MF)) {
    report_fatal_error(
        "emitEpilogue doesn't support framepointer-less functions");
  }

  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const MMIXRegisterInfo *RI = STI.getRegisterInfo();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  DebugLoc DL = MBBI->getDebugLoc();
  unsigned FPReg = getFPReg(STI);
  unsigned SPReg = getSPReg(STI);

  // Skip to before the restores of callee-saved registers
  // FIXME: assumes exactly one instruction is used to restore each
  // callee-saved register.
  MachineBasicBlock::iterator LastFrameDestroy = MBBI;
  size_t CalleeSavedSize = getCalleeSavedSize(
      MFI.getCalleeSavedInfo(), MF.getSubtarget().getRegisterInfo());
  std::advance(LastFrameDestroy, -CalleeSavedSize);

  uint64_t StackSize = MFI.getStackSize();

  // Restore the stack pointer using the value of the frame pointer. Only
  // necessary if the stack pointer was modified, meaning the stack size is
  // unknown.
  if (RI->needsStackRealignment(MF) || MFI.hasVarSizedObjects()) {
    adjustReg(MBB, LastFrameDestroy, DL, SPReg, FPReg, -StackSize,
              MachineInstr::FrameDestroy);
  }

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, StackSize, MachineInstr::FrameDestroy);
}

int MMIXFrameLowering::getFrameIndexReference(const MachineFunction &MF,
                                              int FI,
                                              unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterInfo *RI = MF.getSubtarget().getRegisterInfo();

  // Callee-saved registers should be referenced relative to the stack
  // pointer (positive offset), otherwise use the frame pointer (negative
  // offset).
  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  int MinCSFI = 0;
  int MaxCSFI = -1;

  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  if (CSI.size()) {
    MinCSFI = CSI[0].getFrameIdx();
    MaxCSFI = CSI[CSI.size() - 1].getFrameIdx();
  }

  FrameReg = RI->getFrameRegister(MF);
  if (FI >= MinCSFI && FI <= MaxCSFI) {
    FrameReg = MMIX::r254;
    Offset += MF.getFrameInfo().getStackSize();
  }
  return Offset;
}

void MMIXFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                              BitVector &SavedRegs,
                                              RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);
  // TODO: Once frame pointer elimination is implemented, don't
  // unconditionally spill the frame pointer and return address.
  SavedRegs.set(MMIX::r253);
}
