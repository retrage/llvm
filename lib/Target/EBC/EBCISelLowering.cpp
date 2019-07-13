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
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64, Expand);

  setOperationAction(ISD::BR_CC, MVT::i64, Custom);
  setOperationAction(ISD::BRCOND, MVT::Other, Expand);
  setOperationAction(ISD::SETCC, MVT::i64, Custom);
  setOperationAction(ISD::SELECT, MVT::i64, Custom);
  setOperationAction(ISD::SELECT_CC, MVT::i64, Expand);

  setOperationAction(ISD::STACKSAVE, MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Expand);

  setOperationAction(ISD::SMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::MULHS, MVT::i64, Expand);
  setOperationAction(ISD::MULHU, MVT::i64, Expand);

  setOperationAction(ISD::ROTL, MVT::i64, Expand);
  setOperationAction(ISD::ROTR, MVT::i64, Expand);
  setOperationAction(ISD::BSWAP, MVT::i64, Expand);
  setOperationAction(ISD::CTTZ, MVT::i64, Expand);
  setOperationAction(ISD::CTLZ, MVT::i64, Expand);
  setOperationAction(ISD::CTPOP, MVT::i64, Expand);

  setOperationAction(ISD::GlobalAddress, MVT::i64, Custom);
  setOperationAction(ISD::BlockAddress, MVT::i64, Custom);

  setBooleanContents(ZeroOrOneBooleanContent);

  // Function alignments (log2).
  setMinFunctionAlignment(3);
  setPrefFunctionAlignment(3);
}

static void normalizeSetCC(ISD::CondCode &CC, bool &IsCS) {
  IsCS = false;

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
}

static unsigned getCmpOpcodeForIntCondCode(ISD::CondCode CC) {
  switch (CC) {
    default:
      llvm_unreachable("Unsupported CondCode");
    case ISD::SETEQ:
      return EBC::CMPeq64Op2D;
    case ISD::SETGE:
      return EBC::CMPgte64Op2D;
    case ISD::SETLE:
      return EBC::CMPlte64Op2D;
    case ISD::SETUGE:
      return EBC::CMPugte64Op2D;
    case ISD::SETULE:
      return EBC::CMPulte64Op2D;
  }
}

SDValue EBCTargetLowering::LowerOperation(SDValue Op,
                                            SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  case ISD::BlockAddress:
    return lowerBlockAddress(Op, DAG);
  case ISD::BR_CC:
    return lowerBR_CC(Op, DAG);
  case ISD::SELECT:
    return lowerSELECT(Op, DAG);
  case ISD::SETCC:
    return lowerSETCC(Op, DAG);
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
  bool IsCS;
  unsigned CmpOpcode;

  normalizeSetCC(CC, IsCS);
  CmpOpcode = getCmpOpcodeForIntCondCode(CC);

  SDValue Cmp = SDValue(DAG.getMachineNode(CmpOpcode, DL, MVT::Glue,
                                           LHS, RHS), 0);

  unsigned JmpOpcode = IsCS ? EBC::JMP64CSRelImm : EBC::JMP64CCRelImm;

  return SDValue(DAG.getMachineNode(JmpOpcode, DL, MVT::Other,
                                    Dest, Chain, Cmp), 0);
}

SDValue EBCTargetLowering::lowerSELECT(SDValue Op, SelectionDAG &DAG) const {
  SDValue CondV = Op.getOperand(0);
  SDValue TrueV = Op.getOperand(1);
  SDValue FalseV = Op.getOperand(2);

  SDLoc DL(Op);

  if (Op.getSimpleValueType() == MVT::i64 && CondV.getOpcode() == ISD::SETCC &&
      CondV.getOperand(0).getSimpleValueType() == MVT::i64) {
    SDValue LHS = CondV.getOperand(0);
    SDValue RHS = CondV.getOperand(1);
    auto CC = cast<CondCodeSDNode>(CondV.getOperand(2));
    ISD::CondCode CCVal = CC->get();
    bool IsCS;

    normalizeSetCC(CCVal, IsCS);

    SDValue TargetCC = DAG.getConstant(CCVal, DL, MVT::i64);
    SDValue TargetIsCS = DAG.getConstant(IsCS ? 1 : 0, DL, MVT::i64);
    SDVTList VTs = DAG.getVTList(Op.getValueType(), MVT::Glue);
    SDValue Ops[] = {LHS, RHS, TargetCC, TargetIsCS, TrueV, FalseV};
    return DAG.getNode(EBCISD::SELECT_CC, DL, VTs, Ops);
  }

  SDValue Zero = DAG.getConstant(0, DL, MVT::i64);
  SDValue SetEQ = DAG.getConstant(ISD::SETEQ, DL, MVT::i64);
  SDValue TargetIsCS = DAG.getConstant(0, DL, MVT::i64);

  SDVTList VTs = DAG.getVTList(Op.getValueType(), MVT::Glue);
  SDValue Ops[] = {CondV, Zero, SetEQ, TargetIsCS, TrueV, FalseV};

  return DAG.getNode(EBCISD::SELECT_CC, DL, VTs, Ops);
}

SDValue EBCTargetLowering::lowerSETCC(SDValue Op, SelectionDAG &DAG) const {
  SDValue LHS = Op.getOperand(0);
  SDValue RHS = Op.getOperand(1);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(2))->get();
  SDLoc DL(Op);
  bool IsCS;

  normalizeSetCC(CC, IsCS);

  SDValue TargetCC = DAG.getConstant(CC, DL, MVT::i64);
  SDValue TargetIsCS = DAG.getConstant(IsCS ? 1 : 0, DL, MVT::i64);
  SDValue TrueV = DAG.getConstant(1, DL, Op.getValueType());
  SDValue FalseV = DAG.getConstant(0, DL, Op.getValueType());
  SDVTList VTs = DAG.getVTList(Op.getValueType(), MVT::Glue);
  SDValue Ops[] = {LHS, RHS, TargetCC, TargetIsCS, TrueV, FalseV};

  return DAG.getNode(EBCISD::SELECT_CC, DL, VTs, Ops);
}

MachineBasicBlock *
EBCTargetLowering::EmitInstrWithCustomInserter(MachineInstr &MI,
                                               MachineBasicBlock *BB) const {
  const TargetInstrInfo &TII = *BB->getParent()->getSubtarget().getInstrInfo();
  DebugLoc DL = MI.getDebugLoc();

  assert(MI.getOpcode() == EBC::PseudoSELECT &&
         "Unexpected instr type to insert");

  // To "insert" a SELECT instruction, we actually have to insert the triangle
  // control flow pattern. The incoming instruction knows the destination vreg
  // to set, the condition code register to branch on, the true/false values to
  // select between, and the condcode to use to select the appropriate branch.
  //
  // We produce the following control flow:
  //     HeadMBB
  //     |  \
  //     |  IfFalseMBB
  //     |  /
  //     TailMBB
  const BasicBlock *LLVM_BB = BB->getBasicBlock();
  MachineFunction::iterator I = ++BB->getIterator();

  MachineBasicBlock *HeadMBB = BB;
  MachineFunction *F = BB->getParent();
  MachineBasicBlock *TailMBB = F->CreateMachineBasicBlock(LLVM_BB);
  MachineBasicBlock *IfFalseMBB = F->CreateMachineBasicBlock(LLVM_BB);

  F->insert(I, IfFalseMBB);
  F->insert(I, TailMBB);
  // Move all remaining instructions to TailMBB.
  TailMBB->splice(TailMBB->begin(), HeadMBB,
                  std::next(MachineBasicBlock::iterator(MI)), HeadMBB->end());
  // Update machine-CFG edges by transferring all successors of the current
  // block to the new block which will contain the Phi node for the select.
  TailMBB->transferSuccessorsAndUpdatePHIs(HeadMBB);
  // Set the successors for HeadMBB;
  HeadMBB->addSuccessor(IfFalseMBB);
  HeadMBB->addSuccessor(TailMBB);

  // Insert appropriate branch.
  unsigned LHS = MI.getOperand(1).getReg();
  unsigned RHS = MI.getOperand(2).getReg();
  auto CC = static_cast<ISD::CondCode>(MI.getOperand(3).getImm());
  unsigned CmpOpcode = getCmpOpcodeForIntCondCode(CC);
  auto IsCS = static_cast<bool>(MI.getOperand(4).getImm());
  unsigned JmpOpcode = IsCS ? EBC::JMP64CSRelImm : EBC::JMP64CCRelImm;

  BuildMI(HeadMBB, DL, TII.get(CmpOpcode))
    .addReg(LHS)
    .addReg(RHS);
  BuildMI(HeadMBB, DL, TII.get(JmpOpcode))
    .addMBB(TailMBB);

  // IfFalseMBB just falls through to TailMBB;
  IfFalseMBB->addSuccessor(TailMBB);

  // %Result = phi [ %TrueValue, HeadMBB ], [ %FalseValue, IfFalseMBB ]
  BuildMI(*TailMBB, TailMBB->begin(), DL, TII.get(EBC::PHI),
          MI.getOperand(0).getReg())
      .addReg(MI.getOperand(5).getReg())
      .addMBB(HeadMBB)
      .addReg(MI.getOperand(6).getReg())
      .addMBB(IfFalseMBB);

  MI.eraseFromParent(); // The pseudo instruction is gone now.
  return TailMBB;
}

SDValue EBCTargetLowering::lowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  SDLoc DL(Op);
  EVT Ty = Op.getValueType();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();

  SDValue IP = DAG.getRegister(EBC::ip, MVT::i64);
  SDValue SP = SDValue(DAG.getMachineNode(EBC::STORESP, DL, Ty, IP), 0);

  SDValue GA = DAG.getTargetGlobalAddress(GV, DL, Ty);
  // TODO: Replace with pseudo inst to select suitable inst later.
  SDValue MN = SDValue(DAG.getMachineNode(EBC::MOVIqqOp1D, DL, Ty, GA), 0);
  MN = DAG.getNode(ISD::ADD, DL, Ty, MN, SP);

  if (Offset != 0)
    return DAG.getNode(ISD::ADD, DL, Ty, MN,
                       DAG.getConstant(Offset, DL, MVT::i64));

  return MN;
}

SDValue EBCTargetLowering::lowerBlockAddress(SDValue Op,
                                             SelectionDAG &DAG) const {
  SDLoc DL(Op);
  EVT Ty = Op.getValueType();
  BlockAddressSDNode *N = cast<BlockAddressSDNode>(Op);
  const BlockAddress *B = N->getBlockAddress();
  int64_t Offset = N->getOffset();

  SDValue IP = DAG.getRegister(EBC::ip, MVT::i64);
  SDValue SP = SDValue(DAG.getMachineNode(EBC::STORESP, DL, Ty, IP), 0);

  SDValue BA = DAG.getTargetBlockAddress(B, Ty, Offset);
  // TODO: Replace with pseudo inst to select suitable inst later.
  SDValue MN = SDValue(DAG.getMachineNode(EBC::MOVIqqOp1D, DL, Ty, BA), 0);
  MN = DAG.getNode(ISD::ADD, DL, Ty, MN, SP);

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

    if (VA.isRegLoc()) {
      report_fatal_error("Passing arguments via register not supported");
    }

    assert(VA.isMemLoc() && "Argument not register or memory");

    // Work out the address of the stack slot.
    if (!StackPtr.getNode()) {
      StackPtr = DAG.getCopyFromReg(Chain, DL, EBC::r0, PtrVT);
    }
    SDValue Address =
      DAG.getNode(ISD::ADD, DL, PtrVT, StackPtr,
                  DAG.getIntPtrConstant(VA.getLocMemOffset(), DL));

    // Emit the store.
    MemOpChains.push_back(
        DAG.getStore(Chain, DL, ArgValue, Address, MachinePointerInfo()));
  }

  // Join the stores, which are independent of one another.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  SDValue Glue;

  if (GlobalAddressSDNode *S = dyn_cast<GlobalAddressSDNode>(Callee)) {
    Callee = DAG.getTargetGlobalAddress(S->getGlobal(), DL, PtrVT,
                                        S->getOffset(), 0);
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
  Glue = Chain.getValue(1);

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
  case EBCISD::SELECT_CC:
    return "EBCISD::SELECT_CC";
  }
  return nullptr;
}

std::pair<unsigned, const TargetRegisterClass *>
EBCTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                StringRef Constraint,
                                                MVT VT) const {
  // First, see if this is a constraint that directly corresponds to a
  // EBC register class.
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    case 'r':
      return std::make_pair(0U, &EBC::GPRRegClass);
    default:
      break;
    }
  }

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}
