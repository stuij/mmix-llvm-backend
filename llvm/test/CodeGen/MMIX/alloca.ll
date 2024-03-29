; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mmix -verify-machineinstrs < %s | FileCheck %s

declare void @notdead(i8*)

; These tests must ensure the stack pointer is restored using the frame
; pointer

define void @simple_alloca(i64 %n) nounwind {
; CHECK-LABEL: simple_alloca:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x10
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x8
; CHECK-NEXT:    sto $253,$254,0x0
; CHECK-NEXT:    add $253,$254,0x10
; CHECK-NEXT:    add $16,$231,0xf
; CHECK-NEXT:    neg $17,0x0,0x10
; CHECK-NEXT:    and $16,$16,$17
; CHECK-NEXT:    sub $231,$254,$16
; CHECK-NEXT:    add $254,$231,0x0
; CHECK-NEXT:    seth $16,notdead
; CHECK-NEXT:    ormh $16,notdead
; CHECK-NEXT:    orml $16,notdead
; CHECK-NEXT:    orl $16,notdead
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    sub $254,$253,0x10
; CHECK-NEXT:    ldo $253,$254,0x0
; CHECK-NEXT:    ldo $252,$254,0x8
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    add $254,$254,0x10
; CHECK-NEXT:    pop 0x0,0x0
  %1 = alloca i8, i64 %n
  call void @notdead(i8* %1)
  ret void
}

declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)

define void @scoped_alloca(i64 %n) nounwind {
; CHECK-LABEL: scoped_alloca:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x20
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x18
; CHECK-NEXT:    sto $253,$254,0x10
; CHECK-NEXT:    sto $0,$254,0x8
; CHECK-NEXT:    add $253,$254,0x20
; CHECK-NEXT:    add $16,$231,0xf
; CHECK-NEXT:    neg $17,0x0,0x10
; CHECK-NEXT:    and $16,$16,$17
; CHECK-NEXT:    add $0,$254,0x0
; CHECK-NEXT:    sub $231,$254,$16
; CHECK-NEXT:    add $254,$231,0x0
; CHECK-NEXT:    seth $16,notdead
; CHECK-NEXT:    ormh $16,notdead
; CHECK-NEXT:    orml $16,notdead
; CHECK-NEXT:    orl $16,notdead
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    add $254,$0,0x0
; CHECK-NEXT:    sub $254,$253,0x20
; CHECK-NEXT:    ldo $0,$254,0x8
; CHECK-NEXT:    ldo $253,$254,0x10
; CHECK-NEXT:    ldo $252,$254,0x18
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    add $254,$254,0x20
; CHECK-NEXT:    pop 0x0,0x0
  %sp = call i8* @llvm.stacksave()
  %addr = alloca i8, i64 %n
  call void @notdead(i8* %addr)
  call void @llvm.stackrestore(i8* %sp)
  ret void
}
