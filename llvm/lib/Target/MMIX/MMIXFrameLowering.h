//===-- MMIXFrameLowering.h - Define frame lowering for MMIX -*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class implements MMIX-specific bits of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MMIX_MMIXFRAMELOWERING_H
#define LLVM_LIB_TARGET_MMIX_MMIXFRAMELOWERING_H

#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {
class MMIXSubtarget;

class MMIXFrameLowering : public TargetFrameLowering {
public:
  explicit MMIXFrameLowering(const MMIXSubtarget &STI)
      : TargetFrameLowering(StackGrowsDown,
                            /*StackAlignment=*/ Align(16),
                            /*LocalAreaOffset=*/ 0),
        STI(STI) {}

  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

  int getFrameIndexReference(const MachineFunction &MF, int FI,
                             unsigned &FrameReg) const override;

  void determineCalleeSaves(MachineFunction &MF, BitVector &SavedRegs,
                            RegScavenger *RS) const override;

  bool hasFP(const MachineFunction &MF) const override;

  MachineBasicBlock::iterator
  eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MI) const override {
    return MBB.erase(MI);
  }

protected:
  const MMIXSubtarget &STI;

private:
  void determineFrameLayout(MachineFunction &MF) const;
  void adjustReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                 const DebugLoc &DL, unsigned DestReg, unsigned SrcReg,
                 int64_t Val, MachineInstr::MIFlag Flag) const;
};
}
#endif
