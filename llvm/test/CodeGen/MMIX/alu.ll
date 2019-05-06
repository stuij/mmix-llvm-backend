; RUN: llc -mtriple=mmix -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=I

; Register-immediate instructions

define i64 @add(i64 %a, i64 %b) nounwind {
; I-LABEL: add:
; I:       % %bb.0:
; I-NEXT:    add     $231,$231,$232
; I-NEXT:    pop     0x0,0x0
  %1 = add i64 %a, %b
  ret i64 %1
}

define i64 @addi(i64 %a) nounwind {
; I-LABEL: addi:
; I:       % %bb.0:
; I-NEXT:    add     $231,$231,0x1
; I-NEXT:    pop     0x0,0x0
  %1 = add i64 %a, 1
  ret i64 %1
}
