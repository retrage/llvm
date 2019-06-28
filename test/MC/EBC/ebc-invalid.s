; RUN: not llvm-mc %s -triple=ebc 2>&1 | FileCheck %s

; Out of range immediates
; breakcode
BREAK -1 ; CHECK: :[[@LINE]]:7: error: break code must be an integer in the range [0, 6]
BREAK 7 ; CHECK: :[[@LINE]]:7: error: break code must be an integer in the range [0, 6]

; imm16
ADD64 r1, r2 -32769 ; CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-32768, 32767]
ADD64 r1, r2 32768 ; CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-32768, 32767]

; imm32
CMPI64deq r1, -2147483649 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-2147483648, 2147483647]
CMPI64deq r1, 2147483648 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-2147483648, 2147483647]

; FIXME: handle INT64_MIN and INT64_MAX
; imm64
; MOVIqq r1, -9223372036854775809
; MOVIqq r1, 9223372036854775808

; imm8_jmp
JMP8 -129 ; CHECK: :[[@LINE]]:6: error: immediate must be an integer in the range [-128, 127]
JMP8 128 ; CHECK: :[[@LINE]]:6: error: immediate must be an integer in the range [-128, 127]

; FIXME: handle INT64_MIN and INT64_MAX
; imm64_jmp
; JMP64 -9223372036854775809
; JMP64 9223372036854775808

; index16
SUB64 r1, @r2 (-4096, 0) ; CHECK: :[[@LINE]]:16: error: immediate must be an integer in the range [-4095, 4095]
SUB64 r1, @r2 (4096, 0) ; CHECK: :[[@LINE]]:16: error: immediate must be an integer in the range [-4095, 4095]
SUB64 r1, @r2 (0, -4096) ; CHECK: :[[@LINE]]:19: error: immediate must be an integer in the range [-4095, 4095]
SUB64 r1, @r2 (0, 4096) ; CHECK: :[[@LINE]]:19: error: immediate must be an integer in the range [-4095, 4095]

; index32
MOVdd @r1 (-268435456, 0), r2 ; CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [-268435455, 268435455]
MOVdd @r1 (268435456, 0), r2 ; CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [-268435455, 268435455]
MOVdd @r1 (0, -268435456), r2 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-268435455, 268435455]
MOVdd @r1 (0, 268435456), r2 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-268435455, 268435455]

; index64
MOVqq @r1 (-72057594037927936, 0), r2 ; CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [-72057594037927935, 72057594037927935]
MOVqq @r1 (72057594037927936, 0), r2 ; CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [-72057594037927935, 72057594037927935]
MOVqq @r1 (0, -72057594037927936), r2 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-72057594037927935, 72057594037927935]
MOVqq @r1 (0, 72057594037927936), r2 ; CHECK: :[[@LINE]]:15: error: immediate must be an integer in the range [-72057594037927935, 72057594037927935]

; Invalid natural index
; index16
MUL64 r1, @r2 (1234, -1234) ; CHECK: :[[@LINE]]:12: error: natural unit and constant unit must have same signs
MUL64 r1, @r2 (-1234, 1234) ; CHECK: :[[@LINE]]:12: error: natural unit and constant unit must have same signs
MUL64 r1, @r2 (4095, 4095) ; CHECK: :[[@LINE]]:12: error: unit length is too long
; index32
MOVdd @r1 (5678, -5678), r2 ; CHECK: :[[@LINE]]:8: error: natural unit and constant unit must have same signs
MOVdd @r1 (-5678, 5678), r2 ; CHECK: :[[@LINE]]:8: error: natural unit and constant unit must have same signs
MOVdd @r1 (268435455, 268435455), r2 ; CHECK: :[[@LINE]]:8: error: unit length is too long
; index64
MOVqq @r1 (268435456, -268435456), r2 ; CHECK: :[[@LINE]]:8: error: natural unit and constant unit must have same signs
MOVqq @r1 (-268435456, 268435456), r2 ; CHECK: :[[@LINE]]:8: error: natural unit and constant unit must have same signs
MOVqq @r1 (70000000000000000, 70000000000000000), r2 ; CHECK: :[[@LINE]]:8: error: unit length is too long

; Invalid mnemonics
ADD r1, r2 ; CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic
SUB r2, r3 ; CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic

; Invalid register names
ADD64 r8, r1 ; CHECK: :[[@LINE]]:7: error: invalid operand for instruction
SUB64 r1, r8 ; CHECK: :[[@LINE]]:11: error: invalid operand for instruction

; Too many operands
JMP8 99, r1 ; CHECK: :[[@LINE]]:10: error: invalid operand for instruction

; Too few operands
ADD64 r1 ; CHECK: :[[@LINE]]:1: error: too few operands for instruction

; Using dedicated registers when general purpose registers are expected
ADD64 ip, r1 ; CHECK: :[[@LINE]]:7: error: invalid operand for instruction
SUB64 r2, flags ; CHECK: :[[@LINE]]:11: error: invalid operand for instruction

; Using general purpose registers when dedicated registers are expected
LOADSP ip, r0 ; CHECK: :[[@LINE]]:8: error: invalid operand for instruction
LOADSP r1, r2 ; CHECK: :[[@LINE]]:8: error: invalid operand for instruction
STORESP r2, r3 ; CHECK: :[[@LINE]]:13: error: invalid operand for instruction
