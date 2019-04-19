# RUN: llvm-mc %s -filetype=obj -triple=mmix | llvm-readobj -h | FileCheck %s

# CHECK: Format: ELF64-mmix
# CHECK: Arch: mmix
# CHECK: AddressSize: 64bit
# CHECK: ElfHeader {
# CHECK:   Ident {
# CHECK:     Magic: (7F 45 4C 46)
# CHECK:     Class: 64-bit (0x2)
# CHECK:     DataEncoding: BigEndian (0x2)
# CHECK:     FileVersion: 1
# CHECK:     OS/ABI: SystemV (0x0)
# CHECK:     ABIVersion: 0
# CHECK:   }
# CHECK:   Type: Relocatable (0x1)
# CHECK:   Machine: EM_MMIX (0x50)
# CHECK:   Version: 1
# CHECK:   Flags [ (0x0)
# CHECK:   ]
# CHECK: }
