//===- MMIX.td - Describe the MMIX Target Machine --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// We define a few instruction classes to capture some abstract shapes the
// instruction layouts can take. All instructions start with an 8-bit opcode
// prefix, followed by a few variations of register/immediate combinations.
//===----------------------------------------------------------------------===//

class MMIXInst<dag outs, dag ins, string opcodestr, string argstr,
             list<dag> pattern>
    : Instruction {
  field bits<32> Inst;
  let Size = 4;

  bits<8> Opcode = 0;

  let Inst{31-24} = Opcode;

  let Namespace = "MMIX";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;

  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Pseudo instructions
class Pseudo<dag outs, dag ins, list<dag> pattern>
    : MMIXInst<outs, ins, "", "", pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

// 3 operands
class MMIX3op<bits<8> opcode, dag outs, dag ins, string opcodestr>
    : MMIXInst<outs, ins, opcodestr, "$x,$y,$z", []> {
  bits<8> x;
  bits<8> y;
  bits<8> z;

  let Opcode = opcode;
  let Inst{23-16} = x;
  let Inst{15-8} = y;
  let Inst{7-0} = z;
}
