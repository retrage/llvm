set(LLVM_TARGET_DEFINITIONS EBC.td)

tablegen(LLVM EBCGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM EBCGenInstrInfo.inc -gen-instr-info)

add_public_tablegen_target(EBCCommonTableGen)

add_llvm_target(EBCCodeGen
  EBCTargetMachine.cpp
  )

add_subdirectory(TargetInfo)
