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
// MMIX specific DAG Nodes.
//===----------------------------------------------------------------------===//

def RetFlag : SDNode<"MMIXISD::RET_FLAG", SDTNone,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

//===----------------------------------------------------------------------===//
// Operands
//===----------------------------------------------------------------------===//

class UImmAsmOperand<int width>
    : AsmOperandClass {
  let Name = "UImm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def uimm8 : Operand<i64>, ImmLeaf<i64, [{return isUInt<8>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<8>;
  let DecoderMethod = "decodeUImmOperand<8>";
}

def uimm16 : Operand<i64>, ImmLeaf<i64, [{return isUInt<16>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<16>;
  let DecoderMethod = "decodeUImmOperand<16>";
}

// immediate wyde operands: INCH, SETMH, ORML, ANDNL, etc..
class WydeAsmOperand<string pos>
    : AsmOperandClass {
  let Name = "Wyde" # pos;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidWyde";
}

def h_imm : Operand<OtherVT> {
  let ParserMatchClass = WydeAsmOperand<"H">;
  let EncoderMethod = "getHWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def mh_imm : Operand<OtherVT> {
  let ParserMatchClass = WydeAsmOperand<"MH">;
  let EncoderMethod = "getMHWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def ml_imm : Operand<OtherVT> {
  let ParserMatchClass = WydeAsmOperand<"ML">;
  let EncoderMethod = "getMLWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def l_imm : Operand<OtherVT> {
  let ParserMatchClass = WydeAsmOperand<"L">;
  let EncoderMethod = "getLWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

// branch operands
class BranchAsmOperand<int width>
    : AsmOperandClass {
  let Name = "BranchImm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def branch_imm : Operand<OtherVT> {
  let ParserMatchClass = BranchAsmOperand<16>;
  let EncoderMethod = "getBranchTargetOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
  let PrintMethod = "printBranchImm";
}

def jmp_imm : Operand<OtherVT> {
  let ParserMatchClass = BranchAsmOperand<24>;
  let EncoderMethod = "getJumpTargetOpValue";
  let DecoderMethod = "decodeUImmOperand<24>";
  let PrintMethod = "printJumpImm";
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

// 2 operand ALUs
class ALU2op<bits<8> opcode, string opname>
    : MMIX2op<opcode, (outs GPR:$x), (ins uimm16:$yz), opname>;

// 'Wyde' instructions get their own parent class because of label operand
class Wyde2op<bits<8> opcode, string opname, dag ins>
    : MMIX2op<opcode, (outs GPR:$x), ins, opname>;

def SETH : Wyde2op<0xe0, "seth", (ins h_imm:$yz)>;
def ORH  : Wyde2op<0xe8, "orh", (ins h_imm:$yz)>;
def ORMH : Wyde2op<0xe9, "ormh", (ins mh_imm:$yz)>;
def ORML : Wyde2op<0xea, "orml", (ins ml_imm:$yz)>;
def ORL  : Wyde2op<0xeb, "orl", (ins l_imm:$yz)>;

// control flow
let isCall = 1, mayLoad = 1 in
def PUSHJ_F : MMIX2op<0xf2, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;
let isCall = 1, mayLoad = 1 in
def PUSHJ_B : MMIX2op<0xf3, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;

let isReturn = 1, mayStore = 1 in
def POP : MMIX2op<0xf8, (outs), (ins uimm8:$x, uimm16:$yz), "pop">;

def JMP_F : MMIX1op<0xf0, (ins jmp_imm:$xyz), "jmp">;
def JMP_B : MMIX1op<0xf1, (ins jmp_imm:$xyz), "jmp">;

//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//
// Naming convention: For 'generic' pattern classes, we use the naming
// convention PatTy1Ty2. For pattern classes which offer a more complex
// expension, prefix the class name, e.g. BccPat.
//===----------------------------------------------------------------------===//

/// Generic pattern classes
class PatGprGpr<SDPatternOperator OpNode, ALU3op Inst>
    : Pat<(OpNode GPR:$y, GPR:$z), (Inst GPR:$y, GPR:$z)>;
class PatGprUimm8<SDPatternOperator OpNode, ALU3op Inst>
    : Pat<(OpNode GPR:$y, uimm8:$z), (Inst GPR:$y, uimm8:$z)>;

/// Simple arithmetic operations
def : PatGprGpr<add, ADD_R>;
def : PatGprUimm8<add, ADD_I>;

/// Branches, jumps and returns
let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : Pseudo<(outs), (ins), [(RetFlag)]>,
                PseudoInstExpansion<(POP 0, 0)>;
