; RUN: llvm-mc %s -triple=ebc -show-encoding \
; RUN:     | FileCheck -check-prefix=CHECK-FIXUP %s
; RUN: llvm-mc %s -triple=ebc -filetype=obj \
; RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INSTR %s
; RUN: llvm-mc %s -triple=ebc -filetype=obj \
; RUN:     | llvm-readobj -r | FileCheck -check-prefix=CHECK-REL %s

; Checks that fixups that can be resolved within the same object file are
; applied correctly

.LBB0:
MOVRELw r1, .LBB2 ; 4
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB2, kind: fixup_ebc_movrelw
; CHECK-INSTR: movrelw  r1, 32766
MOVRELd r2, .LBB3 ; 6
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB3, kind: fixup_ebc_movreld
; CHECK-INSTR: movreld  r2, 32762
MOVRELq r3, .LBB4 ; 10
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB4, kind: fixup_ebc_movrelq
; CHECK-INSTR: movrelq  r3, 32756

JMP8 .LBB0    ; 2
; CHECK-FIXUP: fixup A - offset: 1, value: .LBB0, kind: fixup_ebc_jmp8
; CHECK-INSTR: jmp8 -11 
JMP8cs .LBB1  ; 2
; CHECK-FIXUP: fixup A - offset: 1, value: .LBB1, kind: fixup_ebc_jmp8
; CHECK-INSTR: jmp8cs 127
JMP64 .LBB0   ; 10 
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB0, kind: fixup_ebc_jmp64rel
; CHECK-INSTR: jmp64  -34
JMP64cs .LBB2 ; 10
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB2, kind: fixup_ebc_jmp64rel
; CHECK-INSTR: jmp64cs  32726

CALL64 .LBB0  ; 10
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB0, kind: fixup_ebc_call64rel
; CHECK-INSTR: call64 -54
CALL64 .LBB2  ; 10
; CHECK-FIXUP: fixup A - offset: 2, value: .LBB2, kind: fixup_ebc_call64rel
; CHECK-INSTR: call64 32706

.fill 214
.LBB1: ; 256
MOVqq r0, r0

.fill 32490
.LBB2: ; 32770
.short 0x1234

.LBB3:
.long 0x12345678

.LBB4:
.quad 0x0123456789abcdef

; CHECK-REL-NOT: R_EBC
