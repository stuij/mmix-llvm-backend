# REQUIRES: mmix

# RUN: llvm-mc -filetype=obj -triple=mmix-unknown-elf %s -o %t.mmix.o

# RUN: ld.lld %t.mmix.o --defsym foo=_start --defsym bar=_start -o %t.mmix
# RUN: llvm-objdump -d %t.mmix | FileCheck %s
# CHECK: 40 00 00 00     bn    $0,0x0
# CHECK: 49 00 ff ff     bnn   $0,-0x4

# RUN: ld.lld %t.mmix.o --defsym foo=_start-0x40000 --defsym bar=_start+0x40000 -o %t.mmix.limits
# RUN: llvm-objdump -d %t.mmix.limits | FileCheck --check-prefix=LIMITS %s
# LIMITS: 41 00 00 00     bn    $0,-0x40000
# LIMITS: 48 00 ff ff     bnn   $0,0x3fffc

# RUN: not ld.lld %t.mmix.o --defsym foo=_start-0x40004 --defsym bar=_start+0x40004 -o %t 2>&1 | FileCheck --check-prefix=ERROR-RANGE %s
# ERROR-RANGE: R_MMIX_REL_16: fixup value out of range
# ERROR-RANGE: R_MMIX_REL_16: fixup value out of range

# RUN: not ld.lld %t.mmix.o --defsym foo=_start+0x1 --defsym bar=_start-0x1 -o %t 2>&1 | FileCheck --check-prefix=ERROR-ALIGN %s
# ERROR-ALIGN: improper alignment for relocation R_MMIX_REL_16: 0x1 is not aligned to 4 bytes
.global _start
_start:
     bn $0,foo
     bnn $0,bar
