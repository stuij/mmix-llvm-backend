# RUN: not llvm-mc -triple mmix < %s 2>&1 | FileCheck %s

# Out of range immediates
# CHECK: :13: error: immediate must be an integer in the range [0, 255]
  add $0,$1,-1
# CHECK: :13: error: immediate must be an integer in the range [0, 255]
  add $3,$4,256

# Invalid mnemonics
# CHECK: :3: error: unrecognized instruction mnemonic
  addi $0,$1,1

# Invalid register names
# CHECK: :7: error: unknown operand
  add foo,$1,10

# Invalid operand types
# CHECK: :7: error: invalid operand for instruction
  add 22,$1,$0

# Too many operands
# CHECK: :16: error: invalid operand for instruction
  add $0,$1,$2,$3

# Too few operands
# CHECK: :3: error: too few operands for instruction
  add $0,$1
