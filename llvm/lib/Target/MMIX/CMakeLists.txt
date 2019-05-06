set(LLVM_TARGET_DEFINITIONS MMIX.td)

tablegen(LLVM MMIXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM MMIXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM MMIXGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM MMIXGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM MMIXGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM MMIXGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM MMIXGenCallingConv.inc -gen-callingconv)
tablegen(LLVM MMIXGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM MMIXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM MMIXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM MMIXGenDisassemblerTables.inc -gen-disassembler)

add_public_tablegen_target(MMIXCommonTableGen)

add_llvm_target(MMIXCodeGen
  MMIXAsmPrinter.cpp
  MMIXFrameLowering.cpp
  MMIXInstrInfo.cpp
  MMIXISelDAGToDAG.cpp
  MMIXISelLowering.cpp
  MMIXMCInstLower.cpp
  MMIXRegisterInfo.cpp
  MMIXSubtarget.cpp
  MMIXTargetMachine.cpp
  )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
