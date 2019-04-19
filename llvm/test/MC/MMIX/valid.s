# RUN: llvm-mc %s -triple=mmix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s

# CHECK-INST: add $0,$255,$2
# CHECK: encoding: [0x20,0x00,0xff,0x02]
  add $0,$255,$2

# CHECK-INST: add $5,$6,0
# CHECK: encoding: [0x21,0x05,0x06,0x00]
  add $5,$6,0

# CHECK-INST: add $5,$6,255
# CHECK: encoding: [0x21,0x05,0x06,0xff]
  add $5,$6,255
