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

// Integer registers
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
