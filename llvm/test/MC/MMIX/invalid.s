# RUN: not llvm-mc -triple mmix < %s 2>&1 | FileCheck %s


# ALU instructions

# Out of range immediates
# CHECK: :13: error: immediate must be an integer in the range [0, 0xff]
  add $0,$1,-1
# CHECK: :13: error: immediate must be an integer in the range [0, 0xff]
  add $3,$4,256

# Invalid mnemonics
# CHECK: :3: error: unrecognized instruction mnemonic
  addi $0,$1,1

# Invalid operand types
# CHECK: :7:  error: invalid operand for instruction
  add foo,$1,10
# CHECK: :7: error: invalid operand for instruction
  add 22,$1,$0

# Too many operands
# CHECK: :16: error: invalid operand for instruction
  add $0,$1,$2,$3

# Too few operands
# CHECK: :3: error: too few operands for instruction
  add $0,$1


# Wyde instructions

# CHECK: :10: error: operand must be either a label or an integer in the range [0, 0xffff]
 seth $1,0x10000
# CHECK: :10: error: operand must be either a label or an integer in the range [0, 0xffff]
 seth $1,-0x1
