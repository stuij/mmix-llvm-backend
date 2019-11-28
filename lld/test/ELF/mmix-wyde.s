# REQUIRES: mmix

# RUN: llvm-mc -filetype=obj -triple=mmix-unknown-elf %s -o %t.mmix.o

# RUN: ld.lld %t.mmix.o --defsym foo=0xfeebdaeddeadbeef -o %t.mmix
# RUN: llvm-objdump -d %t.mmix | FileCheck %s
# CHECK: e0 00 fe eb     seth    $0,0xfeeb
# CHECK: e9 00 da ed     ormh    $0,0xdaed
# CHECK: e6 00 de ad     incml   $0,0xdead
# CHECK: ef 00 be ef     andl    $0,0xbeef

.global _start
_start:
  seth  $0,foo
  ormh  $0,foo
  incml $0,foo
  andl  $0,foo
