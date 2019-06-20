; RUN: llvm-mc %s -triple=ebc -show-encoding \
; RUN:    | FileCheck -check-prefixes=CHECK,CHECK-INST %s
; RUN: llvm-mc -filetype=obj -triple=ebc < %s \
; RUN:    | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INST %s

; CHECK-INST: jmp8cc	127                     
; CHECK: encoding: [0x82,0x7f]
jmp8cc	127                     
; CHECK-INST: jmp8cs	-128                    
; CHECK: encoding: [0xc2,0x80]
jmp8cs	-128                    
; CHECK-INST: add64	r1, r2 32767            
; CHECK: encoding: [0xcc,0x21,0xff,0x7f]
add64	r1, r2 32767            
; CHECK-INST: and64	r3, r4 -32768           
; CHECK: encoding: [0xd4,0x43,0x00,0x80]
and64	r3, r4 -32768           
; CHECK-INST: cmpi64deq	r1, 2147483647  
; CHECK: encoding: [0xed,0x01,0xff,0xff,0xff,0x7f]
cmpi64deq	r1, 2147483647  
; CHECK-INST: cmpi64dlte	r2, -2147483648 
; CHECK: encoding: [0xee,0x02,0x00,0x00,0x00,0x80]
cmpi64dlte	r2, -2147483648 
; CHECK-INST: moviqq	r3, 9223372036854775807 
; CHECK: encoding: [0xf7,0x33,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x7f]
moviqq	r3, 9223372036854775807 
; CHECK-INST: moviqq	r4, -9223372036854775808 
; CHECK: encoding: [0xf7,0x34,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80]
moviqq	r4, -9223372036854775808 
