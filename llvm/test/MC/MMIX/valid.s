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

# CHECK-INST: addu $221,$255,$176
# CHECK: encoding: [0x22,0xdd,0xff,0xb0]
# CHECK-DISASS: 22 dd ff b0     addu $221,$255,$176
  addu $221,$255,$176

# CHECK-INST: addu $241,$158,0xec
# CHECK: encoding: [0x23,0xf1,0x9e,0xec]
# CHECK-DISASS: 23 f1 9e ec     addu $241,$158,0xec
  addu $241,$158,0xec

# CHECK-INST: sub $66,$244,$114
# CHECK: encoding: [0x24,0x42,0xf4,0x72]
# CHECK-DISASS: 24 42 f4 72     sub $66,$244,$114
  sub $66,$244,$114

# CHECK-INST: sub $90,$235,0xe6
# CHECK: encoding: [0x25,0x5a,0xeb,0xe6]
# CHECK-DISASS: 25 5a eb e6     sub $90,$235,0xe6
  sub $90,$235,0xe6

# CHECK-INST: subu $237,$233,$230
# CHECK: encoding: [0x26,0xed,0xe9,0xe6]
# CHECK-DISASS: 26 ed e9 e6     subu $237,$233,$230
  subu $237,$233,$230

# CHECK-INST: subu $152,$39,0xd8
# CHECK: encoding: [0x27,0x98,0x27,0xd8]
# CHECK-DISASS: 27 98 27 d8     subu $152,$39,0xd8
  subu $152,$39,0xd8


# Wyde instructions

# load immediate

# CHECK-INST: seth $1,0xffff
# CHECK: encoding: [0xe0,0x01,0xff,0xff]
# CHECK-DISASS: e0 01 ff ff     seth $1,0xffff
  seth $1,0xffff

# CHECK-INST: setmh $2,0xff00
# CHECK: encoding: [0xe1,0x02,0xff,0x00]
# CHECK-DISASS: e1 02 ff 00     setmh $2,0xff00
  setmh $2,0xff00

# CHECK-INST: setml $1,0xffff
# CHECK: encoding: [0xe2,0x01,0xff,0xff]
# CHECK-DISASS: e2 01 ff ff     setml $1,0xffff
  setml $1,0xffff

# CHECK-INST: setl $1,0xffff
# CHECK: encoding: [0xe3,0x01,0xff,0xff]
# CHECK-DISASS: e3 01 ff ff     setl $1,0xffff
  setl $1,0xffff

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


# load instructions

# CHECK-INST: ldb $19,$19,$117
# CHECK: encoding: [0x80,0x13,0x13,0x75]
# CHECK-DISASS: 80 13 13 75     ldb $19,$19,$117
  ldb $19,$19,$117

# CHECK-INST: ldb $196,$164,0xe8
# CHECK: encoding: [0x81,0xc4,0xa4,0xe8]
# CHECK-DISASS: 81 c4 a4 e8     ldb $196,$164,0xe8
  ldb $196,$164,0xe8

# CHECK-INST: ldbu $208,$166,$152
# CHECK: encoding: [0x82,0xd0,0xa6,0x98]
# CHECK-DISASS: 82 d0 a6 98     ldbu $208,$166,$152
  ldbu $208,$166,$152

# CHECK-INST: ldbu $59,$40,0x8e
# CHECK: encoding: [0x83,0x3b,0x28,0x8e]
# CHECK-DISASS: 83 3b 28 8e     ldbu $59,$40,0x8e
  ldbu $59,$40,0x8e

# CHECK-INST: ldw $26,$118,$124
# CHECK: encoding: [0x84,0x1a,0x76,0x7c]
# CHECK-DISASS: 84 1a 76 7c     ldw $26,$118,$124
  ldw $26,$118,$124

# CHECK-INST: ldw $175,$255,0x82
# CHECK: encoding: [0x85,0xaf,0xff,0x82]
# CHECK-DISASS: 85 af ff 82     ldw $175,$255,0x82
  ldw $175,$255,0x82

# CHECK-INST: ldwu $20,$189,$237
# CHECK: encoding: [0x86,0x14,0xbd,0xed]
# CHECK-DISASS: 86 14 bd ed     ldwu $20,$189,$237
  ldwu $20,$189,$237

# CHECK-INST: ldwu $215,$103,0xe
# CHECK: encoding: [0x87,0xd7,0x67,0x0e]
# CHECK-DISASS: 87 d7 67 0e     ldwu $215,$103,0xe
  ldwu $215,$103,0xe

# CHECK-INST: ldt $8,$124,$215
# CHECK: encoding: [0x88,0x08,0x7c,0xd7]
# CHECK-DISASS: 88 08 7c d7     ldt $8,$124,$215
  ldt $8,$124,$215

# CHECK-INST: ldt $78,$247,0x6
# CHECK: encoding: [0x89,0x4e,0xf7,0x06]
# CHECK-DISASS: 89 4e f7 06     ldt $78,$247,0x6
  ldt $78,$247,0x6

# CHECK-INST: ldtu $42,$15,$222
# CHECK: encoding: [0x8a,0x2a,0x0f,0xde]
# CHECK-DISASS: 8a 2a 0f de     ldtu $42,$15,$222
  ldtu $42,$15,$222

# CHECK-INST: ldtu $26,$233,0x88
# CHECK: encoding: [0x8b,0x1a,0xe9,0x88]
# CHECK-DISASS: 8b 1a e9 88     ldtu $26,$233,0x88
  ldtu $26,$233,0x88

# CHECK-INST: ldo $242,$48,$142
# CHECK: encoding: [0x8c,0xf2,0x30,0x8e]
# CHECK-DISASS: 8c f2 30 8e     ldo $242,$48,$142
  ldo $242,$48,$142

# CHECK-INST: ldo $240,$181,0x3c
# CHECK: encoding: [0x8d,0xf0,0xb5,0x3c]
# CHECK-DISASS: 8d f0 b5 3c     ldo $240,$181,0x3c
  ldo $240,$181,0x3c

# CHECK-INST: ldou $87,$216,$67
# CHECK: encoding: [0x8e,0x57,0xd8,0x43]
# CHECK-DISASS: 8e 57 d8 43     ldou $87,$216,$67
  ldou $87,$216,$67

# CHECK-INST: ldou $12,$230,0x32
# CHECK: encoding: [0x8f,0x0c,0xe6,0x32]
# CHECK-DISASS: 8f 0c e6 32     ldou $12,$230,0x32
  ldou $12,$230,0x32


# store instructions

# CHECK-INST: stb $130,$64,$209
# CHECK: encoding: [0xa0,0x82,0x40,0xd1]
# CHECK-DISASS: a0 82 40 d1     stb $130,$64,$209
  stb $130,$64,$209

# CHECK-INST: stb $255,$5,0x8e
# CHECK: encoding: [0xa1,0xff,0x05,0x8e]
# CHECK-DISASS: a1 ff 05 8e     stb $255,$5,0x8e
  stb $255,$5,0x8e

# CHECK-INST: stbu $172,$23,$232
# CHECK: encoding: [0xa2,0xac,0x17,0xe8]
# CHECK-DISASS: a2 ac 17 e8     stbu $172,$23,$232
  stbu $172,$23,$232

# CHECK-INST: stbu $33,$207,0x3e
# CHECK: encoding: [0xa3,0x21,0xcf,0x3e]
# CHECK-DISASS: a3 21 cf 3e     stbu $33,$207,0x3e
  stbu $33,$207,0x3e

# CHECK-INST: stw $153,$2,$34
# CHECK: encoding: [0xa4,0x99,0x02,0x22]
# CHECK-DISASS: a4 99 02 22     stw $153,$2,$34
  stw $153,$2,$34

# CHECK-INST: stw $225,$226,0xf6
# CHECK: encoding: [0xa5,0xe1,0xe2,0xf6]
# CHECK-DISASS: a5 e1 e2 f6     stw $225,$226,0xf6
  stw $225,$226,0xf6

# CHECK-INST: stwu $13,$164,$154
# CHECK: encoding: [0xa6,0x0d,0xa4,0x9a]
# CHECK-DISASS: a6 0d a4 9a     stwu $13,$164,$154
  stwu $13,$164,$154

# CHECK-INST: stwu $183,$111,0xf6
# CHECK: encoding: [0xa7,0xb7,0x6f,0xf6]
# CHECK-DISASS: a7 b7 6f f6     stwu $183,$111,0xf6
  stwu $183,$111,0xf6

# CHECK-INST: stt $110,$178,$102
# CHECK: encoding: [0xa8,0x6e,0xb2,0x66]
# CHECK-DISASS: a8 6e b2 66     stt $110,$178,$102
  stt $110,$178,$102

# CHECK-INST: stt $252,$9,0xb2
# CHECK: encoding: [0xa9,0xfc,0x09,0xb2]
# CHECK-DISASS: a9 fc 09 b2     stt $252,$9,0xb2
  stt $252,$9,0xb2

# CHECK-INST: sttu $131,$54,$113
# CHECK: encoding: [0xaa,0x83,0x36,0x71]
# CHECK-DISASS: aa 83 36 71     sttu $131,$54,$113
  sttu $131,$54,$113

# CHECK-INST: sttu $102,$248,0x98
# CHECK: encoding: [0xab,0x66,0xf8,0x98]
# CHECK-DISASS: ab 66 f8 98     sttu $102,$248,0x98
  sttu $102,$248,0x98

# CHECK-INST: sto $172,$139,$179
# CHECK: encoding: [0xac,0xac,0x8b,0xb3]
# CHECK-DISASS: ac ac 8b b3     sto $172,$139,$179
  sto $172,$139,$179

# CHECK-INST: sto $12,$137,0x25
# CHECK: encoding: [0xad,0x0c,0x89,0x25]
# CHECK-DISASS: ad 0c 89 25     sto $12,$137,0x25
  sto $12,$137,0x25

# CHECK-INST: stou $203,$142,$232
# CHECK: encoding: [0xae,0xcb,0x8e,0xe8]
# CHECK-DISASS: ae cb 8e e8     stou $203,$142,$232
  stou $203,$142,$232

# CHECK-INST: stou $144,$245,0xe7
# CHECK: encoding: [0xaf,0x90,0xf5,0xe7]
# CHECK-DISASS: af 90 f5 e7     stou $144,$245,0xe7
  stou $144,$245,0xe7
