//===-- EBCISelLowering.cpp - EBC DAG Lowering Implementation  --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that EBC uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#include "EBCISelLowering.h"
#include "EBC.h"
#include "EBCRegisterInfo.h"
#include "EBCSubtarget.h"
#include "EBCTargetMachine.h"
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
#include "llvm/Support/MachineValueType.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "ebc-lower"

EBCTargetLowering::EBCTargetLowering(const TargetMachine &TM,
                                         const EBCSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {

  // Set up the register classes.
  addRegisterClass(MVT::i64, &EBC::GPRRegClass);

  // Compute derived properties from the register classes.
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(EBC::r0);

  for (auto N : {ISD::EXTLOAD, ISD::SEXTLOAD, ISD::ZEXTLOAD})
    setLoadExtAction(N, MVT::i64, MVT::i1, Promote);

  // TODO: add all necessary setOperationAction calls.
  setOperationAction(ISD::GlobalAddress, MVT::i64, Custom);

  setBooleanContents(ZeroOrOneBooleanContent);

  // Function alignments (log2).
  setMinFunctionAlignment(3);
  setPrefFunctionAlignment(3);
}

SDValue EBCTargetLowering::LowerOperation(SDValue Op,
                                            SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  }
}

SDValue EBCTargetLowering::lowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  SDLoc DL(Op);
  EVT Ty = Op.getValueType();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();

  // TODO: this should be improved by using natural indexing.
  SDValue GA = DAG.getTargetGlobalAddress(GV, DL, Ty);
  SDValue MN = SDValue(DAG.getMachineNode(EBC::MOVRELqOp1D, DL, Ty, GA), 0);
  if (Offset != 0)
    return DAG.getNode(ISD::ADD, DL, Ty, MN,
                       DAG.getConstant(Offset, DL, MVT::i64));

  return MN;
}

// Calling Convention Implementation.
#include "EBCGenCallingConv.inc"

// Transform physical registers into virtual registers.
SDValue EBCTargetLowering::LowerFormalArguments(
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
  MachineFrameInfo &MFI = MF.getFrameInfo();

  if (IsVarArg)
    report_fatal_error("VarArg not supported");

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_EBC);

  for (auto &VA : ArgLocs) {
    if (!VA.isMemLoc())
      report_fatal_error("CCValAssign must be mem");
    unsigned ArgOffset = VA.getLocMemOffset();
    unsigned ArgSize = VA.getValVT().getSizeInBits() / 8;

    int FI = MFI.CreateFixedObject(ArgSize, ArgOffset, true);

    // Create load nodes to retrieve arguments from the stack.
    SDValue FIN = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
    SDValue ArgValue;

    // For NON_EXTLOAD, generic code in getLoad assert(ValVT == MemVT)
    ISD::LoadExtType ExtType = ISD::NON_EXTLOAD;
    MVT MemVT = VA.getValVT();

    switch (VA.getLocInfo()) {
    default:
      break;
    case CCValAssign::BCvt:
      MemVT = VA.getLocVT();
      break;
    case CCValAssign::SExt:
      ExtType = ISD::SEXTLOAD;
      break;
    case CCValAssign::ZExt:
      ExtType = ISD::ZEXTLOAD;
      break;
    case CCValAssign::AExt:
      ExtType = ISD::EXTLOAD;
      break;
    }

    ArgValue = DAG.getExtLoad(
        ExtType, DL, VA.getLocVT(), Chain, FIN,
        MachinePointerInfo::getFixedStack(DAG.getMachineFunction(), FI),
        MemVT);

    InVals.push_back(ArgValue);
  }
  return Chain;
}

SDValue
EBCTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
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

  CCInfo.AnalyzeReturn(Outs, RetCC_EBC);

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

  return DAG.getNode(EBC::RET_FLAG, DL, MVT::Other, RetOps);
}

const char *EBCTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((EBC::NodeType)Opcode) {
  case EBC::FIRST_NUMBER:
    break;
  case EBC::RET_FLAG:
    return "EBC::RET_FLAG";
  }
  return nullptr;
}
