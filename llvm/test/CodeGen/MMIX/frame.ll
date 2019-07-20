; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mmix -verify-machineinstrs < %s | FileCheck %s

%struct.key_t = type { i32, [16 x i8] }

; FIXME: prologue and epilogue insertion must be implemented to complete this
; test

define i32 @test() nounwind {
; CHECK-LABEL: test:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x30
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x28
; CHECK-NEXT:    sto $253,$254,0x20
; CHECK-NEXT:    sto $0,$254,0x18
; CHECK-NEXT:    add $253,$254,0x30
; CHECK-NEXT:    setl $0,0x0
; CHECK-NEXT:    neg $16,0x0,0x20
; CHECK-NEXT:    stt $0,$253,$16
; CHECK-NEXT:    neg $16,0x0,0x28
; CHECK-NEXT:    sto $0,$253,$16
; CHECK-NEXT:    neg $16,0x0,0x30
; CHECK-NEXT:    sto $0,$253,$16
; CHECK-NEXT:    sub $231,$253,0x2c
; CHECK-NEXT:    seth $16,test1
; CHECK-NEXT:    ormh $16,test1
; CHECK-NEXT:    orml $16,test1
; CHECK-NEXT:    orl $16,test1
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    add $231,$0,0x0
; CHECK-NEXT:    ldo $0,$254,0x18
; CHECK-NEXT:    ldo $253,$254,0x20
; CHECK-NEXT:    ldo $252,$254,0x28
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    add $254,$254,0x30
; CHECK-NEXT:    pop 0x0,0x0
  %key = alloca %struct.key_t, align 4
  %1 = bitcast %struct.key_t* %key to i8*
  call void @llvm.memset.p0i8.i64(i8* %1, i8 0, i64 20, i32 4, i1 false)
  %2 = getelementptr inbounds %struct.key_t, %struct.key_t* %key, i64 0, i32 1, i64 0
  call void @test1(i8* %2) #3
  ret i32 0
}

declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1)

declare void @test1(i8*)
