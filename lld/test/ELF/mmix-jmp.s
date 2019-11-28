# REQUIRES: mmix

# RUN: llvm-mc -filetype=obj -triple=mmix-unknown-elf %s -o %t.mmix.o

# RUN: ld.lld %t.mmix.o --defsym foo=_start --defsym bar=_start -o %t.mmix
# RUN: llvm-objdump -d %t.mmix | FileCheck %s
# CHECK: f0 00 00 00     jmp    0x0
# CHECK: f1 ff ff ff     jmp   -0x4

# RUN: ld.lld %t.mmix.o --defsym foo=_start-0x4000000 --defsym bar=_start+0x4000000 -o %t.mmix.limits
# RUN: llvm-objdump -d %t.mmix.limits | FileCheck --check-prefix=LIMITS %s
# LIMITS: f1 00 00 00     jmp   -0x4000000
# LIMITS: f0 ff ff ff     jmp    0x3fffffc

# RUN: not ld.lld %t.mmix.o --defsym foo=_start-0x4000004 --defsym bar=_start+0x4000004 -o %t 2>&1 | FileCheck --check-prefix=ERROR-RANGE %s
# ERROR-RANGE: R_MMIX_REL_24: fixup value out of range
# ERROR-RANGE: R_MMIX_REL_24: fixup value out of range

# RUN: not ld.lld %t.mmix.o --defsym foo=_start+0x1 --defsym bar=_start-0x1 -o %t 2>&1 | FileCheck --check-prefix=ERROR-ALIGN %s
# ERROR-ALIGN: improper alignment for relocation R_MMIX_REL_24: 0x1 is not aligned to 4 bytes
.global _start
_start:
     jmp foo
     jmp bar
