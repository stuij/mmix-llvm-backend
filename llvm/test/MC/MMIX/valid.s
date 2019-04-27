# RUN: llvm-mc %s -triple=mmix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -triple=mmix -filetype=obj < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-DISASS %s


# ALU instructions

# CHECK-INST: add $0,$255,$2
# CHECK: encoding: [0x20,0x00,0xff,0x02]
# CHECK-DISASS: 20 00 ff 02     add $0,$255,$2
  add $0,$255,$2

# CHECK-INST: add $5,$6,0x0
# CHECK: encoding: [0x21,0x05,0x06,0x00]
# CHECK-DISASS: 21 05 06 00     add $5,$6,0x0
  add $5,$6,0

# CHECK-INST: add $5,$6,0xff
# CHECK: encoding: [0x21,0x05,0x06,0xff]
# CHECK-DISASS: 21 05 06 ff     add $5,$6,0xff
  add $5,$6,255


# Wyde instructions

# load immediate

# CHECK-INST: seth $1,0xffff
# CHECK: encoding: [0xe0,0x01,0xff,0xff]
# CHECK-DISASS: e0 01 ff ff     seth $1,0xffff
  seth $1,0xffff

# CHECK-INST: orh $1,0x0
# CHECK: encoding: [0xe8,0x01,0x00,0x00]
# CHECK-DISASS: e8 01 00 00     orh $1,0x0
  orh $1,0x0

# CHECK-INST: ormh $1,0xffff
# CHECK: encoding: [0xe9,0x01,0xff,0xff]
# CHECK-DISASS: e9 01 ff ff     ormh $1,0xffff
  ormh $1,0xffff

# CHECK-INST: orml $1,0xffff
# CHECK: encoding: [0xea,0x01,0xff,0xff]
# CHECK-DISASS: ea 01 ff ff     orml $1,0xffff
  orml $1,0xffff

# CHECK-INST: orl $1,0xffff
# CHECK: encoding: [0xeb,0x01,0xff,0xff]
# CHECK-DISASS: eb 01 ff ff     orl $1,0xffff
  orl $1,0xffff
