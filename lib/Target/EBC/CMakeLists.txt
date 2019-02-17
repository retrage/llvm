set(LLVM_TARGET_DEFINITIONS EBC.td)

tablegen(LLVM EBCGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM EBCGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM EBCGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM EBCGenAsmMatcher.inc -gen-asm-matcher)

add_public_tablegen_target(EBCCommonTableGen)

add_llvm_target(EBCCodeGen
  EBCTargetMachine.cpp
  )

add_subdirectory(AsmParser)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
