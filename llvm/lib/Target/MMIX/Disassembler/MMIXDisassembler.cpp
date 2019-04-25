//===-- MMIXDisassembler.cpp - Disassembler for MMIX --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the MMIXDisassembler class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/MMIXMCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "mmix-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {
class MMIXDisassembler : public MCDisassembler {

public:
  MMIXDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
} // end anonymous namespace

static MCDisassembler *createMMIXDisassembler(const Target &T,
                                              const MCSubtargetInfo &STI,
                                              MCContext &Ctx) {
  return new MMIXDisassembler(STI, Ctx);
}

extern "C" void LLVMInitializeMMIXDisassembler() {
  // Register the disassembler for each target.
  TargetRegistry::RegisterMCDisassembler(getTheMMIXTarget(),
                                         createMMIXDisassembler);
}

static const unsigned GPRDecoderTable[] = {
  MMIX::r0,   MMIX::r1,   MMIX::r2,   MMIX::r3,   MMIX::r4,
  MMIX::r5,   MMIX::r6,   MMIX::r7,   MMIX::r8,   MMIX::r9,
  MMIX::r10,  MMIX::r11,  MMIX::r12,  MMIX::r13,  MMIX::r14,
  MMIX::r15,  MMIX::r16,  MMIX::r17,  MMIX::r18,  MMIX::r19,
  MMIX::r20,  MMIX::r21,  MMIX::r22,  MMIX::r23,  MMIX::r24,
  MMIX::r25,  MMIX::r26,  MMIX::r27,  MMIX::r28,  MMIX::r29,
  MMIX::r30,  MMIX::r31,  MMIX::r32,  MMIX::r33,  MMIX::r34,
  MMIX::r35,  MMIX::r36,  MMIX::r37,  MMIX::r38,  MMIX::r39,
  MMIX::r40,  MMIX::r41,  MMIX::r42,  MMIX::r43,  MMIX::r44,
  MMIX::r45,  MMIX::r46,  MMIX::r47,  MMIX::r48,  MMIX::r49,
  MMIX::r50,  MMIX::r51,  MMIX::r52,  MMIX::r53,  MMIX::r54,
  MMIX::r55,  MMIX::r56,  MMIX::r57,  MMIX::r58,  MMIX::r59,
  MMIX::r60,  MMIX::r61,  MMIX::r62,  MMIX::r63,  MMIX::r64,
  MMIX::r65,  MMIX::r66,  MMIX::r67,  MMIX::r68,  MMIX::r69,
  MMIX::r70,  MMIX::r71,  MMIX::r72,  MMIX::r73,  MMIX::r74,
  MMIX::r75,  MMIX::r76,  MMIX::r77,  MMIX::r78,  MMIX::r79,
  MMIX::r80,  MMIX::r81,  MMIX::r82,  MMIX::r83,  MMIX::r84,
  MMIX::r85,  MMIX::r86,  MMIX::r87,  MMIX::r88,  MMIX::r89,
  MMIX::r90,  MMIX::r91,  MMIX::r92,  MMIX::r93,  MMIX::r94,
  MMIX::r95,  MMIX::r96,  MMIX::r97,  MMIX::r98,  MMIX::r99,

  MMIX::r100, MMIX::r101, MMIX::r102, MMIX::r103, MMIX::r104,
  MMIX::r105, MMIX::r106, MMIX::r107, MMIX::r108, MMIX::r109,
  MMIX::r110, MMIX::r111, MMIX::r112, MMIX::r113, MMIX::r114,
  MMIX::r115, MMIX::r116, MMIX::r117, MMIX::r118, MMIX::r119,
  MMIX::r120, MMIX::r121, MMIX::r122, MMIX::r123, MMIX::r124,
  MMIX::r125, MMIX::r126, MMIX::r127, MMIX::r128, MMIX::r129,
  MMIX::r130, MMIX::r131, MMIX::r132, MMIX::r133, MMIX::r134,
  MMIX::r135, MMIX::r136, MMIX::r137, MMIX::r138, MMIX::r139,
  MMIX::r140, MMIX::r141, MMIX::r142, MMIX::r143, MMIX::r144,
  MMIX::r145, MMIX::r146, MMIX::r147, MMIX::r148, MMIX::r149,
  MMIX::r150, MMIX::r151, MMIX::r152, MMIX::r153, MMIX::r154,
  MMIX::r155, MMIX::r156, MMIX::r157, MMIX::r158, MMIX::r159,
  MMIX::r160, MMIX::r161, MMIX::r162, MMIX::r163, MMIX::r164,
  MMIX::r165, MMIX::r166, MMIX::r167, MMIX::r168, MMIX::r169,
  MMIX::r170, MMIX::r171, MMIX::r172, MMIX::r173, MMIX::r174,
  MMIX::r175, MMIX::r176, MMIX::r177, MMIX::r178, MMIX::r179,
  MMIX::r180, MMIX::r181, MMIX::r182, MMIX::r183, MMIX::r184,
  MMIX::r185, MMIX::r186, MMIX::r187, MMIX::r188, MMIX::r189,
  MMIX::r190, MMIX::r191, MMIX::r192, MMIX::r193, MMIX::r194,
  MMIX::r195, MMIX::r196, MMIX::r197, MMIX::r198, MMIX::r199,

  MMIX::r200, MMIX::r201, MMIX::r202, MMIX::r203, MMIX::r204,
  MMIX::r205, MMIX::r206, MMIX::r207, MMIX::r208, MMIX::r209,
  MMIX::r210, MMIX::r211, MMIX::r212, MMIX::r213, MMIX::r214,
  MMIX::r215, MMIX::r216, MMIX::r217, MMIX::r218, MMIX::r219,
  MMIX::r220, MMIX::r221, MMIX::r222, MMIX::r223, MMIX::r224,
  MMIX::r225, MMIX::r226, MMIX::r227, MMIX::r228, MMIX::r229,
  MMIX::r230, MMIX::r231, MMIX::r232, MMIX::r233, MMIX::r234,
  MMIX::r235, MMIX::r236, MMIX::r237, MMIX::r238, MMIX::r239,
  MMIX::r240, MMIX::r241, MMIX::r242, MMIX::r243, MMIX::r244,
  MMIX::r245, MMIX::r246, MMIX::r247, MMIX::r248, MMIX::r249,
  MMIX::r250, MMIX::r251, MMIX::r252, MMIX::r253, MMIX::r254,
  MMIX::r255
};

static DecodeStatus DecodeGPRRegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
   if (RegNo > sizeof(GPRDecoderTable))
     return MCDisassembler::Fail;

   // We must define our own mapping from RegNo to register identifier.
   // Accessing index RegNo in the register class will work in the case that
   // registers were added in ascending order, but not in general.
   unsigned Reg = GPRDecoderTable[RegNo];
   Inst.addOperand(MCOperand::createReg(Reg));
   return MCDisassembler::Success;
}

template <unsigned N>
static DecodeStatus decodeUImmOperand(MCInst &Inst, uint64_t Imm,
                                      int64_t Address, const void *Decoder) {
  assert(isUInt<N>(Imm) && "Invalid unsigned immediate");
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

#include "MMIXGenDisassemblerTables.inc"

DecodeStatus MMIXDisassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                              ArrayRef<uint8_t> Bytes,
                                              uint64_t Address,
                                              raw_ostream &OS,
                                              raw_ostream &CS) const {
  Size = 4;
  if (Bytes.size() < 4) {
    Size = 0;
    return MCDisassembler::Fail;
  }

  // Get the four bytes of the instruction.
  uint32_t Inst = support::endian::read32be(Bytes.data());

  return decodeInstruction(DecoderTableMMIX32, MI, Inst, Address, this, STI);
}
