; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mmix -verify-machineinstrs < %s | FileCheck %s

define i64 @bare_select(i1 %a, i64 %b, i64 %c) {
; CHECK-LABEL: bare_select:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x10
; CHECK-NEXT:    sto $253,$254,0x8
; CHECK-NEXT:    add $253,$254,0x10
; CHECK-NEXT:    and $16,$231,0x1
; CHECK-NEXT:    csp $233,$16,$232
; CHECK-NEXT:    add $231,$233,0x0
; CHECK-NEXT:    ldo $253,$254,0x8
; CHECK-NEXT:    add $254,$254,0x10
; CHECK-NEXT:    pop 0x0,0x0
   %1 = select i1 %a, i64 %b, i64 %c

   ret i64 %1
}

define i64 @setcc_select(i64 %a, i64 *%b) {
; CHECK-LABEL: setcc_select:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x10
; CHECK-NEXT:    sto $253,$254,0x8
; CHECK-NEXT:    add $253,$254,0x10
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    cmp $17,$231,$16
; CHECK-NEXT:    csz $16,$17,$231
; CHECK-NEXT:    ldo $17,$232,0x0
; CHECK-NEXT:    cmp $18,$16,$17
; CHECK-NEXT:    csnz $17,$18,$16
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    cmpu $18,$17,$16
; CHECK-NEXT:    csp $16,$18,$17
; CHECK-NEXT:    ldo $17,$232,0x0
; CHECK-NEXT:    cmpu $18,$16,$17
; CHECK-NEXT:    csnn $17,$18,$16
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    cmpu $18,$17,$16
; CHECK-NEXT:    csn $16,$18,$17
; CHECK-NEXT:    ldo $17,$232,0x0
; CHECK-NEXT:    cmpu $18,$16,$17
; CHECK-NEXT:    csnp $17,$18,$16
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    cmp $18,$17,$16
; CHECK-NEXT:    csp $16,$18,$17
; CHECK-NEXT:    ldo $17,$232,0x0
; CHECK-NEXT:    cmp $18,$16,$17
; CHECK-NEXT:    csnn $17,$18,$16
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    cmp $18,$17,$16
; CHECK-NEXT:    csn $16,$18,$17
; CHECK-NEXT:    ldo $231,$232,0x0
; CHECK-NEXT:    cmp $17,$16,$231
; CHECK-NEXT:    csnp $231,$17,$16
; CHECK-NEXT:    ldo $253,$254,0x8
; CHECK-NEXT:    add $254,$254,0x10
; CHECK-NEXT:    pop 0x0,0x0
  %val1 = load volatile i64, i64* %b
  %tst1 = icmp eq i64 %a, %val1
  %val2 = select i1 %tst1, i64 %a, i64 %val1

  %val3 = load volatile i64, i64* %b
  %tst2 = icmp ne i64 %val2, %val3
  %val4 = select i1 %tst2, i64 %val2, i64 %val3

  %val5 = load volatile i64, i64* %b
  %tst3 = icmp ugt i64 %val4, %val5
  %val6 = select i1 %tst3, i64 %val4, i64 %val5

  %val7 = load volatile i64, i64* %b
  %tst4 = icmp uge i64 %val6, %val7
  %val8 = select i1 %tst4, i64 %val6, i64 %val7

  %val9 = load volatile i64, i64* %b
  %tst5 = icmp ult i64 %val8, %val9
  %val10 = select i1 %tst5, i64 %val8, i64 %val9

  %val11 = load volatile i64, i64* %b
  %tst6 = icmp ule i64 %val10, %val11
  %val12 = select i1 %tst6, i64 %val10, i64 %val11

  %val13 = load volatile i64, i64* %b
  %tst7 = icmp sgt i64 %val12, %val13
  %val14 = select i1 %tst7, i64 %val12, i64 %val13

  %val15 = load volatile i64, i64* %b
  %tst8 = icmp sge i64 %val14, %val15
  %val16 = select i1 %tst8, i64 %val14, i64 %val15

  %val17 = load volatile i64, i64* %b
  %tst9 = icmp slt i64 %val16, %val17
  %val18 = select i1 %tst9, i64 %val16, i64 %val17

  %val19 = load volatile i64, i64* %b
  %tst10 = icmp sle i64 %val18, %val19
  %val20 = select i1 %tst10, i64 %val18, i64 %val19

  ret i64 %val20
}

define i64 @select_eq_zero(i64 %a, i64 *%b) {
; CHECK-LABEL: select_eq_zero:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x10
; CHECK-NEXT:    sto $253,$254,0x8
; CHECK-NEXT:    add $253,$254,0x10
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    csz $16,$16,$231
; CHECK-NEXT:    add $231,$16,0x0
; CHECK-NEXT:    ldo $253,$254,0x8
; CHECK-NEXT:    add $254,$254,0x10
; CHECK-NEXT:    pop 0x0,0x0
  %val1 = load volatile i64, i64* %b
  %tst1 = icmp eq i64 %val1, 0
  %val2 = select i1 %tst1, i64 %a, i64 %val1

  ret i64 %val2
}

define i64 @select_ne_zero(i64 %a, i64 *%b) {
; CHECK-LABEL: select_ne_zero:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sub $254,$254,0x10
; CHECK-NEXT:    sto $253,$254,0x8
; CHECK-NEXT:    add $253,$254,0x10
; CHECK-NEXT:    ldo $16,$232,0x0
; CHECK-NEXT:    csnz $16,$16,$231
; CHECK-NEXT:    add $231,$16,0x0
; CHECK-NEXT:    ldo $253,$254,0x8
; CHECK-NEXT:    add $254,$254,0x10
; CHECK-NEXT:    pop 0x0,0x0
  %val1 = load volatile i64, i64* %b
  %tst1 = icmp ne i64 %val1, 0
  %val2 = select i1 %tst1, i64 %a, i64 %val1

  ret i64 %val2
}
