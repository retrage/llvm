; RUN: llvm-mc %s -triple=ebc -show-encoding \
; RUN:    | FileCheck -check-prefixes=CHECK,CHECK-INST %s
; RUN: llvm-mc -filetype=obj -triple=ebc < %s \
; RUN:    | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INST %s

; CHECK-INST: .text
.text

; CHECK-INST: add64 r1, @r2 (4095,0)
; CHECK encoding: [0xcc,0xa1,0xff,0x6f]
ADD64 r1, @r2 (4095, 0)
; CHECK-INST: add64 r1, @r2 (-4095,0)
; CHECK encoding: [0xcc,0xa1,0xff,0xef]
ADD64 r1, @r2 (-4095, 0)
; CHECK-INST: add64 r1, @r2 (0,4095)
; CHECK encoding: [0xcc,0xa1,0xff,0x0f]
ADD64 r1, @r2 (0,4095)
; CHECK-INST: add64 r1, @r2 (0,-4095)
; CHECK encoding: [0xcc,0xa1,0xff,0x8f]
ADD64 r1, @r2 (0, -4095)

; CHECK-INST: jmp32 @r1 (268435455,0)
; CHECK encoding: [0x81,0x09,0xff,0xff,0xff,0x7f]
JMP32 @r1 (268435455, 0)
; CHECK-INST: jmp32 @r1 (-268435455,0)
; CHECK encoding: [0x81,0x09,0xff,0xff,0xff,0xff]
JMP32 @r1 (-268435455, 0)
; CHECK-INST: jmp32 @r1 (0,268435455)
; CHECK encoding: [0x81,0x09,0xff,0xff,0xff,0x0f]
JMP32 @r1 (0, 268435455)
; CHECK-INST: jmp32 @r1 (0,-268435455)
; CHECK encoding: [0x81,0x09,0xff,0xff,0xff,0x8f]
JMP32 @r1 (0, -268435455)

; CHECK-INST: movqq r1, r2 (72057594037927935,0)
; CHECK encoding: [0x68,0x21,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x70]
MOVqq r1, r2 (72057594037927935, 0)
; CHECK-INST: movqq r1, r2 (-72057594037927935,0)
; CHECK encoding: [0x68,0x21,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xf0]
MOVqq r1, r2 (-72057594037927935, 0)
; CHECK-INST: movqq r1, r2 (0,72057594037927935)
; CHECK encoding: [0x68,0x21,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00]
MOVqq r1, r2 (0, 72057594037927935)
; CHECK-INST: movqq r1, r2 (0,-72057594037927935)
; CHECK encoding: [0x68,0x21,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x80]
MOVqq r1, r2 (0, -72057594037927935)
