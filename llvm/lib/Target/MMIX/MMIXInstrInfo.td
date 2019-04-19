//===-- MMIXInstrInfo.td - Target Description for MMIX Target -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the MMIX instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "MMIXInstrFormats.td"

//===----------------------------------------------------------------------===//
// Operands
//===----------------------------------------------------------------------===//

class UImmAsmOperand<int width>
    : AsmOperandClass {
  let Name = "UImm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def uimm8 : Operand<i64> {
  let ParserMatchClass = UImmAsmOperand<8>;
}

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

// ALUs
// 3 operand ALUs
class ALU3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass ALU3multi<bits<8> opcode, string opname> {
  def _R : ALU3op<opcode, (ins GPR:$y, GPR:$z), opname>;
  def _I : ALU3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z), opname>;
}

defm ADD : ALU3multi<0x20, "add">;
