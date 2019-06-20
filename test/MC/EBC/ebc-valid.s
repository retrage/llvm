; RUN: llvm-mc %s -triple=ebc -show-encoding \
; RUN:    | FileCheck -check-prefixes=CHECK,CHECK-INST %s
; RUN: llvm-mc -filetype=obj -triple=ebc < %s \
; RUN:    | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INST %s

; CHECK-INST: ret	                        
; CHECK: encoding: [0x04,0x00]
ret	                        
; CHECK-INST: break	0                       
; CHECK: encoding: [0x00,0x00]
break	0                       
; CHECK-INST: loadsp	flags, r1               
; CHECK: encoding: [0x29,0x10]
loadsp	flags, r1               
; CHECK-INST: storesp	r7, ip                  
; CHECK: encoding: [0x2a,0x17]
storesp	r7, ip                  

; CHECK-INST: push32	r2                      
; CHECK: encoding: [0x2b,0x02]
push32	r2                      
; CHECK-INST: pop64	r3                      
; CHECK: encoding: [0x6c,0x03]
pop64	r3                      
; CHECK-INST: push64	@r1                     
; CHECK: encoding: [0x6b,0x09]
push64	@r1                     
; CHECK-INST: pop32	@r0                     
; CHECK: encoding: [0x2c,0x08]
pop32	@r0                     
; CHECK-INST: pop64	r1 4660                 
; CHECK: encoding: [0xec,0x01,0x34,0x12]
pop64	r1 4660                 
; CHECK-INST: push32	r4 291                  
; CHECK: encoding: [0xab,0x04,0x23,0x01]
push32	r4 291                  
; CHECK-INST: popn	r5                      
; CHECK: encoding: [0x36,0x05]
popn	r5                      
; CHECK-INST: pushn	r6 291                  
; CHECK: encoding: [0xb5,0x06,0x23,0x01]
pushn	r6 291                  
; CHECK-INST: push32	@r2 (42,21)             
; CHECK: encoding: [0xab,0x0a,0x6a,0x35]
push32	@r2 (42,21)             

; CHECK-INST: add32	r1, r2                  
; CHECK: encoding: [0x0c,0x21]
add32	r1, r2                  
; CHECK-INST: sub64	@r3, r4                 
; CHECK: encoding: [0x4d,0x4b]
sub64	@r3, r4                 
; CHECK-INST: mul64	r5, @r6                 
; CHECK: encoding: [0x4e,0xe5]
mul64	r5, @r6                 
; CHECK-INST: divu32	@r7, @r0                
; CHECK: encoding: [0x11,0x8f]
divu32	@r7, @r0                
; CHECK-INST: mod32	r2, r3 4660             
; CHECK: encoding: [0x92,0x32,0x34,0x12]
mod32	r2, r3 4660             
; CHECK-INST: and64	@r5, r4 22136           
; CHECK: encoding: [0xd4,0x4d,0x78,0x56]
and64	@r5, r4 22136           
; CHECK-INST: or64	r2, @r1 (15,18)         
; CHECK: encoding: [0xd5,0x92,0x2f,0x21]
or64	r2, @r1 (15,18)         
; CHECK-INST: shl32	@r7, @r2 (-22,-44)      
; CHECK: encoding: [0x97,0xaf,0x16,0xbb]
shl32	@r7, @r2 (-22,-44)      

; CHECK-INST: cmp32eq	r2, r3                  
; CHECK: encoding: [0x05,0x32]
cmp32eq	r2, r3                  
; CHECK-INST: cmp64lte	r4, @r5         
; CHECK: encoding: [0x46,0xd4]
cmp64lte	r4, @r5         
; CHECK-INST: cmp64gte	r2, r5 13398    
; CHECK: encoding: [0xc7,0x52,0x56,0x34]
cmp64gte	r2, r5 13398    
; CHECK-INST: cmp64ulte	r3, @r6 (0,0)   
; CHECK: encoding: [0xc8,0xe3,0x00,0x80]
cmp64ulte	r3, @r6 (0,0)   

; CHECK-INST: jmp8	1                       
; CHECK: encoding: [0x02,0x01]
jmp8	1                       
; CHECK-INST: jmp8cc	-2                      
; CHECK: encoding: [0x82,0xfe]
jmp8cc	-2                      
; CHECK-INST: jmp8cs	0                       
; CHECK: encoding: [0xc2,0x00]
jmp8cs	0                       
; CHECK-INST: jmp32	r0                      
; CHECK: encoding: [0x01,0x10]
jmp32	r0                      
; CHECK-INST: jmp32cc	r1                      
; CHECK: encoding: [0x01,0x91]
jmp32cc	r1                      
; CHECK-INST: jmp32cs	r2                      
; CHECK: encoding: [0x01,0xd2]
jmp32cs	r2                      
; CHECK-INST: jmp32a	r3                      
; CHECK: encoding: [0x01,0x03]
jmp32a	r3                      
; CHECK-INST: jmp32cca	r4              
; CHECK: encoding: [0x01,0x84]
jmp32cca	r4              
; CHECK-INST: jmp32csa	r5              
; CHECK: encoding: [0x01,0xc5]
jmp32csa	r5              
; CHECK-INST: jmp32	@r0                     
; CHECK: encoding: [0x01,0x18]
jmp32	@r0                     
; CHECK-INST: jmp32cc	@r1                     
; CHECK: encoding: [0x01,0x99]
jmp32cc	@r1                     
; CHECK-INST: jmp32cs	@r2                     
; CHECK: encoding: [0x01,0xda]
jmp32cs	@r2                     
; CHECK-INST: jmp32a	@r3                     
; CHECK: encoding: [0x01,0x0b]
jmp32a	@r3                     
; CHECK-INST: jmp32cca	@r4             
; CHECK: encoding: [0x01,0x8c]
jmp32cca	@r4             
; CHECK-INST: jmp32csa	@r5             
; CHECK: encoding: [0x01,0xcd]
jmp32csa	@r5             
; CHECK-INST: jmp32	r0 305419896            
; CHECK: encoding: [0x81,0x10,0x78,0x56,0x34,0x12]
jmp32	r0 305419896            
; CHECK-INST: jmp32cc	r1 305419896            
; CHECK: encoding: [0x81,0x91,0x78,0x56,0x34,0x12]
jmp32cc	r1 305419896            
; CHECK-INST: jmp32cs	r2 305419896            
; CHECK: encoding: [0x81,0xd2,0x78,0x56,0x34,0x12]
jmp32cs	r2 305419896            
; CHECK-INST: jmp32a	r3 305419896            
; CHECK: encoding: [0x81,0x03,0x78,0x56,0x34,0x12]
jmp32a	r3 305419896            
; CHECK-INST: jmp32cca	r4 305419896    
; CHECK: encoding: [0x81,0x84,0x78,0x56,0x34,0x12]
jmp32cca	r4 305419896    
; CHECK-INST: jmp32csa	r5 305419896    
; CHECK: encoding: [0x81,0xc5,0x78,0x56,0x34,0x12]
jmp32csa	r5 305419896    
; CHECK-INST: jmp32	@r0 (123,345)           
; CHECK: encoding: [0x81,0x18,0x7b,0x59,0x01,0x20]
jmp32	@r0 (123,345)           
; CHECK-INST: jmp32cc	@r1 (123,345)           
; CHECK: encoding: [0x81,0x99,0x7b,0x59,0x01,0x20]
jmp32cc	@r1 (123,345)           
; CHECK-INST: jmp32cs	@r2 (123,345)           
; CHECK: encoding: [0x81,0xda,0x7b,0x59,0x01,0x20]
jmp32cs	@r2 (123,345)           
; CHECK-INST: jmp32a	@r3 (123,345)           
; CHECK: encoding: [0x81,0x0b,0x7b,0x59,0x01,0x20]
jmp32a	@r3 (123,345)           
; CHECK-INST: jmp32cca	@r4 (123,345)   
; CHECK: encoding: [0x81,0x8c,0x7b,0x59,0x01,0x20]
jmp32cca	@r4 (123,345)   
; CHECK-INST: jmp32csa	@r5 (123,345)   
; CHECK: encoding: [0x81,0xcd,0x7b,0x59,0x01,0x20]
jmp32csa	@r5 (123,345)   
; CHECK-INST: jmp64a	81985529216486895       
; CHECK: encoding: [0xc1,0x00,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
jmp64a	81985529216486895       
; CHECK-INST: jmp64	81985529216486895       
; CHECK: encoding: [0xc1,0x10,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
jmp64	81985529216486895       

; CHECK-INST: call32	r0                      
; CHECK: encoding: [0x03,0x10]
call32	r0                      
; CHECK-INST: call32	@r1                     
; CHECK: encoding: [0x03,0x19]
call32	@r1                     
; CHECK-INST: call32	r2 19088743             
; CHECK: encoding: [0x83,0x12,0x67,0x45,0x23,0x01]
call32	r2 19088743             
; CHECK-INST: call32	@r3 (12,345)            
; CHECK: encoding: [0x83,0x1b,0x9c,0x15,0x00,0x10]
call32	@r3 (12,345)            
; CHECK-INST: call32a	r0                      
; CHECK: encoding: [0x03,0x00]
call32a	r0                      
; CHECK-INST: call32a	@r1                     
; CHECK: encoding: [0x03,0x09]
call32a	@r1                     
; CHECK-INST: call32a	r2 19088743             
; CHECK: encoding: [0x83,0x02,0x67,0x45,0x23,0x01]
call32a	r2 19088743             
; CHECK-INST: call32a	@r3 (12,345)            
; CHECK: encoding: [0x83,0x0b,0x9c,0x15,0x00,0x10]
call32a	@r3 (12,345)            
; CHECK-INST: call64	81985529216486895       
; CHECK: encoding: [0xc3,0x10,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
call64	81985529216486895       
; CHECK-INST: call64a	81985529216486895       
; CHECK: encoding: [0xc3,0x00,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
call64a	81985529216486895       

; CHECK-INST: cmpi32weq	r0, 291         
; CHECK: encoding: [0x2d,0x00,0x23,0x01]
cmpi32weq	r0, 291         
; CHECK-INST: cmpi32wlte	@r1, 4660       
; CHECK: encoding: [0x2e,0x09,0x34,0x12]
cmpi32wlte	@r1, 4660       
; CHECK-INST: cmpi32wgte	@r1 (12,45), 291 
; CHECK: encoding: [0x2f,0x19,0xdc,0x22,0x23,0x01]
cmpi32wgte	@r1 (12,45), 291 
; CHECK-INST: cmpi32deq	r0, 19088743    
; CHECK: encoding: [0xad,0x00,0x67,0x45,0x23,0x01]
cmpi32deq	r0, 19088743    
; CHECK-INST: cmpi32dulte	@r1, 19088743   
; CHECK: encoding: [0xb0,0x09,0x67,0x45,0x23,0x01]
cmpi32dulte	@r1, 19088743   
; CHECK-INST: cmpi32dugte	@r1 (12,45), 19088743 
; CHECK: encoding: [0xb1,0x19,0xdc,0x22,0x67,0x45,0x23,0x01]
cmpi32dugte	@r1 (12,45), 19088743 

; CHECK-INST: movnw	r0, r1                  
; CHECK: encoding: [0x32,0x10]
movnw	r0, r1                  
; CHECK-INST: movnw	@r2, r3                 
; CHECK: encoding: [0x32,0x3a]
movnw	@r2, r3                 
; CHECK-INST: movnw	r4, @r5                 
; CHECK: encoding: [0x32,0xd4]
movnw	r4, @r5                 
; CHECK-INST: movnw	@r6, @r7                
; CHECK: encoding: [0x32,0xfe]
movnw	@r6, @r7                
; CHECK-INST: movnw	@r2 (12,34), r3         
; CHECK: encoding: [0xb2,0x3a,0x2c,0x22]
movnw	@r2 (12,34), r3         
; CHECK-INST: movnw	r4, @r5 (12,34)         
; CHECK: encoding: [0x72,0xd4,0x2c,0x22]
movnw	r4, @r5 (12,34)         
; CHECK-INST: movnw	@r6 (12,34), @r7 (-12,-34) 
; CHECK: encoding: [0xf2,0xfe,0x2c,0x22,0x2c,0xa2]
movnw	@r6 (12,34), @r7 (-12,-34) 
; CHECK-INST: movnd	r0, r1                  
; CHECK: encoding: [0x33,0x10]
movnd	r0, r1                  
; CHECK-INST: movnd	@r2, r3                 
; CHECK: encoding: [0x33,0x3a]
movnd	@r2, r3                 
; CHECK-INST: movnd	r4, @r5                 
; CHECK: encoding: [0x33,0xd4]
movnd	r4, @r5                 
; CHECK-INST: movnd	@r6, @r7                
; CHECK: encoding: [0x33,0xfe]
movnd	@r6, @r7                
; CHECK-INST: movnd	@r2 (12,34), r3         
; CHECK: encoding: [0xb3,0x3a,0x2c,0x02,0x00,0x10]
movnd	@r2 (12,34), r3         
; CHECK-INST: movnd	r4, @r5 (12,34)         
; CHECK: encoding: [0x73,0xd4,0x2c,0x02,0x00,0x10]
movnd	r4, @r5 (12,34)         
; CHECK-INST: movnd	@r6 (12,34), @r7 (-12,-34) 
; CHECK: encoding: [0xf3,0xfe,0x2c,0x02,0x00,0x10,0x2c,0x02,0x00,0x90]
movnd	@r6 (12,34), @r7 (-12,-34) 

; CHECK-INST: movrelw	r0, 4660                
; CHECK: encoding: [0x79,0x00,0x34,0x12]
movrelw	r0, 4660                
; CHECK-INST: movrelw	@r1, 4660               
; CHECK: encoding: [0x79,0x09,0x34,0x12]
movrelw	@r1, 4660               
; CHECK-INST: movrelw	@r2 (12,34), 4660       
; CHECK: encoding: [0x79,0x4a,0x2c,0x22,0x34,0x12]
movrelw	@r2 (12,34), 4660       
; CHECK-INST: movreld	r0, 305419896           
; CHECK: encoding: [0xb9,0x00,0x78,0x56,0x34,0x12]
movreld	r0, 305419896           
; CHECK-INST: movreld	@r1, 305419896          
; CHECK: encoding: [0xb9,0x09,0x78,0x56,0x34,0x12]
movreld	@r1, 305419896          
; CHECK-INST: movreld	@r2 (12,34), 305419896  
; CHECK: encoding: [0xb9,0x4a,0x2c,0x22,0x78,0x56,0x34,0x12]
movreld	@r2 (12,34), 305419896  
; CHECK-INST: movrelq	r0, 81985529216486895   
; CHECK: encoding: [0xf9,0x00,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movrelq	r0, 81985529216486895   
; CHECK-INST: movrelq	@r1, 81985529216486895  
; CHECK: encoding: [0xf9,0x09,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movrelq	@r1, 81985529216486895  
; CHECK-INST: movrelq	@r2 (12,34), 81985529216486895 
; CHECK: encoding: [0xf9,0x4a,0x2c,0x22,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movrelq	@r2 (12,34), 81985529216486895 

; CHECK-INST: movsnw	r0, r1                  
; CHECK: encoding: [0x25,0x10]
movsnw	r0, r1                  
; CHECK-INST: movsnw	@r2, r3                 
; CHECK: encoding: [0x25,0x3a]
movsnw	@r2, r3                 
; CHECK-INST: movsnw	r4, @r5                 
; CHECK: encoding: [0x25,0xd4]
movsnw	r4, @r5                 
; CHECK-INST: movsnw	@r6, @r7                
; CHECK: encoding: [0x25,0xfe]
movsnw	@r6, @r7                
; CHECK-INST: movsnw	r0, r1 4660             
; CHECK: encoding: [0x65,0x10,0x34,0x12]
movsnw	r0, r1 4660             
; CHECK-INST: movsnw	@r2, r3 4660            
; CHECK: encoding: [0x65,0x3a,0x34,0x12]
movsnw	@r2, r3 4660            
; CHECK-INST: movsnw	r4, @r5 (12,34)         
; CHECK: encoding: [0x65,0xd4,0x2c,0x22]
movsnw	r4, @r5 (12,34)         
; CHECK-INST: movsnw	@r6, @r7 (12,34)        
; CHECK: encoding: [0x65,0xfe,0x2c,0x22]
movsnw	@r6, @r7 (12,34)        
; CHECK-INST: movsnw	@r6 (-12,-34), @r7 (12,34) 
; CHECK: encoding: [0xe5,0xfe,0x2c,0xa2,0x2c,0x22]
movsnw	@r6 (-12,-34), @r7 (12,34) 

; CHECK-INST: movsnd	r0, r1                  
; CHECK: encoding: [0x26,0x10]
movsnd	r0, r1                  
; CHECK-INST: movsnd	@r2, r3                 
; CHECK: encoding: [0x26,0x3a]
movsnd	@r2, r3                 
; CHECK-INST: movsnd	r4, @r5                 
; CHECK: encoding: [0x26,0xd4]
movsnd	r4, @r5                 
; CHECK-INST: movsnd	@r6, @r7                
; CHECK: encoding: [0x26,0xfe]
movsnd	@r6, @r7                
; CHECK-INST: movsnd	r0, r1 305419896        
; CHECK: encoding: [0x66,0x10,0x78,0x56,0x34,0x12]
movsnd	r0, r1 305419896        
; CHECK-INST: movsnd	@r2, r3 305419896       
; CHECK: encoding: [0x66,0x3a,0x78,0x56,0x34,0x12]
movsnd	@r2, r3 305419896       
; CHECK-INST: movsnd	r4, @r5 (123,345)       
; CHECK: encoding: [0x66,0xd4,0x7b,0x59,0x01,0x20]
movsnd	r4, @r5 (123,345)       
; CHECK-INST: movsnd	@r6, @r7 (123,345)      
; CHECK: encoding: [0x66,0xfe,0x7b,0x59,0x01,0x20]
movsnd	@r6, @r7 (123,345)      
; CHECK-INST: movsnd	@r2 (-12,-34), r3 305419896 
; CHECK: encoding: [0xe6,0x3a,0x2c,0x02,0x00,0x90,0x78,0x56,0x34,0x12]
movsnd	@r2 (-12,-34), r3 305419896 
; CHECK-INST: movsnd	@r6 (-12,-34), @r7 (123,345) 
; CHECK: encoding: [0xe6,0xfe,0x2c,0x02,0x00,0x90,0x7b,0x59,0x01,0x20]
movsnd	@r6 (-12,-34), @r7 (123,345) 

; CHECK-INST: movibw	r0, 4660                
; CHECK: encoding: [0x77,0x00,0x34,0x12]
movibw	r0, 4660                
; CHECK-INST: movibw	@r1, 4660               
; CHECK: encoding: [0x77,0x09,0x34,0x12]
movibw	@r1, 4660               
; CHECK-INST: movibw	@r2 (12,34), 4660       
; CHECK: encoding: [0x77,0x4a,0x2c,0x22,0x34,0x12]
movibw	@r2 (12,34), 4660       
; CHECK-INST: moviww	r0, 4660                
; CHECK: encoding: [0x77,0x10,0x34,0x12]
moviww	r0, 4660                
; CHECK-INST: moviww	@r1, 4660               
; CHECK: encoding: [0x77,0x19,0x34,0x12]
moviww	@r1, 4660               
; CHECK-INST: moviww	@r2 (12,34), 4660       
; CHECK: encoding: [0x77,0x5a,0x2c,0x22,0x34,0x12]
moviww	@r2 (12,34), 4660       
; CHECK-INST: movidw	r0, 4660                
; CHECK: encoding: [0x77,0x20,0x34,0x12]
movidw	r0, 4660                
; CHECK-INST: movidw	@r1, 4660               
; CHECK: encoding: [0x77,0x29,0x34,0x12]
movidw	@r1, 4660               
; CHECK-INST: movidw	@r2 (12,34), 4660       
; CHECK: encoding: [0x77,0x6a,0x2c,0x22,0x34,0x12]
movidw	@r2 (12,34), 4660       
; CHECK-INST: moviqw	r0, 4660                
; CHECK: encoding: [0x77,0x30,0x34,0x12]
moviqw	r0, 4660                
; CHECK-INST: moviqw	@r1, 4660               
; CHECK: encoding: [0x77,0x39,0x34,0x12]
moviqw	@r1, 4660               
; CHECK-INST: moviqw	@r2 (12,34), 4660       
; CHECK: encoding: [0x77,0x7a,0x2c,0x22,0x34,0x12]
moviqw	@r2 (12,34), 4660       
; CHECK-INST: movibd	r0, 305419896           
; CHECK: encoding: [0xb7,0x00,0x78,0x56,0x34,0x12]
movibd	r0, 305419896           
; CHECK-INST: movibd	@r1, 305419896          
; CHECK: encoding: [0xb7,0x09,0x78,0x56,0x34,0x12]
movibd	@r1, 305419896          
; CHECK-INST: movibd	@r2 (12,34), 305419896  
; CHECK: encoding: [0xb7,0x4a,0x2c,0x22,0x78,0x56,0x34,0x12]
movibd	@r2 (12,34), 305419896  
; CHECK-INST: moviwd	r0, 305419896           
; CHECK: encoding: [0xb7,0x10,0x78,0x56,0x34,0x12]
moviwd	r0, 305419896           
; CHECK-INST: moviwd	@r1, 305419896          
; CHECK: encoding: [0xb7,0x19,0x78,0x56,0x34,0x12]
moviwd	@r1, 305419896          
; CHECK-INST: moviwd	@r2 (12,34), 305419896  
; CHECK: encoding: [0xb7,0x5a,0x2c,0x22,0x78,0x56,0x34,0x12]
moviwd	@r2 (12,34), 305419896  
; CHECK-INST: movidd	r0, 305419896           
; CHECK: encoding: [0xb7,0x20,0x78,0x56,0x34,0x12]
movidd	r0, 305419896           
; CHECK-INST: movidd	@r1, 305419896          
; CHECK: encoding: [0xb7,0x29,0x78,0x56,0x34,0x12]
movidd	@r1, 305419896          
; CHECK-INST: movidd	@r2 (12,34), 305419896  
; CHECK: encoding: [0xb7,0x6a,0x2c,0x22,0x78,0x56,0x34,0x12]
movidd	@r2 (12,34), 305419896  
; CHECK-INST: moviqd	r0, 305419896           
; CHECK: encoding: [0xb7,0x30,0x78,0x56,0x34,0x12]
moviqd	r0, 305419896           
; CHECK-INST: moviqd	@r1, 305419896          
; CHECK: encoding: [0xb7,0x39,0x78,0x56,0x34,0x12]
moviqd	@r1, 305419896          
; CHECK-INST: moviqd	@r2 (12,34), 305419896  
; CHECK: encoding: [0xb7,0x7a,0x2c,0x22,0x78,0x56,0x34,0x12]
moviqd	@r2 (12,34), 305419896  
; CHECK-INST: movibq	r0, 81985529216486895   
; CHECK: encoding: [0xf7,0x00,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movibq	r0, 81985529216486895   
; CHECK-INST: movibq	@r1, 81985529216486895  
; CHECK: encoding: [0xf7,0x09,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movibq	@r1, 81985529216486895  
; CHECK-INST: movibq	@r2 (12,34), 81985529216486895 
; CHECK: encoding: [0xf7,0x4a,0x2c,0x22,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movibq	@r2 (12,34), 81985529216486895 
; CHECK-INST: moviwq	r0, 81985529216486895   
; CHECK: encoding: [0xf7,0x10,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviwq	r0, 81985529216486895   
; CHECK-INST: moviwq	@r1, 81985529216486895  
; CHECK: encoding: [0xf7,0x19,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviwq	@r1, 81985529216486895  
; CHECK-INST: moviwq	@r2 (12,34), 81985529216486895 
; CHECK: encoding: [0xf7,0x5a,0x2c,0x22,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviwq	@r2 (12,34), 81985529216486895 
; CHECK-INST: movidq	r0, 81985529216486895   
; CHECK: encoding: [0xf7,0x20,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movidq	r0, 81985529216486895   
; CHECK-INST: movidq	@r1, 81985529216486895  
; CHECK: encoding: [0xf7,0x29,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movidq	@r1, 81985529216486895  
; CHECK-INST: movidq	@r2 (12,34), 81985529216486895 
; CHECK: encoding: [0xf7,0x6a,0x2c,0x22,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
movidq	@r2 (12,34), 81985529216486895 
; CHECK-INST: moviqq	r0, 81985529216486895   
; CHECK: encoding: [0xf7,0x30,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviqq	r0, 81985529216486895   
; CHECK-INST: moviqq	@r1, 81985529216486895  
; CHECK: encoding: [0xf7,0x39,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviqq	@r1, 81985529216486895  
; CHECK-INST: moviqq	@r2 (12,34), 81985529216486895 
; CHECK: encoding: [0xf7,0x7a,0x2c,0x22,0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01]
moviqq	@r2 (12,34), 81985529216486895 

; CHECK-INST: movinw	r0, (12,34)             
; CHECK: encoding: [0x78,0x00,0x2c,0x22]
movinw	r0, (12,34)             
; CHECK-INST: movinw	@r1, (12,34)            
; CHECK: encoding: [0x78,0x09,0x2c,0x22]
movinw	@r1, (12,34)            
; CHECK-INST: movinw	@r2 (-12,-34), (12,34)  
; CHECK: encoding: [0x78,0x4a,0x2c,0xa2,0x2c,0x22]
movinw	@r2 (-12,-34), (12,34)  
; CHECK-INST: movind	r0, (123,345)           
; CHECK: encoding: [0xb8,0x00,0x7b,0x59,0x01,0x20]
movind	r0, (123,345)           
; CHECK-INST: movind	@r1, (123,345)          
; CHECK: encoding: [0xb8,0x09,0x7b,0x59,0x01,0x20]
movind	@r1, (123,345)          
; CHECK-INST: movind	@r2 (-12,-34), (123,345) 
; CHECK: encoding: [0xb8,0x4a,0x2c,0xa2,0x7b,0x59,0x01,0x20]
movind	@r2 (-12,-34), (123,345) 
; CHECK-INST: movinq	r0, (1234,3456)         
; CHECK: encoding: [0xf8,0x00,0xd2,0x04,0x80,0x0d,0x00,0x00,0x00,0x20]
movinq	r0, (1234,3456)         
; CHECK-INST: movinq	@r1, (1234,3456)        
; CHECK: encoding: [0xf8,0x09,0xd2,0x04,0x80,0x0d,0x00,0x00,0x00,0x20]
movinq	@r1, (1234,3456)        
; CHECK-INST: movinq	@r2 (-12,-34), (1234,3456) 
; CHECK: encoding: [0xf8,0x4a,0x2c,0xa2,0xd2,0x04,0x80,0x0d,0x00,0x00,0x00,0x20]
movinq	@r2 (-12,-34), (1234,3456) 

; CHECK-INST: movbw	r0, r1                  
; CHECK: encoding: [0x1d,0x10]
movbw	r0, r1                  
; CHECK-INST: movbw	@r2, r3                 
; CHECK: encoding: [0x1d,0x3a]
movbw	@r2, r3                 
; CHECK-INST: movbw	r4, @r5                 
; CHECK: encoding: [0x1d,0xd4]
movbw	r4, @r5                 
; CHECK-INST: movbw	@r6, @r7                
; CHECK: encoding: [0x1d,0xfe]
movbw	@r6, @r7                
; CHECK-INST: movbw	@r2 (12,34), r3         
; CHECK: encoding: [0x9d,0x3a,0x2c,0x22]
movbw	@r2 (12,34), r3         
; CHECK-INST: movbw	r4, @r5 (12,34)         
; CHECK: encoding: [0x5d,0xd4,0x2c,0x22]
movbw	r4, @r5 (12,34)         
; CHECK-INST: movbw	@r6 (12,34), @r7 (-12,-34) 
; CHECK: encoding: [0xdd,0xfe,0x2c,0x22,0x2c,0xa2]
movbw	@r6 (12,34), @r7 (-12,-34) 
; CHECK-INST: movww	r0, r1                  
; CHECK: encoding: [0x1e,0x10]
movww	r0, r1                  
; CHECK-INST: movww	@r2, r3                 
; CHECK: encoding: [0x1e,0x3a]
movww	@r2, r3                 
; CHECK-INST: movww	r4, @r5                 
; CHECK: encoding: [0x1e,0xd4]
movww	r4, @r5                 
; CHECK-INST: movww	@r6, @r7                
; CHECK: encoding: [0x1e,0xfe]
movww	@r6, @r7                
; CHECK-INST: movww	@r2 (12,34), r3         
; CHECK: encoding: [0x9e,0x3a,0x2c,0x22]
movww	@r2 (12,34), r3         
; CHECK-INST: movww	r4, @r5 (12,34)         
; CHECK: encoding: [0x5e,0xd4,0x2c,0x22]
movww	r4, @r5 (12,34)         
; CHECK-INST: movww	@r6 (12,34), @r7 (-12,-34) 
; CHECK: encoding: [0xde,0xfe,0x2c,0x22,0x2c,0xa2]
movww	@r6 (12,34), @r7 (-12,-34) 

; CHECK-INST: movqq	r0, r1                  
; CHECK: encoding: [0x28,0x10]
movqq	r0, r1                  
; CHECK-INST: movqq	@r2, r3                 
; CHECK: encoding: [0x28,0x3a]
movqq	@r2, r3                 
; CHECK-INST: movqq	r4, @r5                 
; CHECK: encoding: [0x28,0xd4]
movqq	r4, @r5                 
; CHECK-INST: movqq	@r6, @r7                
; CHECK: encoding: [0x28,0xfe]
movqq	@r6, @r7                
; CHECK-INST: movqq	@r2 (12,34), r3         
; CHECK: encoding: [0xa8,0x3a,0x0c,0x22,0x00,0x00,0x00,0x00,0x00,0x10]
movqq	@r2 (12,34), r3         
; CHECK-INST: movqq	r4, @r5 (12,34)         
; CHECK: encoding: [0x68,0xd4,0x0c,0x22,0x00,0x00,0x00,0x00,0x00,0x10]
movqq	r4, @r5 (12,34)         
; CHECK-INST: movqq	@r6 (12,34), @r7 (-12,-34) 
; CHECK: encoding: [0xe8,0xfe,0x0c,0x22,0x00,0x00,0x00,0x00,0x00,0x10,0x0c,0x22,0x00,0x00,0x00,0x00,0x00,0x90]
movqq	@r6 (12,34), @r7 (-12,-34) 
