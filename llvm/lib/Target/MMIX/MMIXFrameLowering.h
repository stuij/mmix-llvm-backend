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
                            /*LocalAreaOffset=*/ 0) {}

  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

  bool hasFP(const MachineFunction &MF) const override;

  MachineBasicBlock::iterator
  eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MI) const override {
    return MBB.erase(MI);
  }

};
}
#endif
