; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mmix -verify-machineinstrs < %s | FileCheck %s

;; loads
define i64 @load_byte(i8 *%a) nounwind {
; CHECK-LABEL: load_byte:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldb $16,$231,0x0
; CHECK-NEXT:    ldbu $16,$231,0x2
; CHECK-NEXT:    ldb $17,$231,0x1
; CHECK-NEXT:    add $231,$17,$16
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i8, i8* %a, i64 1
  %2 = load i8, i8* %1
  %3 = sext i8 %2 to i64
  ; zext
  %4 = getelementptr i8, i8* %a, i64 2
  %5 = load i8, i8* %4
  %6 = zext i8 %5 to i64
  %7 = add i64 %3, %6
  ; the unused load will produce an anyext for selection
  %8 = load volatile i8, i8* %a
  ret i64 %7
}

define i64 @load_wyde(i16 *%a) nounwind {
; CHECK-LABEL: load_wyde:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldw $16,$231,0x0
; CHECK-NEXT:    ldwu $16,$231,0x8
; CHECK-NEXT:    ldw $17,$231,0x4
; CHECK-NEXT:    add $231,$17,$16
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i16, i16* %a, i64 2
  %2 = load i16, i16* %1
  %3 = sext i16 %2 to i64
  %4 = getelementptr i16, i16* %a, i64 4
  %5 = load i16, i16* %4
  %6 = zext i16 %5 to i64
  %7 = add i64 %3, %6
  ; the unused load will produce an anyext for selection
  %8 = load volatile i16, i16* %a
  ret i64 %7
}

define i64 @load_tetra(i32 *%a) nounwind {
; CHECK-LABEL: load_tetra:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldt $16,$231,0x0
; CHECK-NEXT:    ldtu $16,$231,0x40
; CHECK-NEXT:    ldt $17,$231,0x20
; CHECK-NEXT:    add $231,$17,$16
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i32, i32* %a, i64 8
  %2 = load i32, i32* %1
  %3 = sext i32 %2 to i64
  %4 = getelementptr i32, i32* %a, i64 16
  %5 = load i32, i32* %4
  %6 = zext i32 %5 to i64
  %7 = add i64 %3, %6
  ; the unused load will produce an anyext for selection
  %8 = load volatile i32, i32* %a
  ret i64 %7
}

define i64 @load_octa(i64 *%a) nounwind {
; CHECK-LABEL: load_octa:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldo $231,$231,0xf8
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i64, i64* %a, i64 31
  %2 = load i64, i64* %1
  ret i64 %2
}


;; stores
define void @store_byte(i8 *%a, i8 %b) nounwind {
; CHECK-LABEL: store_byte:
; CHECK:       % %bb.0:
; CHECK-NEXT:    stb $232,$231,0x4
; CHECK-NEXT:    stb $232,$231,0x0
; CHECK-NEXT:    pop 0x0,0x0
  store i8 %b, i8* %a
  %1 = getelementptr i8, i8* %a, i64 4
  store i8 %b, i8* %1
  ret void
}

define void @store_wyde(i16 *%a, i16 %b) nounwind {
; CHECK-LABEL: store_wyde:
; CHECK:       % %bb.0:
; CHECK-NEXT:    stw $232,$231,0x8
; CHECK-NEXT:    stw $232,$231,0x0
; CHECK-NEXT:    pop 0x0,0x0
  store i16 %b, i16* %a
  %1 = getelementptr i16, i16* %a, i64 4
  store i16 %b, i16* %1
  ret void
}

define void @store_tetra(i32 *%a, i32 %b) nounwind {
; CHECK-LABEL: store_tetra:
; CHECK:       % %bb.0:
; CHECK-NEXT:    stt $232,$231,0x10
; CHECK-NEXT:    stt $232,$231,0x0
; CHECK-NEXT:    pop 0x0,0x0
  store i32 %b, i32* %a
  %1 = getelementptr i32, i32* %a, i64 4
  store i32 %b, i32* %1
  ret void
}

define void @store_octa(i64 *%a, i64 %b) nounwind {
; CHECK-LABEL: store_octa:
; CHECK:       % %bb.0:
; CHECK-NEXT:    sto $232,$231,0x20
; CHECK-NEXT:    sto $232,$231,0x0
; CHECK-NEXT:    pop 0x0,0x0
  store i64 %b, i64* %a
  %1 = getelementptr i64, i64* %a, i64 4
  store i64 %b, i64* %1
  ret void
}


;; check larger memory offsets
define i64 @load_medium_range(i8 *%a) nounwind {
; CHECK-LABEL: load_medium_range:
; CHECK:       % %bb.0:
; CHECK-NEXT:    setl $16,0x100
; CHECK-NEXT:    add $16,$231,$16
; CHECK-NEXT:    ldb $231,$16,0x0
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i8, i8* %a, i64 256
  %2 = load i8, i8* %1
  %3 = sext i8 %2 to i64
  ret i64 %3
}

define i64 @load_long_range(i8 *%a) nounwind {
; CHECK-LABEL: load_long_range:
; CHECK:       % %bb.0:
; CHECK-NEXT:    setl $16,0xeeff
; CHECK-NEXT:    orml $16,0xccdd
; CHECK-NEXT:    ormh $16,0xaabb
; CHECK-NEXT:    orh $16,0x8899
; CHECK-NEXT:    add $16,$231,$16
; CHECK-NEXT:    ldb $231,$16,0x0
; CHECK-NEXT:    pop 0x0,0x0
  %1 = getelementptr i8, i8* %a, i64 9843086184167632639
  %2 = load i8, i8* %1
  %3 = sext i8 %2 to i64
  ret i64 %3
}


; Check load and store to an i1 location
define i64 @load_sext_zext_anyext_i1(i1 *%a) nounwind {
; CHECK-LABEL: load_sext_zext_anyext_i1:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldb $16,$231,0x0
; CHECK-NEXT:    ldbu $16,$231,0x1
; CHECK-NEXT:    ldbu $17,$231,0x2
; CHECK-NEXT:    sub $231,$17,$16
; CHECK-NEXT:    pop 0x0,0x0
  ; sextload i1
  %1 = getelementptr i1, i1* %a, i64 1
  %2 = load i1, i1* %1
  %3 = sext i1 %2 to i64
  ; zextload i1
  %4 = getelementptr i1, i1* %a, i64 2
  %5 = load i1, i1* %4
  %6 = zext i1 %5 to i64
  %7 = add i64 %3, %6
  ; extload i1 (anyext). Produced as the load is unused.
  %8 = load volatile i1, i1* %a
  ret i64 %7
}

define i16 @load_sext_zext_anyext_i1_i16(i1 *%a) nounwind {
; CHECK-LABEL: load_sext_zext_anyext_i1_i16:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldb $16,$231,0x0
; CHECK-NEXT:    ldbu $16,$231,0x1
; CHECK-NEXT:    ldbu $17,$231,0x2
; CHECK-NEXT:    sub $231,$17,$16
; CHECK-NEXT:    pop 0x0,0x0
  ; sextload i1
  %1 = getelementptr i1, i1* %a, i64 1
  %2 = load i1, i1* %1
  %3 = sext i1 %2 to i16
  ; zextload i1
  %4 = getelementptr i1, i1* %a, i64 2
  %5 = load i1, i1* %4
  %6 = zext i1 %5 to i16
  %7 = add i16 %3, %6
  ; extload i1 (anyext). Produced as the load is unused.
  %8 = load volatile i1, i1* %a
  ret i16 %7
}

; Check load and store to a global
@G = global i64 0

define i64 @lw_sw_global(i64 %a) nounwind {
; CHECK-LABEL: lw_sw_global:
; CHECK:       % %bb.0:
; CHECK-NEXT:    seth $17,G
; CHECK-NEXT:    ormh $17,G
; CHECK-NEXT:    orml $17,G
; CHECK-NEXT:    orl $17,G
; CHECK-NEXT:    ldo $16,$17,0x0
; CHECK-NEXT:    sto $231,$17,0x0
; CHECK-NEXT:    seth $17,G+72
; CHECK-NEXT:    ormh $17,G+72
; CHECK-NEXT:    orml $17,G+72
; CHECK-NEXT:    orl $17,G+72
; CHECK-NEXT:    ldo $18,$17,0x0
; CHECK-NEXT:    sto $231,$17,0x0
; CHECK-NEXT:    add $231,$16,0x0
; CHECK-NEXT:    pop 0x0,0x0
  %1 = load volatile i64, i64* @G
  store i64 %a, i64* @G
  %2 = getelementptr i64, i64* @G, i64 9
  %3 = load volatile i64, i64* %2
  store i64 %a, i64* %2
  ret i64 %1
}


; Check load/store operations on values wider than what is natively supported

define i128 @load_i128(i128 *%a) nounwind {
; CHECK-LABEL: load_i128:
; CHECK:       % %bb.0:
; CHECK-NEXT:    ldo $16,$231,0x0
; CHECK-NEXT:    ldo $232,$231,0x8
; CHECK-NEXT:    add $231,$16,0x0
; CHECK-NEXT:    pop 0x0,0x0
  %1 = load i128, i128* %a
  ret i128 %1
}

@val128 = local_unnamed_addr global i128 340282366920938463463374607431768211456, align 8

define i128 @load_i128_global() nounwind {
; CHECK-LABEL: load_i128_global:
; CHECK:       % %bb.0:
; CHECK-NEXT:    seth $16,val128
; CHECK-NEXT:    ormh $16,val128
; CHECK-NEXT:    orml $16,val128
; CHECK-NEXT:    orl $16,val128
; CHECK-NEXT:    ldo $231,$16,0x0
; CHECK-NEXT:    seth $16,val128+8
; CHECK-NEXT:    ormh $16,val128+8
; CHECK-NEXT:    orml $16,val128+8
; CHECK-NEXT:    orl $16,val128+8
; CHECK-NEXT:    ldo $232,$16,0x0
; CHECK-NEXT:    pop 0x0,0x0
  %1 = load i128, i128* @val128
  ret i128 %1
}
