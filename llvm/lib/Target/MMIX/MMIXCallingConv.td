//===-- MMIXCallingConv.td - Calling Conventions MMIX ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the MMIX architecture.
//
//===----------------------------------------------------------------------===//

// MMIX C return-value convention.
def RetCC_MMIX : CallingConv<[CCIfType<[i64], CCAssignToReg<[r231, r232]>>]>;

// MMIX C Calling convention.
def CC_MMIX : CallingConv<[
  // Promote i8/i16/132 args to i64
  CCIfType<[ i8, i16, i32 ], CCPromoteToType<i64>>,

  // All arguments get passed in integer registers if there is space.
  CCIfType<[i64], CCAssignToReg<[ r231, r232, r233, r234, r235, r236, r237, r238, r239, r240, r241, r242, r243, r244, r245, r246 ]>>,

  // Could be assigned to the stack in 8-byte aligned units, but unsupported
  CCAssignToStack<8, 8>
]>;

def CSR : CalleeSavedRegs<(add r253, (sequence "r%u", 0, 15))>;
