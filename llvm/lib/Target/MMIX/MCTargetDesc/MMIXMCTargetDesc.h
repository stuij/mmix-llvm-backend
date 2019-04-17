//===-- MMIXMCTargetDesc.h - MMIX Target Descriptions ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides MMIX specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCTARGETDESC_H
#define LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;

Target &getTheMMIXTarget();

MCCodeEmitter *createMMIXMCCodeEmitter(const MCInstrInfo &MCII,
                                       const MCRegisterInfo &MRI,
                                       MCContext &Ctx);

MCAsmBackend *createMMIXAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                   const MCRegisterInfo &MRI,
                                   const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter> createMMIXELFObjectWriter(uint8_t OSABI);
}

// Defines symbolic names for MMIX registers.
#define GET_REGINFO_ENUM
#include "MMIXGenRegisterInfo.inc"

// Defines symbolic names for MMIX instructions.
#define GET_INSTRINFO_ENUM
#include "MMIXGenInstrInfo.inc"

#endif // LLVM_LIB_TARGET_MMIX_MCTARGETDESC_MMIXMCTARGETDESC_H
