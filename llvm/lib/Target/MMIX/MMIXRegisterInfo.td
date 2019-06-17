//===- MMIXRegisterInfo.td - MMIX Register defs ------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//  Declarations that describe the MMIX register file
//===----------------------------------------------------------------------===//

let Namespace = "MMIX" in {
class MMIXReg<bits<8> Enc, string n> : Register<n> {
  let HWEncoding{7-0} = Enc;
}
} // Namespace = "MMIX"


/// Integer registers
foreach i = 0-255 in {
  def r#i : MMIXReg<i, "$"#i>, DwarfRegNum<[i]>;
}

// The order of registers represents the preferred allocation sequence.
// Registers are naturally listed in the order caller-save, callee-save, specials.
// General purpose register class
def GPR : RegisterClass<"MMIX", [i64], 32, (add
    (sequence "r%u", 0, 255)
  )> {
}


/// Special registers
def rA : MMIXReg<21, "rA">, DwarfRegNum<[0x100]>; // arithmetic status register
def rB : MMIXReg< 0, "rB">, DwarfRegNum<[0x101]>; // bootstrap register
def rC : MMIXReg< 8, "rC">, DwarfRegNum<[0x102]>; // continuation register
def rD : MMIXReg< 1, "rD">, DwarfRegNum<[0x103]>; // dividend register
def rE : MMIXReg< 2, "rE">, DwarfRegNum<[0x104]>; // epsilon register
def rF : MMIXReg<22, "rF">, DwarfRegNum<[0x105]>; // failure location register
def rG : MMIXReg<19, "rG">, DwarfRegNum<[0x106]>; // global threshold register
def rH : MMIXReg< 3, "rH">, DwarfRegNum<[0x107]>; // himult register
def rI : MMIXReg<12, "rI">, DwarfRegNum<[0x108]>; // interval counter
def rJ : MMIXReg< 4, "rJ">, DwarfRegNum<[0x109]>; // return-jump register
def rK : MMIXReg<15, "rK">, DwarfRegNum<[0x10a]>; // interrupt mask register
def rL : MMIXReg<20, "rL">, DwarfRegNum<[0x10b]>; // local threshold register
def rM : MMIXReg< 5, "rM">, DwarfRegNum<[0x10c]>; // multiplex mask register
def rN : MMIXReg< 9, "rN">, DwarfRegNum<[0x10d]>; // serial number
def rO : MMIXReg<10, "rO">, DwarfRegNum<[0x10e]>; // register stack offset
def rP : MMIXReg<23, "rP">, DwarfRegNum<[0x10f]>; // prediction register5B
def rQ : MMIXReg<16, "rQ">, DwarfRegNum<[0x110]>; // interrupt request register
def rR : MMIXReg< 6, "rR">, DwarfRegNum<[0x111]>; // remainder register
def rS : MMIXReg<11, "rS">, DwarfRegNum<[0x112]>; // register stack pointer
def rT : MMIXReg<13, "rT">, DwarfRegNum<[0x113]>; // trap address register
def rU : MMIXReg<17, "rU">, DwarfRegNum<[0x114]>; // usage counter
def rV : MMIXReg<18, "rV">, DwarfRegNum<[0x115]>; // virtual translation register
def rW : MMIXReg<24, "rW">, DwarfRegNum<[0x116]>; // where-interrupted register (trip)
def rX : MMIXReg<25, "rX">, DwarfRegNum<[0x117]>; // execution register (trip)
def rY : MMIXReg<26, "rY">, DwarfRegNum<[0x118]>; // Y operand (trip)
def rZ : MMIXReg<27, "rZ">, DwarfRegNum<[0x119]>; // Z operand (trip)
def rBB : MMIXReg< 7, "rBB">, DwarfRegNum<[0x11a]>; // bootstrap register (trap)
def rTT : MMIXReg<14, "rTT">, DwarfRegNum<[0x11b]>; // dynamic trap address register
def rWW : MMIXReg<28, "rWW">, DwarfRegNum<[0x11c]>; // where-interrupted register (trap)
def rXX : MMIXReg<29, "rXX">, DwarfRegNum<[0x11d]>; // execution register (trap)
def rYY : MMIXReg<30, "rYY">, DwarfRegNum<[0x11e]>; // Y operand (trap)
def rZZ : MMIXReg<31, "rZZ">, DwarfRegNum<[0x11f]>; // Z operand (trap)

def SR : RegisterClass<"MMIX", [i64], 32, (add
    rA, rB, rC, rD, rE, rF, rG, rH, rI, rJ, rK, rL, rM, rN, rO, rP, rQ, rR, rS,
    rT, rU, rV, rW, rX, rY, rZ, rBB, rTT, rWW, rXX, rYY, rZZ
  )> {
}
