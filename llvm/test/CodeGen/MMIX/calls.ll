; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mmix -verify-machineinstrs < %s | FileCheck %s

declare i64 @external_function(i64)

define i64 @test_call_external(i64 %a) nounwind {
; CHECK-LABEL: test_call_external:
; CHECK:       % %bb.0:
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x8
; CHECK-NEXT:    seth $16,external_function
; CHECK-NEXT:    ormh $16,external_function
; CHECK-NEXT:    orml $16,external_function
; CHECK-NEXT:    orl $16,external_function
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    ldo $252,$254,0x8
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    pop 0x0,0x0
  %1 = call i64 @external_function(i64 %a)
  ret i64 %1
}

define i32 @defined_function(i32 %a) nounwind {
; CHECK-LABEL: defined_function:
; CHECK:       % %bb.0:
; CHECK-NEXT:    add $231,$231,0x1
; CHECK-NEXT:    pop 0x0,0x0
  %1 = add i32 %a, 1
  ret i32 %1
}

define i32 @test_call_defined(i32 %a) nounwind {
; CHECK-LABEL: test_call_defined:
; CHECK:       % %bb.0:
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x8
; CHECK-NEXT:    seth $16,defined_function
; CHECK-NEXT:    ormh $16,defined_function
; CHECK-NEXT:    orml $16,defined_function
; CHECK-NEXT:    orl $16,defined_function
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    ldo $252,$254,0x8
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    pop 0x0,0x0
  %1 = call i32 @defined_function(i32 %a) nounwind
  ret i32 %1
}

define i32 @test_call_indirect(i32 (i32)* %a, i32 %b) nounwind {
; CHECK-LABEL: test_call_indirect:
; CHECK:       % %bb.0:
; CHECK-NEXT:    get $252,rJ
; CHECK-NEXT:    sto $252,$254,0x8
; CHECK-NEXT:    add $16,$231,0x0
; CHECK-NEXT:    add $231,$232,0x0
; CHECK-NEXT:    pushgo $0,$16,0x0
; CHECK-NEXT:    ldo $252,$254,0x8
; CHECK-NEXT:    put rJ,$252
; CHECK-NEXT:    pop 0x0,0x0
  %1 = call i32 %a(i32 %b)
  ret i32 %1
}
