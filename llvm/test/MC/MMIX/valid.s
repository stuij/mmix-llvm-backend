# RUN: llvm-mc %s -triple=mmix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -triple=mmix -filetype=obj < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-DISASS %s

# leftovers

# CHECK-INST: trap 0x16,0xa7,0xf5
# CHECK: encoding: [0x00,0x16,0xa7,0xf5]
# CHECK-DISASS: 00 16 a7 f5   trap 0x16,0xa7,0xf5
  trap 0x16,0xa7,0xf5

# CHECK-INST: swym 0x57,0x46,0x69
# CHECK: encoding: [0xfd,0x57,0x46,0x69]
# CHECK-DISASS: fd 57 46 69   swym 0x57,0x46,0x69
  swym 0x57,0x46,0x69

# CHECK-INST: trip 0x69,0x62,0x27
# CHECK: encoding: [0xff,0x69,0x62,0x27]
# CHECK-DISASS: ff 69 62 27   trip 0x69,0x62,0x27
  trip 0x69,0x62,0x27

# CHECK-INST: resume 0x74
# CHECK: encoding: [0xf9,0x00,0x00,0x74]
# CHECK-DISASS: f9 00 00 74   resume 0x74
  resume 0x74

# CHECK-INST: save $210
# CHECK: encoding: [0xfa,0xd2,0x00,0x00]
# CHECK-DISASS: fa d2 00 00   save $210
  save $210

# CHECK-INST: unsave $211
# CHECK: encoding: [0xfb,0x00,0x00,0xd3]
# CHECK-DISASS: fb 00 00 d3   unsave $211
  unsave $211

# CHECK-INST: sync 0xf5
# CHECK: encoding: [0xfc,0x00,0x00,0xf5]
# CHECK-DISASS: fc 00 00 f5   sync 0xf5
  sync 0xf5

# floating point instructions

# CHECK-INST: fcmp $118,$40,$86
# CHECK: encoding: [0x01,0x76,0x28,0x56]
# CHECK-DISASS: 01 76 28 56   fcmp $118,$40,$86
  fcmp $118,$40,$86

# CHECK-INST: fun $145,$237,$137
# CHECK: encoding: [0x02,0x91,0xed,0x89]
# CHECK-DISASS: 02 91 ed 89   fun $145,$237,$137
  fun $145,$237,$137

# CHECK-INST: feql $103,$252,$225
# CHECK: encoding: [0x03,0x67,0xfc,0xe1]
# CHECK-DISASS: 03 67 fc e1   feql $103,$252,$225
  feql $103,$252,$225

# CHECK-INST: fadd $238,$95,$21
# CHECK: encoding: [0x04,0xee,0x5f,0x15]
# CHECK-DISASS: 04 ee 5f 15   fadd $238,$95,$21
  fadd $238,$95,$21

# CHECK-INST: fsub $112,$19,$127
# CHECK: encoding: [0x06,0x70,0x13,0x7f]
# CHECK-DISASS: 06 70 13 7f   fsub $112,$19,$127
  fsub $112,$19,$127

# CHECK-INST: fmul $212,$236,$23
# CHECK: encoding: [0x10,0xd4,0xec,0x17]
# CHECK-DISASS: 10 d4 ec 17   fmul $212,$236,$23
  fmul $212,$236,$23

# CHECK-INST: fcmpe $145,$79,$51
# CHECK: encoding: [0x11,0x91,0x4f,0x33]
# CHECK-DISASS: 11 91 4f 33   fcmpe $145,$79,$51
  fcmpe $145,$79,$51

# CHECK-INST: fune $192,$35,$199
# CHECK: encoding: [0x12,0xc0,0x23,0xc7]
# CHECK-DISASS: 12 c0 23 c7   fune $192,$35,$199
  fune $192,$35,$199

# CHECK-INST: feqle $143,$107,$208
# CHECK: encoding: [0x13,0x8f,0x6b,0xd0]
# CHECK-DISASS: 13 8f 6b d0   feqle $143,$107,$208
  feqle $143,$107,$208

# CHECK-INST: fdiv $77,$58,$143
# CHECK: encoding: [0x14,0x4d,0x3a,0x8f]
# CHECK-DISASS: 14 4d 3a 8f   fdiv $77,$58,$143
  fdiv $77,$58,$143

# CHECK-INST: frem $92,$97,$196
# CHECK: encoding: [0x16,0x5c,0x61,0xc4]
# CHECK-DISASS: 16 5c 61 c4   frem $92,$97,$196
  frem $92,$97,$196

# CHECK-INST: fix $103,0x0,$161
# CHECK: encoding: [0x05,0x67,0x00,0xa1]
# CHECK-DISASS: 05 67 00 a1   fix $103,0x0,$161
  fix $103,0x0,$161

# CHECK-INST: fixu $204,0x0,$96
# CHECK: encoding: [0x07,0xcc,0x00,0x60]
# CHECK-DISASS: 07 cc 00 60   fixu $204,0x0,$96
  fixu $204,0x0,$96

# CHECK-INST: fsqrt $25,0x4,$157
# CHECK: encoding: [0x15,0x19,0x04,0x9d]
# CHECK-DISASS: 15 19 04 9d   fsqrt $25,0x4,$157
  fsqrt $25,0x4,$157

# CHECK-INST: fint $207,0x4,$182
# CHECK: encoding: [0x17,0xcf,0x04,0xb6]
# CHECK-DISASS: 17 cf 04 b6   fint $207,0x4,$182
  fint $207,0x4,$182

# CHECK-INST: flot $80,0x4,$104
# CHECK: encoding: [0x08,0x50,0x04,0x68]
# CHECK-DISASS: 08 50 04 68   flot $80,0x4,$104
  flot $80,0x4,$104

# CHECK-INST: flot $219,0x4,0xa1
# CHECK: encoding: [0x09,0xdb,0x04,0xa1]
# CHECK-DISASS: 09 db 04 a1   flot $219,0x4,0xa1
  flot $219,0x4,0xa1

# CHECK-INST: flotu $112,0x4,$54
# CHECK: encoding: [0x0a,0x70,0x04,0x36]
# CHECK-DISASS: 0a 70 04 36   flotu $112,0x4,$54
  flotu $112,0x4,$54

# CHECK-INST: flotu $187,0x3,0x2d
# CHECK: encoding: [0x0b,0xbb,0x03,0x2d]
# CHECK-DISASS: 0b bb 03 2d   flotu $187,0x3,0x2d
  flotu $187,0x3,0x2d

# CHECK-INST: sflot $191,0x3,$190
# CHECK: encoding: [0x0c,0xbf,0x03,0xbe]
# CHECK-DISASS: 0c bf 03 be   sflot $191,0x3,$190
  sflot $191,0x3,$190

# CHECK-INST: sflot $75,0x0,0x80
# CHECK: encoding: [0x0d,0x4b,0x00,0x80]
# CHECK-DISASS: 0d 4b 00 80   sflot $75,0x0,0x80
  sflot $75,0x0,0x80

# CHECK-INST: sflotu $174,0x3,$157
# CHECK: encoding: [0x0e,0xae,0x03,0x9d]
# CHECK-DISASS: 0e ae 03 9d   sflotu $174,0x3,$157
  sflotu $174,0x3,$157

# CHECK-INST: sflotu $177,0x3,0xc0
# CHECK: encoding: [0x0f,0xb1,0x03,0xc0]
# CHECK-DISASS: 0f b1 03 c0   sflotu $177,0x3,0xc0
  sflotu $177,0x3,0xc0

# ALU instructions

# CHECK-INST: mul $24,$232,$83
# CHECK: encoding: [0x18,0x18,0xe8,0x53]
# CHECK-DISASS: 18 18 e8 53     mul $24,$232,$83
  mul $24,$232,$83

# CHECK-INST: mul $7,$232,0x97
# CHECK: encoding: [0x19,0x07,0xe8,0x97]
# CHECK-DISASS: 19 07 e8 97     mul $7,$232,0x97
  mul $7,$232,0x97

# CHECK-INST: mulu $187,$58,$144
# CHECK: encoding: [0x1a,0xbb,0x3a,0x90]
# CHECK-DISASS: 1a bb 3a 90     mulu $187,$58,$144
  mulu $187,$58,$144

# CHECK-INST: mulu $123,$205,0x73
# CHECK: encoding: [0x1b,0x7b,0xcd,0x73]
# CHECK-DISASS: 1b 7b cd 73     mulu $123,$205,0x73
  mulu $123,$205,0x73

# CHECK-INST: div $167,$206,$217
# CHECK: encoding: [0x1c,0xa7,0xce,0xd9]
# CHECK-DISASS: 1c a7 ce d9     div $167,$206,$217
  div $167,$206,$217

# CHECK-INST: div $134,$89,0x4f
# CHECK: encoding: [0x1d,0x86,0x59,0x4f]
# CHECK-DISASS: 1d 86 59 4f     div $134,$89,0x4f
  div $134,$89,0x4f

# CHECK-INST: divu $201,$201,$72
# CHECK: encoding: [0x1e,0xc9,0xc9,0x48]
# CHECK-DISASS: 1e c9 c9 48     divu $201,$201,$72
  divu $201,$201,$72

# CHECK-INST: divu $163,$203,0x89
# CHECK: encoding: [0x1f,0xa3,0xcb,0x89]
# CHECK-DISASS: 1f a3 cb 89     divu $163,$203,0x89
  divu $163,$203,0x89

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

# CHECK-INST: addu2 $227,$109,$38
# CHECK: encoding: [0x28,0xe3,0x6d,0x26]
# CHECK-DISASS: 28 e3 6d 26     addu2 $227,$109,$38
  addu2 $227,$109,$38

# CHECK-INST: addu2 $245,$82,0xaa
# CHECK: encoding: [0x29,0xf5,0x52,0xaa]
# CHECK-DISASS: 29 f5 52 aa     addu2 $245,$82,0xaa
  addu2 $245,$82,0xaa

# CHECK-INST: addu4 $62,$207,$36
# CHECK: encoding: [0x2a,0x3e,0xcf,0x24]
# CHECK-DISASS: 2a 3e cf 24     addu4 $62,$207,$36
  addu4 $62,$207,$36

# CHECK-INST: addu4 $1,$17,0xc0
# CHECK: encoding: [0x2b,0x01,0x11,0xc0]
# CHECK-DISASS: 2b 01 11 c0     addu4 $1,$17,0xc0
  addu4 $1,$17,0xc0

# CHECK-INST: addu8 $7,$100,$147
# CHECK: encoding: [0x2c,0x07,0x64,0x93]
# CHECK-DISASS: 2c 07 64 93     addu8 $7,$100,$147
  addu8 $7,$100,$147

# CHECK-INST: addu8 $28,$217,0xac
# CHECK: encoding: [0x2d,0x1c,0xd9,0xac]
# CHECK-DISASS: 2d 1c d9 ac     addu8 $28,$217,0xac
  addu8 $28,$217,0xac

# CHECK-INST: addu16 $147,$80,$215
# CHECK: encoding: [0x2e,0x93,0x50,0xd7]
# CHECK-DISASS: 2e 93 50 d7     addu16 $147,$80,$215
  addu16 $147,$80,$215

# CHECK-INST: addu16 $213,$115,0xe4
# CHECK: encoding: [0x2f,0xd5,0x73,0xe4]
# CHECK-DISASS: 2f d5 73 e4     addu16 $213,$115,0xe4
  addu16 $213,$115,0xe4

# CHECK-INST: cmp $111,$171,$244
# CHECK: encoding: [0x30,0x6f,0xab,0xf4]
# CHECK-DISASS: 30 6f ab f4     cmp $111,$171,$244
  cmp $111,$171,$244

# CHECK-INST: cmp $19,$182,0x6
# CHECK: encoding: [0x31,0x13,0xb6,0x06]
# CHECK-DISASS: 31 13 b6 06     cmp $19,$182,0x6
  cmp $19,$182,0x6

# CHECK-INST: cmpu $235,$87,$62
# CHECK: encoding: [0x32,0xeb,0x57,0x3e]
# CHECK-DISASS: 32 eb 57 3e     cmpu $235,$87,$62
  cmpu $235,$87,$62

# CHECK-INST: cmpu $185,$163,0xb2
# CHECK: encoding: [0x33,0xb9,0xa3,0xb2]
# CHECK-DISASS: 33 b9 a3 b2     cmpu $185,$163,0xb2
  cmpu $185,$163,0xb2

# CHECK-INST: neg $1,0x0,$2
# CHECK: encoding: [0x34,0x01,0x00,0x02]
# CHECK-DISASS:  34 01 00 02     neg $1,0x0,$2
  neg $1,0x0,$2

# CHECK-INST: neg $1,0xff,0x2
# CHECK: encoding: [0x35,0x01,0xff,0x02]
# CHECK-DISASS: 35 01 ff 02      neg $1,0xff,0x2
  neg $1,0xff,0x2

# CHECK-INST: negu $1,0x1,$2
# CHECK: encoding: [0x36,0x01,0x01,0x02]
# CHECK-DISASS: 36 01 01 02      negu $1,0x1,$2
  negu $1,0x1,$2

# CHECK-INST: negu $1,0xff,0x2
# CHECK: encoding: [0x37,0x01,0xff,0x02]
# CHECK-DISASS: 37 01 ff 02      negu $1,0xff,0x2
  negu $1,0xff,0x2

# CHECK-INST: sl $59,$46,$145
# CHECK: encoding: [0x38,0x3b,0x2e,0x91]
# CHECK-DISASS: 38 3b 2e 91     sl $59,$46,$145
  sl $59,$46,$145

# CHECK-INST: sl $46,$246,0x49
# CHECK: encoding: [0x39,0x2e,0xf6,0x49]
# CHECK-DISASS: 39 2e f6 49     sl $46,$246,0x49
  sl $46,$246,0x49

# CHECK-INST: slu $83,$17,$191
# CHECK: encoding: [0x3a,0x53,0x11,0xbf]
# CHECK-DISASS: 3a 53 11 bf     slu $83,$17,$191
  slu $83,$17,$191

# CHECK-INST: slu $171,$249,0x9
# CHECK: encoding: [0x3b,0xab,0xf9,0x09]
# CHECK-DISASS: 3b ab f9 09     slu $171,$249,0x9
  slu $171,$249,0x9

# CHECK-INST: sr $158,$211,$181
# CHECK: encoding: [0x3c,0x9e,0xd3,0xb5]
# CHECK-DISASS: 3c 9e d3 b5     sr $158,$211,$181
  sr $158,$211,$181

# CHECK-INST: sr $7,$40,0x2a
# CHECK: encoding: [0x3d,0x07,0x28,0x2a]
# CHECK-DISASS: 3d 07 28 2a     sr $7,$40,0x2a
  sr $7,$40,0x2a

# CHECK-INST: sru $182,$195,$44
# CHECK: encoding: [0x3e,0xb6,0xc3,0x2c]
# CHECK-DISASS: 3e b6 c3 2c     sru $182,$195,$44
  sru $182,$195,$44

# CHECK-INST: sru $67,$77,0x7f
# CHECK: encoding: [0x3f,0x43,0x4d,0x7f]
# CHECK-DISASS: 3f 43 4d 7f     sru $67,$77,0x7f
  sru $67,$77,0x7f

# CHECK-INST: csn $107,$72,$56
# CHECK: encoding: [0x60,0x6b,0x48,0x38]
# CHECK-DISASS: 60 6b 48 38     csn $107,$72,$56
  csn $107,$72,$56

# CHECK-INST: csn $107,$210,0x2c
# CHECK: encoding: [0x61,0x6b,0xd2,0x2c]
# CHECK-DISASS: 61 6b d2 2c     csn $107,$210,0x2c
  csn $107,$210,0x2c

# CHECK-INST: csz $61,$53,$228
# CHECK: encoding: [0x62,0x3d,0x35,0xe4]
# CHECK-DISASS: 62 3d 35 e4     csz $61,$53,$228
  csz $61,$53,$228

# CHECK-INST: csz $129,$251,0xbd
# CHECK: encoding: [0x63,0x81,0xfb,0xbd]
# CHECK-DISASS: 63 81 fb bd     csz $129,$251,0xbd
  csz $129,$251,0xbd

# CHECK-INST: csp $125,$242,$205
# CHECK: encoding: [0x64,0x7d,0xf2,0xcd]
# CHECK-DISASS: 64 7d f2 cd     csp $125,$242,$205
  csp $125,$242,$205

# CHECK-INST: csp $225,$159,0x69
# CHECK: encoding: [0x65,0xe1,0x9f,0x69]
# CHECK-DISASS: 65 e1 9f 69     csp $225,$159,0x69
  csp $225,$159,0x69

# CHECK-INST: csod $44,$46,$72
# CHECK: encoding: [0x66,0x2c,0x2e,0x48]
# CHECK-DISASS: 66 2c 2e 48     csod $44,$46,$72
  csod $44,$46,$72

# CHECK-INST: csod $248,$124,0xb8
# CHECK: encoding: [0x67,0xf8,0x7c,0xb8]
# CHECK-DISASS: 67 f8 7c b8     csod $248,$124,0xb8
  csod $248,$124,0xb8

# CHECK-INST: csnn $190,$13,$46
# CHECK: encoding: [0x68,0xbe,0x0d,0x2e]
# CHECK-DISASS: 68 be 0d 2e     csnn $190,$13,$46
  csnn $190,$13,$46

# CHECK-INST: csnn $68,$99,0x33
# CHECK: encoding: [0x69,0x44,0x63,0x33]
# CHECK-DISASS: 69 44 63 33     csnn $68,$99,0x33
  csnn $68,$99,0x33

# CHECK-INST: csnz $39,$26,$169
# CHECK: encoding: [0x6a,0x27,0x1a,0xa9]
# CHECK-DISASS: 6a 27 1a a9     csnz $39,$26,$169
  csnz $39,$26,$169

# CHECK-INST: csnz $171,$158,0xf1
# CHECK: encoding: [0x6b,0xab,0x9e,0xf1]
# CHECK-DISASS: 6b ab 9e f1     csnz $171,$158,0xf1
  csnz $171,$158,0xf1

# CHECK-INST: csnp $220,$28,$185
# CHECK: encoding: [0x6c,0xdc,0x1c,0xb9]
# CHECK-DISASS: 6c dc 1c b9     csnp $220,$28,$185
  csnp $220,$28,$185

# CHECK-INST: csnp $143,$210,0xfe
# CHECK: encoding: [0x6d,0x8f,0xd2,0xfe]
# CHECK-DISASS: 6d 8f d2 fe     csnp $143,$210,0xfe
  csnp $143,$210,0xfe

# CHECK-INST: csev $21,$241,$100
# CHECK: encoding: [0x6e,0x15,0xf1,0x64]
# CHECK-DISASS: 6e 15 f1 64     csev $21,$241,$100
  csev $21,$241,$100

# CHECK-INST: csev $191,$144,0x7d
# CHECK: encoding: [0x6f,0xbf,0x90,0x7d]
# CHECK-DISASS: 6f bf 90 7d     csev $191,$144,0x7d
  csev $191,$144,0x7d

# CHECK-INST: zsn $205,$198,$223
# CHECK: encoding: [0x70,0xcd,0xc6,0xdf]
# CHECK-DISASS: 70 cd c6 df     zsn $205,$198,$223
  zsn $205,$198,$223

# CHECK-INST: zsn $131,$174,0x91
# CHECK: encoding: [0x71,0x83,0xae,0x91]
# CHECK-DISASS: 71 83 ae 91     zsn $131,$174,0x91
  zsn $131,$174,0x91

# CHECK-INST: zsz $39,$143,$41
# CHECK: encoding: [0x72,0x27,0x8f,0x29]
# CHECK-DISASS: 72 27 8f 29     zsz $39,$143,$41
  zsz $39,$143,$41

# CHECK-INST: zsz $128,$59,0x7c
# CHECK: encoding: [0x73,0x80,0x3b,0x7c]
# CHECK-DISASS: 73 80 3b 7c     zsz $128,$59,0x7c
  zsz $128,$59,0x7c

# CHECK-INST: zsp $122,$246,$115
# CHECK: encoding: [0x74,0x7a,0xf6,0x73]
# CHECK-DISASS: 74 7a f6 73     zsp $122,$246,$115
  zsp $122,$246,$115

# CHECK-INST: zsp $152,$184,0x20
# CHECK: encoding: [0x75,0x98,0xb8,0x20]
# CHECK-DISASS: 75 98 b8 20     zsp $152,$184,0x20
  zsp $152,$184,0x20

# CHECK-INST: zsod $208,$7,$165
# CHECK: encoding: [0x76,0xd0,0x07,0xa5]
# CHECK-DISASS: 76 d0 07 a5     zsod $208,$7,$165
  zsod $208,$7,$165

# CHECK-INST: zsod $50,$116,0x80
# CHECK: encoding: [0x77,0x32,0x74,0x80]
# CHECK-DISASS: 77 32 74 80     zsod $50,$116,0x80
  zsod $50,$116,0x80

# CHECK-INST: zsnn $130,$30,$27
# CHECK: encoding: [0x78,0x82,0x1e,0x1b]
# CHECK-DISASS: 78 82 1e 1b     zsnn $130,$30,$27
  zsnn $130,$30,$27

# CHECK-INST: zsnn $136,$85,0x60
# CHECK: encoding: [0x79,0x88,0x55,0x60]
# CHECK-DISASS: 79 88 55 60     zsnn $136,$85,0x60
  zsnn $136,$85,0x60

# CHECK-INST: zsnz $206,$233,$37
# CHECK: encoding: [0x7a,0xce,0xe9,0x25]
# CHECK-DISASS: 7a ce e9 25     zsnz $206,$233,$37
  zsnz $206,$233,$37

# CHECK-INST: zsnz $65,$3,0xdb
# CHECK: encoding: [0x7b,0x41,0x03,0xdb]
# CHECK-DISASS: 7b 41 03 db     zsnz $65,$3,0xdb
  zsnz $65,$3,0xdb

# CHECK-INST: zsnp $117,$19,$90
# CHECK: encoding: [0x7c,0x75,0x13,0x5a]
# CHECK-DISASS: 7c 75 13 5a     zsnp $117,$19,$90
  zsnp $117,$19,$90

# CHECK-INST: zsnp $211,$180,0x7b
# CHECK: encoding: [0x7d,0xd3,0xb4,0x7b]
# CHECK-DISASS: 7d d3 b4 7b     zsnp $211,$180,0x7b
  zsnp $211,$180,0x7b

# CHECK-INST: zsev $102,$15,$172
# CHECK: encoding: [0x7e,0x66,0x0f,0xac]
# CHECK-DISASS: 7e 66 0f ac     zsev $102,$15,$172
  zsev $102,$15,$172

# CHECK-INST: zsev $141,$201,0xb7
# CHECK: encoding: [0x7f,0x8d,0xc9,0xb7]
# CHECK-DISASS: 7f 8d c9 b7     zsev $141,$201,0xb7
  zsev $141,$201,0xb7

# CHECK-INST: bdif $157,$57,$209
# CHECK: encoding: [0xd0,0x9d,0x39,0xd1]
# CHECK-DISASS: d0 9d 39 d1     bdif $157,$57,$209
  bdif $157,$57,$209

# CHECK-INST: bdif $129,$55,0x4f
# CHECK: encoding: [0xd1,0x81,0x37,0x4f]
# CHECK-DISASS: d1 81 37 4f     bdif $129,$55,0x4f
  bdif $129,$55,0x4f

# CHECK-INST: wdif $249,$219,$17
# CHECK: encoding: [0xd2,0xf9,0xdb,0x11]
# CHECK-DISASS: d2 f9 db 11     wdif $249,$219,$17
  wdif $249,$219,$17

# CHECK-INST: wdif $47,$234,0x13
# CHECK: encoding: [0xd3,0x2f,0xea,0x13]
# CHECK-DISASS: d3 2f ea 13     wdif $47,$234,0x13
  wdif $47,$234,0x13

# CHECK-INST: tdif $196,$101,$223
# CHECK: encoding: [0xd4,0xc4,0x65,0xdf]
# CHECK-DISASS: d4 c4 65 df     tdif $196,$101,$223
  tdif $196,$101,$223

# CHECK-INST: tdif $84,$155,0xc
# CHECK: encoding: [0xd5,0x54,0x9b,0x0c]
# CHECK-DISASS: d5 54 9b 0c     tdif $84,$155,0xc
  tdif $84,$155,0xc

# CHECK-INST: odif $202,$206,$80
# CHECK: encoding: [0xd6,0xca,0xce,0x50]
# CHECK-DISASS: d6 ca ce 50     odif $202,$206,$80
  odif $202,$206,$80

# CHECK-INST: odif $102,$184,0xc5
# CHECK: encoding: [0xd7,0x66,0xb8,0xc5]
# CHECK-DISASS: d7 66 b8 c5     odif $102,$184,0xc5
  odif $102,$184,0xc5

# CHECK-INST: mux $25,$234,$85
# CHECK: encoding: [0xd8,0x19,0xea,0x55]
# CHECK-DISASS: d8 19 ea 55     mux $25,$234,$85
  mux $25,$234,$85

# CHECK-INST: mux $121,$30,0xe9
# CHECK: encoding: [0xd9,0x79,0x1e,0xe9]
# CHECK-DISASS: d9 79 1e e9     mux $121,$30,0xe9
  mux $121,$30,0xe9

# CHECK-INST: sadd $138,$202,$255
# CHECK: encoding: [0xda,0x8a,0xca,0xff]
# CHECK-DISASS: da 8a ca ff     sadd $138,$202,$255
  sadd $138,$202,$255

# CHECK-INST: sadd $30,$215,0x80
# CHECK: encoding: [0xdb,0x1e,0xd7,0x80]
# CHECK-DISASS: db 1e d7 80     sadd $30,$215,0x80
  sadd $30,$215,0x80

# CHECK-INST: mor $142,$136,$236
# CHECK: encoding: [0xdc,0x8e,0x88,0xec]
# CHECK-DISASS: dc 8e 88 ec     mor $142,$136,$236
  mor $142,$136,$236

# CHECK-INST: mor $215,$101,0x9f
# CHECK: encoding: [0xdd,0xd7,0x65,0x9f]
# CHECK-DISASS: dd d7 65 9f     mor $215,$101,0x9f
  mor $215,$101,0x9f

# CHECK-INST: mxor $52,$236,$159
# CHECK: encoding: [0xde,0x34,0xec,0x9f]
# CHECK-DISASS: de 34 ec 9f     mxor $52,$236,$159
  mxor $52,$236,$159

# CHECK-INST: mxor $17,$227,0x8
# CHECK: encoding: [0xdf,0x11,0xe3,0x08]
# CHECK-DISASS: df 11 e3 08     mxor $17,$227,0x8
  mxor $17,$227,0x8

# CHECK-INST: or $66,$142,$150
# CHECK: encoding: [0xc0,0x42,0x8e,0x96]
# CHECK-DISASS: c0 42 8e 96     or $66,$142,$150
  or $66,$142,$150

# CHECK-INST: or $13,$188,0x7b
# CHECK: encoding: [0xc1,0x0d,0xbc,0x7b]
# CHECK-DISASS: c1 0d bc 7b     or $13,$188,0x7b
  or $13,$188,0x7b

# CHECK-INST: orn $60,$106,$232
# CHECK: encoding: [0xc2,0x3c,0x6a,0xe8]
# CHECK-DISASS: c2 3c 6a e8     orn $60,$106,$232
  orn $60,$106,$232

# CHECK-INST: orn $13,$149,0xc1
# CHECK: encoding: [0xc3,0x0d,0x95,0xc1]
# CHECK-DISASS: c3 0d 95 c1     orn $13,$149,0xc1
  orn $13,$149,0xc1

# CHECK-INST: nor $98,$52,$219
# CHECK: encoding: [0xc4,0x62,0x34,0xdb]
# CHECK-DISASS: c4 62 34 db     nor $98,$52,$219
  nor $98,$52,$219

# CHECK-INST: nor $48,$155,0x21
# CHECK: encoding: [0xc5,0x30,0x9b,0x21]
# CHECK-DISASS: c5 30 9b 21     nor $48,$155,0x21
  nor $48,$155,0x21

# CHECK-INST: xor $197,$78,$128
# CHECK: encoding: [0xc6,0xc5,0x4e,0x80]
# CHECK-DISASS: c6 c5 4e 80     xor $197,$78,$128
  xor $197,$78,$128

# CHECK-INST: xor $145,$61,0x7d
# CHECK: encoding: [0xc7,0x91,0x3d,0x7d]
# CHECK-DISASS: c7 91 3d 7d     xor $145,$61,0x7d
  xor $145,$61,0x7d

# CHECK-INST: and $15,$182,$0
# CHECK: encoding: [0xc8,0x0f,0xb6,0x00]
# CHECK-DISASS: c8 0f b6 00     and $15,$182,$0
  and $15,$182,$0

# CHECK-INST: and $53,$44,0x16
# CHECK: encoding: [0xc9,0x35,0x2c,0x16]
# CHECK-DISASS: c9 35 2c 16     and $53,$44,0x16
  and $53,$44,0x16

# CHECK-INST: andn $16,$33,$123
# CHECK: encoding: [0xca,0x10,0x21,0x7b]
# CHECK-DISASS: ca 10 21 7b     andn $16,$33,$123
  andn $16,$33,$123

# CHECK-INST: andn $227,$73,0x1d
# CHECK: encoding: [0xcb,0xe3,0x49,0x1d]
# CHECK-DISASS: cb e3 49 1d     andn $227,$73,0x1d
  andn $227,$73,0x1d

# CHECK-INST: nand $16,$118,$203
# CHECK: encoding: [0xcc,0x10,0x76,0xcb]
# CHECK-DISASS: cc 10 76 cb     nand $16,$118,$203
  nand $16,$118,$203

# CHECK-INST: nand $144,$207,0xc
# CHECK: encoding: [0xcd,0x90,0xcf,0x0c]
# CHECK-DISASS: cd 90 cf 0c     nand $144,$207,0xc
  nand $144,$207,0xc

# CHECK-INST: nxor $67,$103,$42
# CHECK: encoding: [0xce,0x43,0x67,0x2a]
# CHECK-DISASS: ce 43 67 2a     nxor $67,$103,$42
  nxor $67,$103,$42

# CHECK-INST: nxor $113,$192,0xef
# CHECK: encoding: [0xcf,0x71,0xc0,0xef]
# CHECK-DISASS: cf 71 c0 ef     nxor $113,$192,0xef
  nxor $113,$192,0xef

# directives

# CHECK-INST: preld 0x65,$222,$237
# CHECK: encoding: [0x9a,0x65,0xde,0xed]
# CHECK-DISASS: 9a 65 de ed   preld 0x65,$222,$237
  preld 0x65,$222,$237

# CHECK-INST: preld 0x97,$155,0xa2
# CHECK: encoding: [0x9b,0x97,0x9b,0xa2]
# CHECK-DISASS: 9b 97 9b a2   preld 0x97,$155,0xa2
  preld 0x97,$155,0xa2

# CHECK-INST: prego 0xce,$154,$19
# CHECK: encoding: [0x9c,0xce,0x9a,0x13]
# CHECK-DISASS: 9c ce 9a 13   prego 0xce,$154,$19
  prego 0xce,$154,$19

# CHECK-INST: prego 0x1b,$67,0x5d
# CHECK: encoding: [0x9d,0x1b,0x43,0x5d]
# CHECK-DISASS: 9d 1b 43 5d   prego 0x1b,$67,0x5d
  prego 0x1b,$67,0x5d

# CHECK-INST: syncd 0x57,$151,$86
# CHECK: encoding: [0xb8,0x57,0x97,0x56]
# CHECK-DISASS: b8 57 97 56   syncd 0x57,$151,$86
  syncd 0x57,$151,$86

# CHECK-INST: syncd 0x29,$133,0xee
# CHECK: encoding: [0xb9,0x29,0x85,0xee]
# CHECK-DISASS: b9 29 85 ee   syncd 0x29,$133,0xee
  syncd 0x29,$133,0xee

# CHECK-INST: prest 0x1c,$0,$77
# CHECK: encoding: [0xba,0x1c,0x00,0x4d]
# CHECK-DISASS: ba 1c 00 4d   prest 0x1c,$0,$77
  prest 0x1c,$0,$77

# CHECK-INST: prest 0xd9,$8,0x27
# CHECK: encoding: [0xbb,0xd9,0x08,0x27]
# CHECK-DISASS: bb d9 08 27   prest 0xd9,$8,0x27
  prest 0xd9,$8,0x27

# CHECK-INST: syncid 0x86,$93,$12
# CHECK: encoding: [0xbc,0x86,0x5d,0x0c]
# CHECK-DISASS: bc 86 5d 0c   syncid 0x86,$93,$12
  syncid 0x86,$93,$12

# CHECK-INST: syncid 0xe2,$197,0x37
# CHECK: encoding: [0xbd,0xe2,0xc5,0x37]
# CHECK-DISASS: bd e2 c5 37   syncid 0xe2,$197,0x37
  syncid 0xe2,$197,0x37

# Wyde instructions

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

# CHECK-INST: inch $180,0x5d5d
# CHECK: encoding: [0xe4,0xb4,0x5d,0x5d]
# CHECK-DISASS: e4 b4 5d 5d   inch $180,0x5d5d
  inch $180,0x5d5d

# CHECK-INST: incmh $135,0x1136
# CHECK: encoding: [0xe5,0x87,0x11,0x36]
# CHECK-DISASS: e5 87 11 36   incmh $135,0x1136
  incmh $135,0x1136

# CHECK-INST: incml $114,0xa5c4
# CHECK: encoding: [0xe6,0x72,0xa5,0xc4]
# CHECK-DISASS: e6 72 a5 c4   incml $114,0xa5c4
  incml $114,0xa5c4

# CHECK-INST: incl $178,0x8335
# CHECK: encoding: [0xe7,0xb2,0x83,0x35]
# CHECK-DISASS: e7 b2 83 35   incl $178,0x8335
  incl $178,0x8335

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

# CHECK-INST: andh $240,0xb502
# CHECK: encoding: [0xec,0xf0,0xb5,0x02]
# CHECK-DISASS: ec f0 b5 02   andh $240,0xb502
  andh $240,0xb502

# CHECK-INST: andmh $83,0x1599
# CHECK: encoding: [0xed,0x53,0x15,0x99]
# CHECK-DISASS: ed 53 15 99   andmh $83,0x1599
  andmh $83,0x1599

# CHECK-INST: andml $188,0xba0f
# CHECK: encoding: [0xee,0xbc,0xba,0x0f]
# CHECK-DISASS: ee bc ba 0f   andml $188,0xba0f
  andml $188,0xba0f

# CHECK-INST: andl $27,0x40f0
# CHECK: encoding: [0xef,0x1b,0x40,0xf0]
# CHECK-DISASS: ef 1b 40 f0   andl $27,0x40f0
  andl $27,0x40f0

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

# CHECK-INST: ldsf $48,$65,$71
# CHECK: encoding: [0x90,0x30,0x41,0x47]
# CHECK-DISASS: 90 30 41 47   ldsf $48,$65,$71
  ldsf $48,$65,$71

# CHECK-INST: ldsf $230,$130,0x34
# CHECK: encoding: [0x91,0xe6,0x82,0x34]
# CHECK-DISASS: 91 e6 82 34   ldsf $230,$130,0x34
  ldsf $230,$130,0x34

# CHECK-INST: ldht $33,$219,$207
# CHECK: encoding: [0x92,0x21,0xdb,0xcf]
# CHECK-DISASS: 92 21 db cf   ldht $33,$219,$207
  ldht $33,$219,$207

# CHECK-INST: ldht $81,$24,0x78
# CHECK: encoding: [0x93,0x51,0x18,0x78]
# CHECK-DISASS: 93 51 18 78   ldht $81,$24,0x78
  ldht $81,$24,0x78

# CHECK-INST: cswap $85,$197,$55
# CHECK: encoding: [0x94,0x55,0xc5,0x37]
# CHECK-DISASS: 94 55 c5 37   cswap $85,$197,$55
  cswap $85,$197,$55

# CHECK-INST: cswap $221,$178,0x9
# CHECK: encoding: [0x95,0xdd,0xb2,0x09]
# CHECK-DISASS: 95 dd b2 09   cswap $221,$178,0x9
  cswap $221,$178,0x9

# CHECK-INST: ldunc $178,$147,$228
# CHECK: encoding: [0x96,0xb2,0x93,0xe4]
# CHECK-DISASS: 96 b2 93 e4   ldunc $178,$147,$228
  ldunc $178,$147,$228

# CHECK-INST: ldunc $80,$148,0x23
# CHECK: encoding: [0x97,0x50,0x94,0x23]
# CHECK-DISASS: 97 50 94 23   ldunc $80,$148,0x23
  ldunc $80,$148,0x23

# CHECK-INST: ldvts $223,$129,$180
# CHECK: encoding: [0x98,0xdf,0x81,0xb4]
# CHECK-DISASS: 98 df 81 b4   ldvts $223,$129,$180
  ldvts $223,$129,$180

# CHECK-INST: ldvts $255,$1,0xd9
# CHECK: encoding: [0x99,0xff,0x01,0xd9]
# CHECK-DISASS: 99 ff 01 d9   ldvts $255,$1,0xd9
  ldvts $255,$1,0xd9

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

# CHECK-INST: stsf $135,$229,$217
# CHECK: encoding: [0xb0,0x87,0xe5,0xd9]
# CHECK-DISASS: b0 87 e5 d9   stsf $135,$229,$217
  stsf $135,$229,$217

# CHECK-INST: stsf $79,$15,0xa5
# CHECK: encoding: [0xb1,0x4f,0x0f,0xa5]
# CHECK-DISASS: b1 4f 0f a5   stsf $79,$15,0xa5
  stsf $79,$15,0xa5

# CHECK-INST: stht $255,$101,$13
# CHECK: encoding: [0xb2,0xff,0x65,0x0d]
# CHECK-DISASS: b2 ff 65 0d   stht $255,$101,$13
  stht $255,$101,$13

# CHECK-INST: stht $219,$131,0xf8
# CHECK: encoding: [0xb3,0xdb,0x83,0xf8]
# CHECK-DISASS: b3 db 83 f8   stht $219,$131,0xf8
  stht $219,$131,0xf8

# CHECK-INST: stco $29,$50,$149
# CHECK: encoding: [0xb4,0x1d,0x32,0x95]
# CHECK-DISASS: b4 1d 32 95   stco $29,$50,$149
  stco $29,$50,$149

# CHECK-INST: stco $34,$4,0x5d
# CHECK: encoding: [0xb5,0x22,0x04,0x5d]
# CHECK-DISASS: b5 22 04 5d   stco $34,$4,0x5d
  stco $34,$4,0x5d

# CHECK-INST: stunc $113,$146,$172
# CHECK: encoding: [0xb6,0x71,0x92,0xac]
# CHECK-DISASS: b6 71 92 ac   stunc $113,$146,$172
  stunc $113,$146,$172

# CHECK-INST: stunc $150,$40,0x50
# CHECK: encoding: [0xb7,0x96,0x28,0x50]
# CHECK-DISASS: b7 96 28 50   stunc $150,$40,0x50
  stunc $150,$40,0x50


# non-relocation branching

# CHECK-INST: pushgo $31,$107,$90
# CHECK: encoding: [0xbe,0x1f,0x6b,0x5a]
# CHECK-DISASS: be 1f 6b 5a     pushgo $31,$107,$90
  pushgo $31,$107,$90

# CHECK-INST: pushgo $181,$150,0x26
# CHECK: encoding: [0xbf,0xb5,0x96,0x26]
# CHECK-DISASS: bf b5 96 26     pushgo $181,$150,0x26
  pushgo $181,$150,0x26

# CHECK-INST: go $74,$103,$145
# CHECK: encoding: [0x9e,0x4a,0x67,0x91]
# CHECK-DISASS: 9e 4a 67 91   go $74,$103,$145
  go $74,$103,$145

# CHECK-INST: go $89,$134,0xba
# CHECK: encoding: [0x9f,0x59,0x86,0xba]
# CHECK-DISASS: 9f 59 86 ba   go $89,$134,0xba
  go $89,$134,0xba

# get/put special registers

# CHECK-INST: put rA,$7
# CHECK: encoding: [0xf6,0x15,0x00,0x07]
# CHECK-DISASS: f6 15 00 07     put rA,$7
  put rA,$7

# CHECK-INST: get $3,rJ
# CHECK: encoding: [0xfe,0x03,0x00,0x04]
# CHECK-DISASS: fe 03 00 04     get $3,rJ
  get $3,rJ
