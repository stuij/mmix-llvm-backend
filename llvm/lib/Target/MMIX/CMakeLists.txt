set(LLVM_TARGET_DEFINITIONS MMIX.td)

tablegen(LLVM MMIXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM MMIXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM MMIXGenMCCodeEmitter.inc -gen-emitter)

add_public_tablegen_target(MMIXCommonTableGen)

add_llvm_target(MMIXCodeGen
  MMIXTargetMachine.cpp
  )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
