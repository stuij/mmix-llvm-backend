# RUN: not llvm-mc -triple=mmix -filetype obj < %s -o /dev/null 2>&1 | FileCheck %s


# out of range checks

# CHECK: error: branch fixup value out of range
  pushj $1,branch_front

branch_back:
# one tetra past maximum branch range
.space 262140
branch_front:

# filler. TODO: add nop instruction
  add $0,$0,0
  add $0,$0,0

# CHECK: error: branch fixup value out of range
  pushj $1,branch_back

# CHECK: error: jump fixup value out of range
  jmp jump_front

jump_back:
# one tetra past maximum jump range
.space 67108860
jump_front:

# filler. TODO: add nop instruction
  add $0,$0,0
  add $0,$0,0

# CHECK: error: jump fixup value out of range
  jmp jump_back


# alignment checks

# CHECK: error: branch fixup value must be 4-byte aligned
  pushj $1,unaligned

# CHECK: error: jump fixup value must be 4-byte aligned
  jmp unaligned

.byte 0
unaligned:
