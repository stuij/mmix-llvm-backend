//===-- MMIXInstPrinter.cpp - Convert MMIX MCInst to asm syntax ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class prints an MMIX MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "MMIXInstPrinter.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

// Include the auto-generated portion of the assembly writer.
#include "MMIXGenAsmWriter.inc"

void MMIXInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                StringRef Annot, const MCSubtargetInfo &STI) {
  printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void MMIXInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << getRegisterName(RegNo);
}

void MMIXInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O, const char *Modifier) {
  assert((Modifier == 0 || Modifier[0] == 0) && "No modifiers supported");
  const MCOperand &MO = MI->getOperand(OpNo);

  if (MO.isReg()) {
    printRegName(O, MO.getReg());
    return;
  }

  if (MO.isImm()) {
    O << formatHex(MO.getImm());
    return;
  }

  assert(MO.isExpr() && "Unknown operand kind in printOperand");
  MO.getExpr()->print(O, &MAI);
}

void MMIXInstPrinter::printBranchImm(const MCInst *MI, unsigned OpNum,
                                     raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNum);
  unsigned Opcode = MI->getOpcode();

  // If the label has already been resolved to an immediate offset (say, when
  // we're running the disassembler), just print the immediate.
  if (Op.isImm()) {
    bool back;
    switch(Opcode) {
    case MMIX::PUSHJ_B:
      back = true;
      break;
    default:
      back = false;
    }

    auto Val = Op.getImm() << 2;
    if(back) {
      Val -= 262144;
    }
    O << formatHex(Val);
    return;
  }

  // Otherwise, just print the expression.
  MI->getOperand(OpNum).getExpr()->print(O, &MAI);
}

void MMIXInstPrinter::printJumpImm(const MCInst *MI, unsigned OpNum,
                                     raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNum);
  unsigned Opcode = MI->getOpcode();

  // If the label has already been resolved to an immediate offset (say, when
  // we're running the disassembler), just print the immediate.
  if (Op.isImm()) {
    bool back = false;
    if (Opcode == MMIX::JMP_B)
      back = true;

    auto Val = Op.getImm() << 2;
    if(back) {
      Val -= 67108864;
    }
    O << formatHex(Val);
    return;
  }

  // Otherwise, just print the expression.
  MI->getOperand(OpNum).getExpr()->print(O, &MAI);
}
