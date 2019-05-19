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

def imm64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;


// immediate wyde operands: INCH, SETMH, ORML, ANDNL, etc..
class WydeAsmOperand<string pos>
    : AsmOperandClass {
  let Name = "Wyde" # pos;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidWyde";
}

def h_imm : Operand<i64> {
  let ParserMatchClass = WydeAsmOperand<"H">;
  let EncoderMethod = "getHWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def mh_imm : Operand<i64> {
  let ParserMatchClass = WydeAsmOperand<"MH">;
  let EncoderMethod = "getMHWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def ml_imm : Operand<i64> {
  let ParserMatchClass = WydeAsmOperand<"ML">;
  let EncoderMethod = "getMLWydeOpValue";
  let DecoderMethod = "decodeUImmOperand<16>";
}

def l_imm : Operand<i64> {
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

/// ALUs
// 3 operand ALUs
class ALU3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass ALU3multi<bits<8> opcode, string opname> {
  def _R : ALU3op<opcode, (ins GPR:$y, GPR:$z), opname>;
  def _I : ALU3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z), opname>;
}

defm ADD    : ALU3multi<0x20, "add">;
defm ADDU   : ALU3multi<0x22, "addu">;
defm SUB    : ALU3multi<0x24, "sub">;
defm SUBU   : ALU3multi<0x26, "subu">;

// 2 operand ALUs
class ALU2op<bits<8> opcode, string opname>
    : MMIX2op<opcode, (outs GPR:$x), (ins uimm16:$yz), opname>;


/// 'Wyde' instructions get their own parent class because of label operand
class Wyde2op<bits<8> opcode, string opname, dag ins>
    : MMIX2op<opcode, (outs GPR:$x), ins, opname>;

def SETH  : Wyde2op<0xe0, "seth", (ins h_imm:$yz)>;
def SETMH : Wyde2op<0xe1, "setmh", (ins mh_imm:$yz)>;
def SETML : Wyde2op<0xe2, "setml", (ins ml_imm:$yz)>;
def SETL  : Wyde2op<0xe3, "setl", (ins l_imm:$yz)>;

def ORH  : Wyde2op<0xe8, "orh", (ins h_imm:$yz)>;
def ORMH : Wyde2op<0xe9, "ormh", (ins mh_imm:$yz)>;
def ORML : Wyde2op<0xea, "orml", (ins ml_imm:$yz)>;
def ORL  : Wyde2op<0xeb, "orl", (ins l_imm:$yz)>;


/// control flow
let isCall = 1, mayLoad = 1 in
def PUSHJ_F : MMIX2op<0xf2, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;
let isCall = 1, mayLoad = 1 in
def PUSHJ_B : MMIX2op<0xf3, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;

let isReturn = 1, mayStore = 1 in
def POP : MMIX2op<0xf8, (outs), (ins uimm8:$x, uimm16:$yz), "pop">;

def JMP_F : MMIX1op<0xf0, (ins jmp_imm:$xyz), "jmp">;
def JMP_B : MMIX1op<0xf1, (ins jmp_imm:$xyz), "jmp">;


/// load and store
// signed and unsigned extended loads
let mayLoad = 1 in
class LD3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass LD3multi<bits<8> opcode, string opname> {
  def _R : LD3op<opcode, (ins GPR:$y, GPR:$z), opname>;
  def _I : LD3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z), opname>;
}

defm LDB  : LD3multi<0x80, "ldb">;
defm LDBU : LD3multi<0x82, "ldbu">;
defm LDW  : LD3multi<0x84, "ldw">;
defm LDWU : LD3multi<0x86, "ldwu">;
defm LDT  : LD3multi<0x88, "ldt">;
defm LDTU : LD3multi<0x8A, "ldtu">;
defm LDO  : LD3multi<0x8C, "ldo">;
defm LDOU : LD3multi<0x8E, "ldou">;


// store
let mayStore = 1 in
class ST3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs), ins, opname> {
}

multiclass ST3multi<bits<8> opcode, string opname> {
  def _R : ST3op<opcode, (ins GPR:$x, GPR:$y, GPR:$z), opname>;
  def _I : ST3op<!add(opcode, 1), (ins GPR:$x, GPR:$y, uimm8:$z), opname>;
}

defm STB  : ST3multi<0xA0, "stb">;
defm STBU : ST3multi<0xA2, "stbu">;
defm STW  : ST3multi<0xA4, "stw">;
defm STWU : ST3multi<0xA6, "stwu">;
defm STT  : ST3multi<0xA8, "stt">;
defm STTU : ST3multi<0xAA, "sttu">;
defm STO  : ST3multi<0xAC, "sto">;
defm STOU : ST3multi<0xAE, "stou">;


//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//
// Naming convention: For 'generic' pattern classes, we use the naming
// convention PatTy1Ty2. For pattern classes which offer a more complex
// expension, prefix the class name, e.g. BccPat.
//===----------------------------------------------------------------------===//

/// Immediates
// load immediate
def LDI : Pseudo<(outs GPR:$x), (ins imm64:$yz), []>;

def : Pat<(uimm16:$yz), (SETL uimm16:$yz)>;
def : Pat<(imm64:$yz), (LDI imm64:$yz)>;


/// Generic pattern classes
class PatGprGpr<SDPatternOperator OpNode, ALU3op Inst>
    : Pat<(OpNode GPR:$y, GPR:$z), (Inst GPR:$y, GPR:$z)>;
class PatGprUimm8<SDPatternOperator OpNode, ALU3op Inst>
    : Pat<(OpNode GPR:$y, uimm8:$z), (Inst GPR:$y, uimm8:$z)>;


/// Simple arithmetic operations
multiclass AluPat<PatFrag AluOp, string op> {
  def : PatGprGpr<AluOp, !cast<ALU3op>(op#_R)>;
  def : PatGprUimm8<AluOp, !cast<ALU3op>(op#_I)>;
}

defm : AluPat<add, "ADD">;
defm : AluPat<sub, "SUB">;


/// Branches, jumps and returns
let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : Pseudo<(outs), (ins), [(RetFlag)]>,
                PseudoInstExpansion<(POP 0, 0)>;


/// load and store
// signed and unsigned extended loads
multiclass LdPat<PatFrag LoadOp, LD3op Inst> {
  def : Pat<(LoadOp GPR:$y), (Inst GPR:$y, 0)>;
  def : Pat<(LoadOp (add GPR:$y, uimm8:$z)),
            (Inst GPR:$y, uimm8:$z)>;
}

// load i8
defm : LdPat<extloadi8, LDB_I>;
defm : LdPat<sextloadi8, LDB_I>;
defm : LdPat<zextloadi8, LDBU_I>;
// load i16
defm : LdPat<extloadi16, LDW_I>;
defm : LdPat<sextloadi16, LDW_I>;
defm : LdPat<zextloadi16, LDWU_I>;
// load i32
defm : LdPat<extloadi32, LDT_I>;
defm : LdPat<sextloadi32, LDT_I>;
defm : LdPat<zextloadi32, LDTU_I>;
// load i64
defm : LdPat<load, LDO_I>;


// store
multiclass StPat<PatFrag StoreOp, ST3op Inst> {
  def : Pat<(StoreOp GPR:$x, GPR:$y), (Inst GPR:$x, GPR:$y, 0)>;
  def : Pat<(StoreOp GPR:$x, (add GPR:$y, uimm8:$z)),
            (Inst GPR:$x, GPR:$y, uimm8:$z)>;
}

defm : StPat<truncstorei8, STB_I>;
defm : StPat<truncstorei16, STW_I>;
defm : StPat<truncstorei32, STT_I>;
defm : StPat<store, STO_I>;
