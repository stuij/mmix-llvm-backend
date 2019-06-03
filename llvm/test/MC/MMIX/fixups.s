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

check_branch_back:

# CHECK-INST: bn $1,check_branch_forward
# CHECK: encoding: [0x41'A',0x01'A',A,A]
# CHECK-DISASS: 40 01 00 20     bn $1,0x80
  bn $1,check_branch_forward

# CHECK-INST: bn $1,check_branch_back
# CHECK: encoding: [0x41'A',0x01'A',A,A]
# CHECK-DISASS: 41 01 ff ff     bn $1,-0x4
  bn $1,check_branch_back

# CHECK-INST: bz $1,check_branch_forward
# CHECK: encoding: [0x43'A',0x01'A',A,A]
# CHECK-DISASS: 42 01 00 1e     bz $1,0x78
  bz $1,check_branch_forward

# CHECK-INST: bz $1,check_branch_back
# CHECK: encoding: [0x43'A',0x01'A',A,A]
# CHECK-DISASS: 43 01 ff fd     bz $1,-0xc
  bz $1,check_branch_back

# CHECK-INST: bp $1,check_branch_forward
# CHECK: encoding: [0x45'A',0x01'A',A,A]
# CHECK-DISASS: 44 01 00 1c     bp $1,0x70
  bp $1,check_branch_forward

# CHECK-INST: bp $1,check_branch_back
# CHECK: encoding: [0x45'A',0x01'A',A,A]
# CHECK-DISASS: 45 01 ff fb     bp $1,-0x14
  bp $1,check_branch_back

# CHECK-INST: bod $1,check_branch_forward
# CHECK: encoding: [0x47'A',0x01'A',A,A]
# CHECK-DISASS: 46 01 00 1a     bod $1,0x68
  bod $1,check_branch_forward

# CHECK-INST: bod $1,check_branch_back
# CHECK: encoding: [0x47'A',0x01'A',A,A]
# CHECK-DISASS: 47 01 ff f9     bod $1,-0x1c
  bod $1,check_branch_back

# CHECK-INST: bnn $1,check_branch_forward
# CHECK: encoding: [0x49'A',0x01'A',A,A]
# CHECK-DISASS: 48 01 00 18     bnn $1,0x60
  bnn $1,check_branch_forward

# CHECK-INST: bnn $1,check_branch_back
# CHECK: encoding: [0x49'A',0x01'A',A,A]
# CHECK-DISASS: 49 01 ff f7     bnn $1,-0x24
  bnn $1,check_branch_back

# CHECK-INST: bnz $1,check_branch_forward
# CHECK: encoding: [0x4b'A',0x01'A',A,A]
# CHECK-DISASS: 4a 01 00 16     bnz $1,0x58
  bnz $1,check_branch_forward

# CHECK-INST: bnz $1,check_branch_back
# CHECK: encoding: [0x4b'A',0x01'A',A,A]
# CHECK-DISASS: 4b 01 ff f5     bnz $1,-0x2c
  bnz $1,check_branch_back

# CHECK-INST: bnp $1,check_branch_forward
# CHECK: encoding: [0x4d'A',0x01'A',A,A]
# CHECK-DISASS: 4c 01 00 14     bnp $1,0x50
  bnp $1,check_branch_forward

# CHECK-INST: bnp $1,check_branch_back
# CHECK: encoding: [0x4d'A',0x01'A',A,A]
# CHECK-DISASS: 4d 01 ff f3     bnp $1,-0x34
  bnp $1,check_branch_back

# CHECK-INST: bev $1,check_branch_forward
# CHECK: encoding: [0x4f'A',0x01'A',A,A]
# CHECK-DISASS: 4e 01 00 12     bev $1,0x48
  bev $1,check_branch_forward

# CHECK-INST: bev $1,check_branch_back
# CHECK: encoding: [0x4f'A',0x01'A',A,A]
# CHECK-DISASS: 4f 01 ff f1     bev $1,-0x3c
  bev $1,check_branch_back

# CHECK-INST: pbn $1,check_branch_forward
# CHECK: encoding: [0x51'A',0x01'A',A,A]
# CHECK-DISASS: 50 01 00 10     pbn $1,0x40
  pbn $1,check_branch_forward

# CHECK-INST: pbn $1,check_branch_back
# CHECK: encoding: [0x51'A',0x01'A',A,A]
# CHECK-DISASS: 51 01 ff ef     pbn $1,-0x44
  pbn $1,check_branch_back

# CHECK-INST: pbz $1,check_branch_forward
# CHECK: encoding: [0x53'A',0x01'A',A,A]
# CHECK-DISASS: 52 01 00 0e     pbz $1,0x38
  pbz $1,check_branch_forward

# CHECK-INST: pbz $1,check_branch_back
# CHECK: encoding: [0x53'A',0x01'A',A,A]
# CHECK-DISASS: 53 01 ff ed     pbz $1,-0x4c
  pbz $1,check_branch_back

# CHECK-INST: pbp $1,check_branch_forward
# CHECK: encoding: [0x55'A',0x01'A',A,A]
# CHECK-DISASS: 54 01 00 0c     pbp $1,0x30
  pbp $1,check_branch_forward

# CHECK-INST: pbp $1,check_branch_back
# CHECK: encoding: [0x55'A',0x01'A',A,A]
# CHECK-DISASS: 55 01 ff eb     pbp $1,-0x54
  pbp $1,check_branch_back

# CHECK-INST: pbod $1,check_branch_forward
# CHECK: encoding: [0x57'A',0x01'A',A,A]
# CHECK-DISASS: 56 01 00 0a     pbod $1,0x28
  pbod $1,check_branch_forward

# CHECK-INST: pbod $1,check_branch_back
# CHECK: encoding: [0x57'A',0x01'A',A,A]
# CHECK-DISASS: 57 01 ff e9     pbod $1,-0x5c
  pbod $1,check_branch_back

# CHECK-INST: pbnn $1,check_branch_forward
# CHECK: encoding: [0x59'A',0x01'A',A,A]
# CHECK-DISASS: 58 01 00 08     pbnn $1,0x20
  pbnn $1,check_branch_forward

# CHECK-INST: pbnn $1,check_branch_back
# CHECK: encoding: [0x59'A',0x01'A',A,A]
# CHECK-DISASS: 59 01 ff e7     pbnn $1,-0x64
  pbnn $1,check_branch_back

# CHECK-INST: pbnz $1,check_branch_forward
# CHECK: encoding: [0x5b'A',0x01'A',A,A]
# CHECK-DISASS: 5a 01 00 06     pbnz $1,0x18
  pbnz $1,check_branch_forward

# CHECK-INST: pbnz $1,check_branch_back
# CHECK: encoding: [0x5b'A',0x01'A',A,A]
# CHECK-DISASS: 5b 01 ff e5     pbnz $1,-0x6c
  pbnz $1,check_branch_back

# CHECK-INST: pbnp $1,check_branch_forward
# CHECK: encoding: [0x5d'A',0x01'A',A,A]
# CHECK-DISASS: 5c 01 00 04     pbnp $1,0x10
  pbnp $1,check_branch_forward

# CHECK-INST: pbnp $1,check_branch_back
# CHECK: encoding: [0x5d'A',0x01'A',A,A]
# CHECK-DISASS: 5d 01 ff e3     pbnp $1,-0x74
  pbnp $1,check_branch_back

# CHECK-INST: pbev $1,check_branch_forward
# CHECK: encoding: [0x5f'A',0x01'A',A,A]
# CHECK-DISASS: 5e 01 00 02     pbev $1,0x8
  pbev $1,check_branch_forward

# CHECK-INST: pbev $1,check_branch_back
# CHECK: encoding: [0x5f'A',0x01'A',A,A]
# CHECK-DISASS: 5f 01 ff e1     pbev $1,-0x7c
  pbev $1,check_branch_back

check_branch_forward:
