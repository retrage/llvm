set(LLVM_TARGET_DEFINITIONS EBC.td)

tablegen(LLVM EBCGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM EBCGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM EBCGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM EBCGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM EBCGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM EBCGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM EBCGenCallingConv.inc -gen-callingconv)
tablegen(LLVM EBCGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM EBCGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM EBCGenDisassemblerTables.inc -gen-disassembler)

add_public_tablegen_target(EBCCommonTableGen)

add_llvm_target(EBCCodeGen
  EBCAsmPrinter.cpp
  EBCFrameLowering.cpp
  EBCInstrInfo.cpp
  EBCISelDAGToDAG.cpp
  EBCISelLowering.cpp
  EBCMCInstLower.cpp
  EBCRegisterInfo.cpp
  EBCSubtarget.cpp
  EBCTargetMachine.cpp
  )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(InstPrinter)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
