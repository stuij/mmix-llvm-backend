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

def SDT_MMIXCall         : SDTypeProfile<0, -1, [SDTCisVT<0, i64>]>;
def SDT_MMIXCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i64>,
                                           SDTCisVT<1, i64>]>;
def SDT_MMIXCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i64>,
                                         SDTCisVT<1, i64>]>;

def Call         : SDNode<"MMIXISD::CALL", SDT_MMIXCall,
                          [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                           SDNPVariadic]>;
def CallSeqStart : SDNode<"ISD::CALLSEQ_START", SDT_MMIXCallSeqStart,
                          [SDNPHasChain, SDNPOutGlue]>;
def CallSeqEnd   : SDNode<"ISD::CALLSEQ_END", SDT_MMIXCallSeqEnd,
                          [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
def RetFlag      : SDNode<"MMIXISD::RET_FLAG", SDTNone,
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

def uimm8 : Operand<i64>, ImmLeaf<i64, [{return isUInt<8>(Imm) && Imm > 0;}]> {
  let ParserMatchClass = UImmAsmOperand<8>;
  let DecoderMethod = "decodeUImmOperand<8>";
}

def uimm16 : Operand<i64>, ImmLeaf<i64, [{return isUInt<16>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<16>;
  let DecoderMethod = "decodeUImmOperand<16>";
}

def imm64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]>;

// determines float rounding mode of certain floating point instructions
// from the MMIX documentation:
// Y = 1, ROUND_OFF (none);
// Y = 2, ROUND_UP (away from zero);
// Y = 3, ROUND_DOWN (toward zero);
// Y = 4, ROUND_NEAR (to closest);
def FloatRoundMode : AsmOperandClass {
  let Name = "FloatRoundMode";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidFloatRoundMode";
}

def float_mode : Operand<i64> {
  let ParserMatchClass = FloatRoundMode;
  let DecoderMethod = "decodeUImmOperand<3>";
}

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

/// leftovers
def TRAP   : MMIX3op<0x00, (outs), (ins uimm8:$x, uimm8:$y, uimm8:$z), "trap">;
def SWYM   : MMIX3op<0xfd, (outs), (ins uimm8:$x, uimm8:$y, uimm8:$z), "swym">;
def TRIP   : MMIX3op<0xff, (outs), (ins uimm8:$x, uimm8:$y, uimm8:$z), "trip">;

def RESUME : MMIXZop<0xf9, (ins uimm8:$z), "resume">;
def SAVE   : MMIXXop<0xfa, (ins GPR:$x),   "save">;
def UNSAVE : MMIXZop<0xfb, (ins GPR:$z),   "unsave">;
def SYNC   : MMIXZop<0xfc, (ins uimm8:$z), "sync">;

/// floating point
class FLP3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

class FLP3plain<bits<8> opcode, string opname>
    : FLP3op<opcode, (ins GPR:$y, GPR:$z), opname> {
}

class FLP2p5op<bits<8> opcode, string opname>
    : FLP3op<opcode, (ins float_mode:$y, GPR:$z), opname> {
}

multiclass FLP3multi<bits<8> opcode, string opname> {
  def _R : FLP3op<opcode, (ins float_mode:$y, GPR:$z), opname>;
  def _I : FLP3op<!add(opcode, 1), (ins float_mode:$y, uimm8:$z), opname>;
}

def FCMP   : FLP3plain<0x01, "fcmp">;
def FUN    : FLP3plain<0x02, "fun">;
def FEQL   : FLP3plain<0x03, "feql">;
def FADD   : FLP3plain<0x04, "fadd">;
def FSUB   : FLP3plain<0x06, "fsub">;
def FMUL   : FLP3plain<0x10, "fmul">;
def FCMPE  : FLP3plain<0x11, "fcmpe">;
def FUNE   : FLP3plain<0x12, "fune">;
def FEQLE  : FLP3plain<0x13, "feqle">;
def FDIV   : FLP3plain<0x14, "fdiv">;
def FREM   : FLP3plain<0x16, "frem">;

def FIX    : FLP2p5op<0x05, "fix">;
def FIXU   : FLP2p5op<0x07, "fixu">;
def FSQRT  : FLP2p5op<0x15, "fsqrt">;
def FINT   : FLP2p5op<0x17, "fint">;

defm FLOT   : FLP3multi<0x08, "flot">;
defm FLOTU  : FLP3multi<0x0a, "flotu">;
defm SFLOT  : FLP3multi<0x0c, "sflot">;
defm SFLOTU : FLP3multi<0x0e, "sflotu">;

/// ALUs
// 3 operand ALUs
class ALU3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass ALU3multi<bits<8> opcode, string opname> {
  def _R : ALU3op<opcode, (ins GPR:$y, GPR:$z), opname>;
  def _I : ALU3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z), opname>;
}

defm MUL    : ALU3multi<0x18, "mul">;
defm MULU   : ALU3multi<0x1a, "mulu">;
defm DIV    : ALU3multi<0x1c, "div">;
defm DIVU   : ALU3multi<0x1e, "divu">;
defm ADD    : ALU3multi<0x20, "add">;
defm ADDU   : ALU3multi<0x22, "addu">;
defm SUB    : ALU3multi<0x24, "sub">;
defm SUBU   : ALU3multi<0x26, "subu">;
// TODO: these should be 2ADDU, etc. Need more work in the asm parser
defm ADDU2  : ALU3multi<0x28, "addu2">;
defm ADDU4  : ALU3multi<0x2a, "addu4">;
defm ADDU8  : ALU3multi<0x2c, "addu8">;
defm ADDU16 : ALU3multi<0x2e, "addu16">;
defm CMP    : ALU3multi<0x30, "cmp">;
defm CMPU   : ALU3multi<0x32, "cmpu">;

def NEG_R   : ALU3op<0x34, (ins uimm8:$y, GPR:$z), "neg">;
def NEG_I   : ALU3op<0x35, (ins uimm8:$y, uimm8:$z), "neg">;
def NEGU_R  : ALU3op<0x36, (ins uimm8:$y, GPR:$z), "negu">;
def NEGU_I  : ALU3op<0x37, (ins uimm8:$y, uimm8:$z), "negu">;

defm SL     : ALU3multi<0x38, "sl">;
defm SLU    : ALU3multi<0x3a, "slu">;
defm SR     : ALU3multi<0x3c, "sr">;
defm SRU    : ALU3multi<0x3e, "sru">;

defm OR     : ALU3multi<0xc0, "or">;
defm ORN    : ALU3multi<0xc2, "orn">;
defm NOR    : ALU3multi<0xc4, "nor">;
defm XOR    : ALU3multi<0xc6, "xor">;
defm AND    : ALU3multi<0xc8, "and">;
defm ANDN   : ALU3multi<0xca, "andn">;
defm NAND   : ALU3multi<0xcc, "nand">;
defm NXOR   : ALU3multi<0xce, "nxor">;

defm BDIF   : ALU3multi<0xd0, "bdif">;
defm WDIF   : ALU3multi<0xd2, "wdif">;
defm TDIF   : ALU3multi<0xd4, "tdif">;
defm ODIF   : ALU3multi<0xd6, "odif">;
defm MUX    : ALU3multi<0xd8, "mux">;
defm SADD   : ALU3multi<0xda, "sadd">;
defm MOR    : ALU3multi<0xdc, "mor">;
defm MXOR   : ALU3multi<0xde, "mxor">;

/// set instructions
// conditional set
let Constraints = "$F = $x" in
class CONDSET3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass CONDSET3multi<bits<8> opcode, string opname> {
  def _R : CONDSET3op<opcode, (ins GPR:$y, GPR:$z, GPR:$F), opname>;
  def _I : CONDSET3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z, GPR:$F), opname>;
}

defm CSN  : CONDSET3multi<0x60, "csn">;
defm CSZ  : CONDSET3multi<0x62, "csz">;
defm CSP  : CONDSET3multi<0x64, "csp">;
defm CSOD : CONDSET3multi<0x66, "csod">;
defm CSNN : CONDSET3multi<0x68, "csnn">;
defm CSNZ : CONDSET3multi<0x6a, "csnz">;
defm CSNP : CONDSET3multi<0x6c, "csnp">;
defm CSEV : CONDSET3multi<0x6e, "csev">;

defm ZSN  : CONDSET3multi<0x70, "zsn">;
defm ZSZ  : CONDSET3multi<0x72, "zsz">;
defm ZSP  : CONDSET3multi<0x74, "zsp">;
defm ZSOD : CONDSET3multi<0x76, "zsod">;
defm ZSNN : CONDSET3multi<0x78, "zsnn">;
defm ZSNZ : CONDSET3multi<0x7a, "zsnz">;
defm ZSNP : CONDSET3multi<0x7c, "zsnp">;
defm ZSEV : CONDSET3multi<0x7e, "zsev">;

/// directives
class DI3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs), ins, opname> {
}

multiclass DI3multi<bits<8> opcode, string opname> {
  def _R : DI3op<opcode, (ins uimm8:$x, GPR:$y, GPR:$z), opname>;
  def _I : DI3op<!add(opcode, 1), (ins uimm8:$x, GPR:$y, uimm8:$z), opname>;
}

defm PRELD  : DI3multi<0x9a, "preld">;
defm PREGO  : DI3multi<0x9c, "prego">;
defm SYNCD  : DI3multi<0xb8, "syncd">;
defm PREST  : DI3multi<0xba, "prest">;
defm SYNCID : DI3multi<0xbc, "syncid">;

// 'Wyde' instructions get their own parent class because of label operand
class Wyde2op<bits<8> opcode, string opname, dag ins>
    : MMIX2op<opcode, (outs GPR:$x), ins, opname>;

def SETH  : Wyde2op<0xe0, "seth", (ins h_imm:$yz)>;
def SETMH : Wyde2op<0xe1, "setmh", (ins mh_imm:$yz)>;
def SETML : Wyde2op<0xe2, "setml", (ins ml_imm:$yz)>;
def SETL  : Wyde2op<0xe3, "setl", (ins l_imm:$yz)>;

def INCH  : Wyde2op<0xe4, "inch", (ins h_imm:$yz)>;
def INCMH : Wyde2op<0xe5, "incmh", (ins mh_imm:$yz)>;
def INCML : Wyde2op<0xe6, "incml", (ins ml_imm:$yz)>;
def INCL  : Wyde2op<0xe7, "incl", (ins l_imm:$yz)>;

def ORH   : Wyde2op<0xe8, "orh", (ins h_imm:$yz)>;
def ORMH  : Wyde2op<0xe9, "ormh", (ins mh_imm:$yz)>;
def ORML  : Wyde2op<0xea, "orml", (ins ml_imm:$yz)>;
def ORL   : Wyde2op<0xeb, "orl", (ins l_imm:$yz)>;

def ANDH  : Wyde2op<0xec, "andh", (ins h_imm:$yz)>;
def ANDMH : Wyde2op<0xed, "andmh", (ins mh_imm:$yz)>;
def ANDML : Wyde2op<0xee, "andml", (ins ml_imm:$yz)>;
def ANDL  : Wyde2op<0xef, "andl", (ins l_imm:$yz)>;

/// control flow
let isCall = 1, mayLoad = 1 in
def PUSHJ_F : MMIX2op<0xf2, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;
let isCall = 1, mayLoad = 1 in
def PUSHJ_B : MMIX2op<0xf3, (outs), (ins GPR:$x, branch_imm:$yz), "pushj">;

let isCall = 1, mayLoad = 1 in
def PUSHGO_R : MMIX3op<0xbe, (outs), (ins GPR:$x, GPR:$y, GPR:$z), "pushgo">;
let isCall = 1, mayLoad = 1 in
def PUSHGO_I : MMIX3op<0xbf, (outs), (ins GPR:$x, GPR:$y, uimm8:$z), "pushgo">;

let isCall = 1, mayLoad = 0 in
def GO_R : MMIX3op<0x9e, (outs), (ins GPR:$x, GPR:$y, GPR:$z), "go">;
let isCall = 1, mayLoad = 0 in
def GO_I : MMIX3op<0x9f, (outs), (ins GPR:$x, GPR:$y, uimm8:$z), "go">;


class BR2op<bits<8> opcode, string opname> :
    MMIX2op<opcode, (outs), (ins GPR:$x, branch_imm:$yz), opname>;

let isCall = 1, mayLoad = 1 in
multiclass BR2multi<bits<8> opcode, string opname> {
  def _F : BR2op<opcode, opname>;
  def _B : BR2op<!add(opcode, 1), opname>;
  def P#NAME#_F : BR2op<!add(opcode, 0x10), "p" # opname>;
  def P#NAME#_B : BR2op<!add(opcode, 0x11), "p" # opname>;
}

defm BN  : BR2multi<0x40, "bn">;
defm BZ  : BR2multi<0x42, "bz">;
defm BP  : BR2multi<0x44, "bp">;
defm BOD : BR2multi<0x46, "bod">;
defm BNN : BR2multi<0x48, "bnn">;
defm BNZ : BR2multi<0x4a, "bnz">;
defm BNP : BR2multi<0x4c, "bnp">;
defm BEV : BR2multi<0x4e, "bev">;

let isReturn = 1, mayStore = 1 in
def POP : MMIX2op<0xf8, (outs), (ins uimm8:$x, uimm16:$yz), "pop">;

def JMP_F : MMIX1op<0xf0, (ins jmp_imm:$xyz), "jmp">;
def JMP_B : MMIX1op<0xf1, (ins jmp_imm:$xyz), "jmp">;

/// put and get
def PUT : MMIX2opNoY<0xf6, (outs SR:$x), (ins GPR:$z), "put">;
def GET : MMIX2opNoY<0xfe, (outs GPR:$x), (ins SR:$z), "get">;

/// load and store
let mayLoad = 1, mayStore = 1 in
def CSWAP_R : MMIX3op<0x94, (outs), (ins GPR:$x, GPR:$y, GPR:$z), "cswap">;
let mayLoad = 1, mayStore = 1 in
def CSWAP_I : MMIX3op<0x95, (outs), (ins GPR:$x, GPR:$y, uimm8:$z), "cswap">;

// TODO: Co-opting the branch_imm operator, as it does exactly what we want.
// We should rename it into something a bit more general or make the backend code
// a bit more general, and create a geta_imm operator or some-such.
let mayLoad = 1 in
def GETA_F : MMIX2op<0xf4, (outs GPR:$x), (ins branch_imm:$yz), "geta">;
let mayLoad = 1 in
def GETA_B : MMIX2op<0xf5, (outs GPR:$x), (ins branch_imm:$yz), "geta">;

// signed and unsigned extended loads
let mayLoad = 1 in
class LD3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs GPR:$x), ins, opname> {
}

multiclass LD3multi<bits<8> opcode, string opname> {
  def _R : LD3op<opcode, (ins GPR:$y, GPR:$z), opname>;
  def _I : LD3op<!add(opcode, 1), (ins GPR:$y, uimm8:$z), opname>;
}

defm LDB   : LD3multi<0x80, "ldb">;
defm LDBU  : LD3multi<0x82, "ldbu">;
defm LDW   : LD3multi<0x84, "ldw">;
defm LDWU  : LD3multi<0x86, "ldwu">;
defm LDT   : LD3multi<0x88, "ldt">;
defm LDTU  : LD3multi<0x8a, "ldtu">;
defm LDO   : LD3multi<0x8c, "ldo">;
defm LDOU  : LD3multi<0x8e, "ldou">;
defm LDSF  : LD3multi<0x90, "ldsf">;
defm LDHT  : LD3multi<0x92, "ldht">;
defm LDUNC : LD3multi<0x96, "ldunc">;
defm LDVTS : LD3multi<0x98, "ldvts">;

// store
let mayStore = 1 in
class ST3op<bits<8> opcode, dag ins, string opname>
    : MMIX3op<opcode, (outs), ins, opname> {
}

multiclass ST3multi<bits<8> opcode, string opname> {
  def _R : ST3op<opcode, (ins GPR:$x, GPR:$y, GPR:$z), opname>;
  def _I : ST3op<!add(opcode, 1), (ins GPR:$x, GPR:$y, uimm8:$z), opname>;
}

defm STB   : ST3multi<0xa0, "stb">;
defm STBU  : ST3multi<0xa2, "stbu">;
defm STW   : ST3multi<0xa4, "stw">;
defm STWU  : ST3multi<0xa6, "stwu">;
defm STT   : ST3multi<0xa8, "stt">;
defm STTU  : ST3multi<0xaa, "sttu">;
defm STO   : ST3multi<0xac, "sto">;
defm STOU  : ST3multi<0xae, "stou">;
defm STSF  : ST3multi<0xb0, "stsf">;
defm STHT  : ST3multi<0xb2, "stht">;
defm STCO  : ST3multi<0xb4, "stco">;
defm STUNC : ST3multi<0xb6, "stunc">;


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
def LDA : Pseudo<(outs GPR:$x), (ins imm64:$yz), []>;

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
defm : AluPat<and, "AND">;

/// setcc/selectcc
class SelectPat<PatFrag CondOp, CONDSET3op CondInst, ALU3op CmpInst>
    : Pat<(select (i64 (CondOp GPR:$lhs, GPR:$rhs)), GPR:$T, GPR:$F),
          (CondInst (CmpInst GPR:$lhs, GPR:$rhs), GPR:$T, GPR:$F)>;

def : SelectPat<seteq, CSZ_R,  CMP_R>;
def : SelectPat<setgt, CSP_R,  CMP_R>;
def : SelectPat<setge, CSNN_R, CMP_R>;
def : SelectPat<setlt, CSN_R,  CMP_R>;
def : SelectPat<setle, CSNP_R, CMP_R>;
def : SelectPat<setne, CSNZ_R, CMP_R>;

def : SelectPat<setueq, CSZ_R,  CMPU_R>;
def : SelectPat<setugt, CSP_R,  CMPU_R>;
def : SelectPat<setuge, CSNN_R, CMPU_R>;
def : SelectPat<setult, CSN_R,  CMPU_R>;
def : SelectPat<setule, CSNP_R, CMPU_R>;
def : SelectPat<setune, CSNZ_R, CMPU_R>;


def : Pat<(select GPR:$cond, GPR:$T, GPR:$F),
          (CSP_R  GPR:$cond, GPR:$T, GPR:$F)>;

def : Pat<(select (i64 (seteq GPR:$lhs, 0)), GPR:$T, GPR:$F),
          (CSZ_R  GPR:$lhs, GPR:$T, GPR:$F)>;
def : Pat<(select (i64 (setne GPR:$lhs, 0)), GPR:$T, GPR:$F),
          (CSNZ_R GPR:$lhs, GPR:$T, GPR:$F)>;

def : Pat<(seteq GPR:$lhs, GPR:$rhs),
          (CMP_R GPR:$lhs, GPR:$rhs)>;


/// Branches, jumps and returns

// Match `(brcond (CondOp ..), ..)` and lower to the appropriate MMIX branch
// pattern.
class BccPat<PatFrag CondOp, BR2op BrInst, ALU3op AluInst>
    : Pat<(brcond (i64 (CondOp GPR:$y, GPR:$z)), bb:$yz),
          (BrInst (AluInst GPR:$y, GPR:$z), branch_imm:$yz)>;

def : BccPat<seteq,  BZ_F,  CMP_R>;
def : BccPat<setgt,  BP_F,  CMP_R>;
def : BccPat<setge,  BNN_F, CMP_R>;
def : BccPat<setlt,  BN_F,  CMP_R>;
def : BccPat<setle,  BNP_F, CMP_R>;
def : BccPat<setne,  BNZ_F, CMP_R>;

def : BccPat<setueq, BZ_F,  CMPU_R>;
def : BccPat<setugt, BP_F,  CMPU_R>;
def : BccPat<setuge, BNN_F, CMPU_R>;
def : BccPat<setult, BN_F,  CMPU_R>;
def : BccPat<setule, BNP_F, CMPU_R>;
def : BccPat<setune, BNZ_F, CMPU_R>;

// An extra pattern is needed for a brcond without a setcc (i.e. where the
// condition was calculated elsewhere).
def : Pat<(brcond GPR:$cond, bb:$addr), (BNZ_F GPR:$cond, bb:$addr)>;

let isBarrier = 1, isBranch = 1, isTerminator = 1 in
def PseudoBR : Pseudo<(outs), (ins jmp_imm:$xyz), [(br bb:$xyz)]>,
               PseudoInstExpansion<(JMP_F jmp_imm:$xyz)>;

let isCall = 1, Defs=[rJ] in
def PseudoCALL : Pseudo<(outs), (ins GPR:$x), [(Call GPR:$x)]>,
                 PseudoInstExpansion<(PUSHGO_I r0, GPR:$x, 0)>;

let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : Pseudo<(outs), (ins), [(RetFlag)]>,
                PseudoInstExpansion<(POP 0, 0)>;


/// Addressing modes.
// Necessary because a frameindex can't be matched directly in a pattern.
def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

/// Predicates
def IsOrAdd: PatFrag<(ops node:$A, node:$B), (or node:$A, node:$B), [{
  return isOrEquivalentToAdd(N);
}]>;


/// FrameIndex calculations
def : Pat<(add (i64 AddrFI:$y), uimm8:$z),
          (ADD_I (i64 AddrFI:$y), uimm8:$z)>;
def : Pat<(IsOrAdd (i64 AddrFI:$y), uimm8:$z),
          (ADD_I (i64 AddrFI:$y), uimm8:$z)>;


/// load and store
// signed and unsigned extended loads
multiclass LdPat<PatFrag LoadOp, LD3op Inst> {
  def : Pat<(LoadOp GPR:$y), (Inst GPR:$y, 0)>;
  def : Pat<(LoadOp (add GPR:$y, uimm8:$z)),
            (Inst GPR:$y, uimm8:$z)>;
  def : Pat<(LoadOp (add AddrFI:$y, uimm8:$z)),
            (Inst AddrFI:$y, uimm8:$z)>;
  def : Pat<(LoadOp (IsOrAdd AddrFI:$y, uimm8:$z)),
            (Inst AddrFI:$y, uimm8:$z)>;
  def : Pat<(LoadOp AddrFI:$y), (Inst AddrFI:$y, 0)>;
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
  def : Pat<(StoreOp GPR:$x, AddrFI:$y), (Inst GPR:$x, AddrFI:$y, 0)>;
  def : Pat<(StoreOp GPR:$x, (add AddrFI:$y, uimm8:$z)),
            (Inst GPR:$x, AddrFI:$y, uimm8:$z)>;
  def : Pat<(StoreOp GPR:$x, (IsOrAdd AddrFI:$y, uimm8:$z)),
            (Inst GPR:$x, AddrFI:$y, uimm8:$z)>;
}

defm : StPat<truncstorei8, STB_I>;
defm : StPat<truncstorei16, STW_I>;
defm : StPat<truncstorei32, STT_I>;
defm : StPat<store, STO_I>;


/// Other pseudo-instructions
// Pessimistically assume the stack pointer will be clobbered
let Defs = [r254], Uses = [r254] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
                              [(CallSeqStart timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
                              [(CallSeqEnd timm:$amt1, timm:$amt2)]>;
}
