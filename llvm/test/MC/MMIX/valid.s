# RUN: llvm-mc %s -triple=mmix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -triple=mmix -filetype=obj < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-DISASS %s

# CHECK-INST: add $0,$255,$2
# CHECK: encoding: [0x20,0x00,0xff,0x02]
# CHECK-DISASS: 20 00 ff 02     add     $0,$255,$2
  add $0,$255,$2

# CHECK-INST: add $5,$6,0
# CHECK: encoding: [0x21,0x05,0x06,0x00]
# CHECK-DISASS: 21 05 06 00     add     $5,$6,0
  add $5,$6,0

# CHECK-INST: add $5,$6,255
# CHECK: encoding: [0x21,0x05,0x06,0xff]
# CHECK-DISASS: 21 05 06 ff     add     $5,$6,255
  add $5,$6,255
