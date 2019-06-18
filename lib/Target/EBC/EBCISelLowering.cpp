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

  setOperationAction(ISD::BR_CC, MVT::i64, Custom);
  setOperationAction(ISD::BRCOND, MVT::Other, Expand);

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
  case ISD::BR_CC:
    return lowerBR_CC(Op, DAG);
  }
}

SDValue EBCTargetLowering::lowerBR_CC(SDValue Op,
                                      SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(1))->get();
  SDValue LHS = Op.getOperand(2);
  SDValue RHS = Op.getOperand(3);
  SDValue Dest = Op.getOperand(4);

  SDLoc DL(Op);

  bool IsCS = false;

  switch (CC) {
  default:
    IsCS = true;
    break;
  case ISD::SETNE:
    CC = ISD::SETEQ;
    break;
  case ISD::SETLT:
    CC = ISD::SETGE;
    break;
  case ISD::SETGT:
    CC = ISD::SETLE;
    break;
  case ISD::SETULT:
    CC = ISD::SETUGE;
    break;
  case ISD::SETUGT:
    CC = ISD::SETULE;
    break;
  }

  unsigned CmpOpcode;

  switch (CC) {
    default:
      report_fatal_error("unimplemented operand");
    case ISD::SETEQ:
      CmpOpcode = EBC::CMPeq64Op2D;
      break;
    case ISD::SETGE:
      CmpOpcode = EBC::CMPgte64Op2D;
      break;
    case ISD::SETLE:
      CmpOpcode = EBC::CMPlte64Op2D;
      break;
    case ISD::SETUGE:
      CmpOpcode = EBC::CMPugte64Op2D;
      break;
    case ISD::SETULE:
      CmpOpcode = EBC::CMPulte64Op2D;
      break;
  }

  SDValue Cmp = SDValue(DAG.getMachineNode(CmpOpcode, DL, MVT::Glue,
                                           LHS, RHS), 0);

  unsigned JmpOpcode = IsCS ? EBC::JMP64CSAbsImm : EBC::JMP64CCAbsImm;

  return SDValue(DAG.getMachineNode(JmpOpcode, DL, MVT::Other,
                                    Dest, Chain, Cmp), 0);
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
  case CallingConv::Fast:
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

// Lower a call to a callseq_start + CALL + callseq_end chain, and add input
// and output parameter nodes.
SDValue EBCTargetLowering::LowerCall(CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc &DL = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  CLI.IsTailCall = false;
  CallingConv::ID CallConv = CLI.CallConv;
  bool IsVarArg = CLI.IsVarArg;
  EVT PtrVT = getPointerTy(DAG.getDataLayout());

  if (IsVarArg) {
    report_fatal_error("LowerCall with varargs not implemented");
  }

  MachineFunction &MF = DAG.getMachineFunction();

  // Analyze the operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState ArgCCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  ArgCCInfo.AnalyzeCallOperands(Outs, CC_EBC);

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NumBytes = ArgCCInfo.getNextStackOffset();

  for (auto &Arg : Outs) {
    if (!Arg.Flags.isByVal())
      continue;
    report_fatal_error("Passing arguments byval not yet implemented");
  }

  Chain = DAG.getCALLSEQ_START(Chain, NumBytes, 0, CLI.DL);

  // Copy argument values to their designated locations.
  SmallVector<SDValue, 16> MemOpChains;
  SDValue StackPtr;
  for (unsigned I = 0, E = ArgLocs.size(); I != E; ++I) {
    CCValAssign &VA = ArgLocs[I];
    SDValue ArgValue = OutVals[I];

    // Promote the value if needed.
    // For now, only handle fully promoted arguments.
    switch (VA.getLocInfo()) {
    default:
      llvm_unreachable("Unknown loc info!");
    case CCValAssign::Full:
      break;
    }

    if (VA.isMemLoc()) {
      // Work out the address of the stack slot.
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, DL, EBC::r0, PtrVT);
      SDValue Address =
          DAG.getNode(ISD::ADD, DL, PtrVT, StackPtr,
                      DAG.getIntPtrConstant(VA.getLocMemOffset(), DL));

      // Emit the store.
      MemOpChains.push_back(
          DAG.getStore(Chain, DL, ArgValue, Address, MachinePointerInfo()));
    } else {
      assert(VA.isRegLoc() && "Argument not register or memory");
      report_fatal_error("Passing arguments via the register not supported");
    }
  }

  // Join the stores, which are independent of one another.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  SDValue Glue;

  if (GlobalAddressSDNode *S = dyn_cast<GlobalAddressSDNode>(Callee)) {
    Callee = DAG.getTargetGlobalAddress(S->getGlobal(), DL, PtrVT, 0, 0);
  } else if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
    Callee = DAG.getTargetExternalSymbol(S->getSymbol(), PtrVT, 0);
  }

  // The first call operand is the chain and the second is the target address.
  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);

  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const uint32_t *Mask = TRI->getCallPreservedMask(MF, CallConv);
  assert(Mask && "Missing call preserved mask for calling convention");
  Ops.push_back(DAG.getRegisterMask(Mask));

  // Glue the call to the argument copies, if any.
  if (Glue.getNode())
    Ops.push_back(Glue);

  // Emit the call.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);

  Chain = DAG.getNode(EBCISD::CALL, DL, NodeTys, Ops);
  Glue = Chain.getValue(1);

  // Mark the end of the call, which is glued to the call itself.
  Chain = DAG.getCALLSEQ_END(Chain,
                             DAG.getConstant(NumBytes, DL, PtrVT, true),
                             DAG.getConstant(0, DL, PtrVT, true),
                             Glue, DL);

  if (!Ins.empty()) {
    Glue = Chain.getValue(1);
  }

  // Assign locations to each value returned by this call.
  SmallVector<CCValAssign, 16> RVLocs;
  CCState RetCCInfo(CallConv, IsVarArg, MF, RVLocs, *DAG.getContext());
  RetCCInfo.AnalyzeCallResult(Ins, RetCC_EBC);

  // Copy all of the result registers out of their specified physreg.
  for (auto &VA : RVLocs) {
    // Copy the value out
    SDValue RetValue =
        DAG.getCopyFromReg(Chain, DL, VA.getLocReg(), VA.getLocVT(), Glue);
    // Glue the RetValue to the end of the call sequence
    Chain = RetValue.getValue(1);
    Glue = Chain.getValue(2);

    InVals.push_back(Chain.getValue(0));
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

  return DAG.getNode(EBCISD::RET_FLAG, DL, MVT::Other, RetOps);
}

const char *EBCTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((EBCISD::NodeType)Opcode) {
  case EBCISD::FIRST_NUMBER:
    break;
  case EBCISD::RET_FLAG:
    return "EBCISD::RET_FLAG";
  case EBCISD::CALL:
    return "EBCISD::CALL";
  case EBCISD::BRCOND:
    return "EBCISD::BRCOND";
  case EBCISD::CMP:
    return "EBCISD::CMP";
  }
  return nullptr;
}
