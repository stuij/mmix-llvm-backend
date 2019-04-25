set(LLVM_TARGET_DEFINITIONS MMIX.td)

tablegen(LLVM MMIXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM MMIXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM MMIXGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM MMIXGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM MMIXGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM MMIXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM MMIXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM MMIXGenDisassemblerTables.inc -gen-disassembler)

add_public_tablegen_target(MMIXCommonTableGen)

add_llvm_target(MMIXCodeGen
  MMIXTargetMachine.cpp
  )

add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
