; RUN: llvm-mc %s -filetype=obj -triple=ebc | llvm-readobj -h \
; RUN:      | FileCheck %s

; CHECK: ImageFileHeader {
; CHECK:   Machine: IMAGE_FILE_MACHINE_EBC
; CHECK:   SectionCount: 3
; CHECK:   TimeDateStamp: {{[0-9]+}}
; CHECK:   PointerToSymbolTable: 0x{{[0-9A-F]+}}
; CHECK:   SymbolCount: 6
; CHECK:   OptionalHeaderSize: 0
; CHECK:   Characteristics [ (0x0)
; CHECK:   ]
; CHECK: }
