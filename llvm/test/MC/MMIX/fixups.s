# RUN: llvm-mc %s -triple=mmix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -triple=mmix -filetype=obj < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-DISASS %s

address:

# CHECK-INST: seth $1,address-77727853370818833
# CHECK: encoding: [0xe0'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_h
# CHECK-DISASS: e0 01 fe eb     seth $1,0xfeeb
  seth $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: setmh $1,address-77727853370818833
# CHECK: encoding: [0xe1'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_mh
# CHECK-DISASS: e1 01 da ed     setmh $1,0xdaed
  setmh $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: setml $1,address-77727853370818833
# CHECK: encoding: [0xe2'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_ml
# CHECK-DISASS: e2 01 de ad     setml $1,0xdead
  setml $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: setl $1,address-77727853370818833
# CHECK: encoding: [0xe3'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_l
# CHECK-DISASS: e3 01 be ef     setl $1,0xbeef
  setl $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: orh $1,address-77727853370818833
# CHECK: encoding: [0xe8'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_h
# CHECK-DISASS: e8 01 fe eb     orh $1,0xfeeb
  orh $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: ormh $1,address-77727853370818833
# CHECK: encoding: [0xe9'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_mh
# CHECK-DISASS: e9 01 da ed     ormh $1,0xdaed
  ormh $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: orml $1,address-77727853370818833
# CHECK: encoding: [0xea'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_ml
# CHECK-DISASS: ea 01 de ad     orml $1,0xdead
  orml $1,address + 0xfeebdaeddeadbeef

# CHECK-INST: orl $1,address-77727853370818833
# CHECK: encoding: [0xeb'A',0x01'A',0x00,0x00]
# CHECK: fixup A - offset: 0, value: address-77727853370818833, kind: fixup_mmix_l
# CHECK-DISASS: eb 01 be ef     orl $1,0xbeef
  orl $1,address + 0xfeebdaeddeadbeef


# branch and subroutine instructions

# CHECK-INST: pushj $1,branch_front
# CHECK: encoding: [0xf{{[23]}}'A',0x01'A',A,A]
# CHECK-DISASS: f2 01 ff ff     pushj $1,0x3fffc
  pushj $1,branch_front

branch_back:
.space 262136
branch_front:

# CHECK-INST: pushj $1,branch_front
# CHECK: encoding: [0xf{{[23]}}'A',0x01'A',A,A]
# CHECK-DISASS: f2 01 00 00     pushj $1,0x0
  pushj $1,branch_front

# CHECK-INST: pushj $1,branch_front
# CHECK: encoding: [0xf{{[23]}}'A',0x01'A',A,A]
# CHECK-DISASS: f3 01 ff ff     pushj $1,-0x4
  pushj $1,branch_front

# CHECK-INST: pushj $1,branch_back
# CHECK: encoding: [0xf{{[23]}}'A',0x01'A',A,A]
# CHECK-DISASS: f3 01 00 00     pushj $1,-0x40000
  pushj $1,branch_back


# CHECK-INST: jmp jump_front
# CHECK: encoding: [0xf{{[01]}}'A',A,A,A]
# CHECK-DISASS: f0 ff ff ff     jmp	0x3fffffc
  jmp jump_front

jump_back:
.space 67108856
jump_front:

# CHECK-INST: jmp jump_front
# CHECK: encoding: [0xf{{[01]}}'A',A,A,A]
# CHECK-DISASS: f0 00 00 00     jmp 0x0
  jmp jump_front

# CHECK-INST: jmp jump_front
# CHECK: encoding: [0xf{{[01]}}'A',A,A,A]
# CHECK-DISASS: f1 ff ff ff     jmp -0x4
  jmp jump_front

# CHECK-INST: jmp jump_back
# CHECK: encoding: [0xf{{[01]}}'A',A,A,A]
# CHECK-DISASS: f1 00 00 00     jmp -0x4000000
  jmp jump_back

# CHECK-INST: jmp jump_back
# CHECK: encoding: [0xf{{[01]}}'A',A,A,A]
# CHECK-DISASS: f1 00 00 01     jmp -0x3fffffc
  jmp jump_back + 8
