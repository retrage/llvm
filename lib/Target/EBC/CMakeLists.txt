set(LLVM_TARGET_DEFINITIONS EBC.td)

tablegen(LLVM EBCGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM EBCGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM EBCGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM EBCGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM EBCGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM EBCGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM EBCGenDisassemblerTables.inc -gen-disassembler)

add_public_tablegen_target(EBCCommonTableGen)

add_llvm_target(EBCCodeGen
  EBCTargetMachine.cpp
  )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(InstPrinter)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
