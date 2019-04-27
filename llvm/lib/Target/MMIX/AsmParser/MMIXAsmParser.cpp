//===-- MMIXAsmParser.cpp - Parse MMIX assembly to MCInst instructions --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

namespace {
struct MMIXOperand;

class MMIXAsmParser : public MCTargetAsmParser {
  SMLoc getLoc() const { return getParser().getTok().getLoc(); }

  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;

  bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc) override;

  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

  bool ParseDirective(AsmToken DirectiveID) override;

// Auto-generated instruction matching functions
#define GET_ASSEMBLER_HEADER
#include "MMIXGenAsmMatcher.inc"

  OperandMatchResultTy parseImmediate(OperandVector &Operands);
  OperandMatchResultTy parseRegister(OperandVector &Operands);

  bool parseOperand(OperandVector &Operands);

public:
  enum MMIXMatchResultTy {
    Match_Dummy = FIRST_TARGET_MATCH_RESULT_TY,
#define GET_OPERAND_DIAGNOSTIC_TYPES
#include "MMIXGenAsmMatcher.inc"
#undef GET_OPERAND_DIAGNOSTIC_TYPES
  };

  MMIXAsmParser(const MCSubtargetInfo &STI, MCAsmParser &Parser,
                const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, STI, MII) {
    setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
  }
};

/// MMIXOperand - Instances of this class represent a parsed machine
/// instruction
struct MMIXOperand : public MCParsedAsmOperand {

  enum KindTy {
    Token,
    Register,
    Immediate,
  } Kind;

  struct RegOp {
    unsigned RegNum;
  };

  struct ImmOp {
    const MCExpr *Val;
  };

  SMLoc StartLoc, EndLoc;
  union {
    StringRef Tok;
    RegOp Reg;
    ImmOp Imm;
  };

  MMIXOperand(KindTy K) : MCParsedAsmOperand(), Kind(K) {}

public:
  MMIXOperand(const MMIXOperand &o) : MCParsedAsmOperand() {
    Kind = o.Kind;
    StartLoc = o.StartLoc;
    EndLoc = o.EndLoc;
    switch (Kind) {
    case Register:
      Reg = o.Reg;
      break;
    case Immediate:
      Imm = o.Imm;
      break;
    case Token:
      Tok = o.Tok;
      break;
    }
  }

  bool isToken() const override { return Kind == Token; }
  bool isReg() const override { return Kind == Register; }
  bool isImm() const override { return Kind == Immediate; }
  bool isMem() const override { return false; }

  bool isConstantImm() const {
    return isImm() && dyn_cast<MCConstantExpr>(getImm());
  }

  int64_t getConstantImm() const {
    const MCExpr *Val = getImm();
    return static_cast<const MCConstantExpr *>(Val)->getValue();
  }

  bool isAcceptableSymbolRef(const MCExpr *Expr) const {

    // It's a simple symbol reference or constant with no addend.
    if (isa<MCConstantExpr>(Expr) || isa<MCSymbolRefExpr>(Expr))
      return true;

    const MCBinaryExpr *BE = dyn_cast<MCBinaryExpr>(Expr);
    if (!BE)
      return false;

    if (!isa<MCSymbolRefExpr>(BE->getLHS()))
      return false;

    if (BE->getOpcode() != MCBinaryExpr::Add &&
        BE->getOpcode() != MCBinaryExpr::Sub)
      return false;

    // We are able to support the subtraction of two symbol references
    if (BE->getOpcode() == MCBinaryExpr::Sub &&
        isa<MCSymbolRefExpr>(BE->getRHS()))
      return true;

    // See if the addend is is a constant, otherwise there's more going
    // on here than we can deal with.
    auto AddendExpr = dyn_cast<MCConstantExpr>(BE->getRHS());
    if (!AddendExpr)
      return false;

    // It's some symbol reference + a constant addend
    return true;
  }

  bool isUImm8() const {
    return (isConstantImm() && isUInt<8>(getConstantImm()));
  }

  bool isUImm16() const {
    return (isConstantImm() && isUInt<16>(getConstantImm()));
  }

  bool isLabelImm16() const {
    if(isConstantImm()) {
      return isUInt<16>(getConstantImm());
    }
    return isImm() && isAcceptableSymbolRef(getImm());
  }

  bool isWydeH() const {
    return isLabelImm16();
  }

  bool isWydeMH() const {
    return isLabelImm16();
  }

  bool isWydeML() const {
    return isLabelImm16();
  }

  bool isWydeL() const {
    return isLabelImm16();
  }

  bool isBranchImm16() const {
    return isImm() && isAcceptableSymbolRef(getImm());
  }

  bool isBranchImm24() const {
    return isImm() && isAcceptableSymbolRef(getImm());
  }

  /// getStartLoc - Gets location of the first token of this operand
  SMLoc getStartLoc() const override { return StartLoc; }
  /// getEndLoc - Gets location of the last token of this operand
  SMLoc getEndLoc() const override { return EndLoc; }

  unsigned getReg() const override {
    assert(Kind == Register && "Invalid type access!");
    return Reg.RegNum;
  }

  const MCExpr *getImm() const {
    assert(Kind == Immediate && "Invalid type access!");
    return Imm.Val;
  }

  StringRef getToken() const {
    assert(Kind == Token && "Invalid type access!");
    return Tok;
  }

  void print(raw_ostream &OS) const override {
    switch (Kind) {
    case Immediate:
      OS << *getImm();
      break;
    case Register:
      OS << "<register x";
      OS << getReg() << ">";
      break;
    case Token:
      OS << "'" << getToken() << "'";
      break;
    }
  }

  static std::unique_ptr<MMIXOperand> createToken(StringRef Str, SMLoc S) {
    auto Op = std::make_unique<MMIXOperand>(Token);
    Op->Tok = Str;
    Op->StartLoc = S;
    Op->EndLoc = S;
    return Op;
  }

  static std::unique_ptr<MMIXOperand> createReg(unsigned RegNo, SMLoc S,
                                                SMLoc E) {
    auto Op = std::make_unique<MMIXOperand>(Register);
    Op->Reg.RegNum = RegNo;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  static std::unique_ptr<MMIXOperand> createImm(const MCExpr *Val, SMLoc S,
                                                SMLoc E) {
    auto Op = std::make_unique<MMIXOperand>(Immediate);
    Op->Imm.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    assert(Expr && "Expr shouldn't be null!");
    if (auto *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  // Used by the TableGen Code
  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    Inst.addOperand(MCOperand::createReg(getReg()));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getImm());
  }
};
} // end anonymous namespace.

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "MMIXGenAsmMatcher.inc"

bool MMIXAsmParser::MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                            OperandVector &Operands,
                                            MCStreamer &Out,
                                            uint64_t &ErrorInfo,
                                            bool MatchingInlineAsm) {
  MCInst Inst;
  SMLoc ErrorLoc;

  switch (MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm)) {
  default:
    break;
  case Match_Success:
    Inst.setLoc(IDLoc);
    Out.EmitInstruction(Inst, getSTI());
    return false;
  case Match_MissingFeature:
    return Error(IDLoc, "instruction use requires an option to be enabled");
  case Match_MnemonicFail:
    return Error(IDLoc, "unrecognized instruction mnemonic");
  case Match_InvalidOperand:
    ErrorLoc = IDLoc;
    if (ErrorInfo != ~0U) {
      if (ErrorInfo >= Operands.size())
        return Error(ErrorLoc, "too few operands for instruction");

      ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorLoc == SMLoc())
        ErrorLoc = IDLoc;
    }
    return Error(ErrorLoc, "invalid operand for instruction");
  case Match_InvalidUImm8:
    ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
    return Error(ErrorLoc,
                 "immediate must be an integer in the range [0, 0xff]");
  case Match_InvalidUImm16:
    ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
    return Error(ErrorLoc,
                 "immediate must be an integer in the range [0, 0xffff]");
  case Match_InvalidWyde:
    ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
    return Error(ErrorLoc,
                 "operand must be either a label "
                 "or an integer in the range [0, 0xffff]");
  case Match_InvalidBranchImm16:
    ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
    return Error(ErrorLoc,
                 "branch operand must be a label");
  case Match_InvalidBranchImm24:
    ErrorLoc = ((MMIXOperand &)*Operands[ErrorInfo]).getStartLoc();
    return Error(ErrorLoc,
                 "branch operand must be a label");
  }

  llvm_unreachable("Unknown match type detected!");
}

bool MMIXAsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                  SMLoc &EndLoc) {
  const AsmToken &Tok = getParser().getTok();
  StartLoc = Tok.getLoc();
  EndLoc = Tok.getEndLoc();
  RegNo = 0;
  StringRef Name = getLexer().getTok().getIdentifier();

  if (!MatchRegisterName(Name)) {
    getParser().Lex(); // Eat identifier token.
    return false;
  }

  return Error(StartLoc, "invalid register name");
}

OperandMatchResultTy MMIXAsmParser::parseRegister(OperandVector &Operands) {
  SMLoc S = getLoc();
  SMLoc E;

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_NoMatch;
  case AsmToken::Dollar:
    getLexer().Lex();
    assert(getLexer().getKind() == AsmToken::Integer && "This token isn't an integer!");
    StringRef Name(std::string("$") + getLexer().getTok().getString().str());
    unsigned RegNo = MatchRegisterName(Name);
    E = SMLoc::getFromPointer(getLoc().getPointer() - 1);
    if (RegNo == 0) {
      return MatchOperand_NoMatch;
    }
    Operands.push_back(MMIXOperand::createReg(RegNo, S, E));
    getLexer().Lex();
  }
  return MatchOperand_Success;
}

OperandMatchResultTy MMIXAsmParser::parseImmediate(OperandVector &Operands) {
  SMLoc S = getLoc();
  SMLoc E = SMLoc::getFromPointer(S.getPointer() - 1);
  const MCExpr *Res;

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_NoMatch;
  case AsmToken::LParen:
  case AsmToken::Minus:
  case AsmToken::Plus:
  case AsmToken::Integer:
  case AsmToken::String:
  case AsmToken::Identifier:
    if (getParser().parseExpression(Res))
      return MatchOperand_ParseFail;
    break;
  }

  Operands.push_back(MMIXOperand::createImm(Res, S, E));
  return MatchOperand_Success;
}

/// Looks at a token type and creates the relevant operand
/// from this information, adding to Operands.
/// If operand was parsed, returns false, else true.
bool MMIXAsmParser::parseOperand(OperandVector &Operands) {
  // Attempt to parse token as register
  if (parseRegister(Operands) == MatchOperand_Success)
    return false;

  // Attempt to parse token as an immediate
  if (parseImmediate(Operands) == MatchOperand_Success)
    return false;

  // Finally we have exhausted all options and must declare defeat.
  Error(getLoc(), "unknown operand");
  return true;
}

bool MMIXAsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                     StringRef Name, SMLoc NameLoc,
                                     OperandVector &Operands) {
  // First operand is token for instruction
  Operands.push_back(MMIXOperand::createToken(Name, NameLoc));

  // If there are no more operands, then finish
  if (getLexer().is(AsmToken::EndOfStatement))
    return false;

  // Parse first operand
  if (parseOperand(Operands))
    return true;

  // Parse until end of statement, consuming commas between operands
  while (getLexer().is(AsmToken::Comma)) {
    // Consume comma token
    getLexer().Lex();

    // Parse next operand
    if (parseOperand(Operands))
      return true;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getParser().Lex(); // Consume the EndOfStatement.
  return false;
}

bool MMIXAsmParser::ParseDirective(AsmToken DirectiveID) { return true; }

extern "C" void LLVMInitializeMMIXAsmParser() {
  RegisterMCAsmParser<MMIXAsmParser> X(getTheMMIXTarget());
}
