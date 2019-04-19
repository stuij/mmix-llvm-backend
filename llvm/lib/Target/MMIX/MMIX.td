//===- MMIX.td - Describe the MMIX Target Machine --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// MMIX processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic-mmix", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "MMIXRegisterInfo.td"
include "MMIXInstrInfo.td"

def MMIXInstrInfo : InstrInfo;
def MMIXAsmParser : AsmParser;

//===----------------------------------------------------------------------===//
// MMIX processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def MMIX : Target {
  let AssemblyParsers = [MMIXAsmParser];
  // Pull in Instruction Info:
  let InstructionSet = MMIXInstrInfo;
}
