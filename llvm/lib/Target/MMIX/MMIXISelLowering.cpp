//===-- MMIXISelLowering.cpp - MMIX DAG Lowering Implementation  --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that MMIX uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#include "MMIXISelLowering.h"
#include "MMIX.h"
#include "MMIXRegisterInfo.h"
#include "MMIXSubtarget.h"
#include "MMIXTargetMachine.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mmix-lower"

MMIXTargetLowering::MMIXTargetLowering(const TargetMachine &TM,
                                       const MMIXSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {

  // Set up the register classes.
  addRegisterClass(MVT::i64, &MMIX::GPRRegClass);

  // Compute derived properties from the register classes.
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(MMIX::r254);

  for (auto N : {ISD::EXTLOAD, ISD::SEXTLOAD, ISD::ZEXTLOAD})
    setLoadExtAction(N, MVT::i64, MVT::i1, Promote);

  // TODO: add all necessary setOperationAction calls.

  setBooleanContents(ZeroOrOneBooleanContent);

  // Function alignments (log2).
  setMinFunctionAlignment(Align(4));
  setPrefFunctionAlignment(Align(4));
}

SDValue MMIXTargetLowering::LowerOperation(SDValue Op,
                                           SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  }
}

// Calling Convention Implementation.
#include "MMIXGenCallingConv.inc"

// Transform physical registers into virtual registers.
SDValue MMIXTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {

  switch (CallConv) {
  default:
    report_fatal_error("Unsupported calling convention");
  case CallingConv::C:
    break;
  }

  MachineFunction &MF = DAG.getMachineFunction();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();

  if (IsVarArg)
    report_fatal_error("VarArg not supported");

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_MMIX);

  for (auto &VA : ArgLocs) {
    if (!VA.isRegLoc())
      report_fatal_error("Defined with too many args");

    EVT RegVT = VA.getLocVT();
    if (RegVT != MVT::i64) {
      LLVM_DEBUG(dbgs() << "LowerFormalArguments Unhandled argument type: "
          << RegVT.getEVTString() << "\n");
      report_fatal_error("unhandled argument type");
    }
    // Arguments passed in registers.
    const unsigned VReg =
      RegInfo.createVirtualRegister(&MMIX::GPRRegClass);
    RegInfo.addLiveIn(VA.getLocReg(), VReg);
    SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);

    InVals.push_back(ArgIn);
  }
  return Chain;
}

SDValue
MMIXTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                bool IsVarArg,
                                const SmallVectorImpl<ISD::OutputArg> &Outs,
                                const SmallVectorImpl<SDValue> &OutVals,
                                const SDLoc &DL, SelectionDAG &DAG) const {
  if (IsVarArg) {
    report_fatal_error("VarArg not supported");
  }

  // Stores the assignment of the return value to a location.
  SmallVector<CCValAssign, 16> RVLocs;

  // Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_MMIX);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  // Copy the result values into the output registers.
  for (unsigned i = 0, e = RVLocs.size(); i < e; ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), OutVals[i], Flag);

    // Guarantee that all emitted copies are stuck together.
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the flag if we have it.
  if (Flag.getNode()) {
    RetOps.push_back(Flag);
  }

  return DAG.getNode(MMIXISD::RET_FLAG, DL, MVT::Other, RetOps);
}

const char *MMIXTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((MMIXISD::NodeType)Opcode) {
  case MMIXISD::FIRST_NUMBER:
    break;
  case MMIXISD::RET_FLAG:
    return "MMIXISD::RET_FLAG";
  }
  return nullptr;
}
