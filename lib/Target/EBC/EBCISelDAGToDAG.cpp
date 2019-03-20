//===-- EBCISelDAGToDAG.cpp - A dag to dag inst selector for EBC ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the EBC target.
//
//===----------------------------------------------------------------------===//

#include "EBC.h"
#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "EBCTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "ebc-isel"

// EBC-specific code to select EBC machine instructions for
// SelectionDAG operations.
namespace {
class EBCDAGToDAGISel final : public SelectionDAGISel {
public:
  explicit EBCDAGToDAGISel(EBCTargetMachine &TargetMachine)
      : SelectionDAGISel(TargetMachine) {}

  StringRef getPassName() const override {
    return "EBC DAG->DAG Pattern Instruction Selection";
  }

  void Select(SDNode *Node) override;

// Include the pieces autogenerated from the target description.
#include "EBCGenDAGISel.inc"
};
}

void EBCDAGToDAGISel::Select(SDNode *Node) {
  // If we have a custom node, we have already selected
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "== "; Node->dump(CurDAG); dbgs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  unsigned Opcode = Node->getOpcode();
  SDLoc DL(Node);
  EVT VT = Node->getValueType(0);
  switch (Opcode) {
  default: break;
  case ISD::FrameIndex: {
    SDValue Op2 = CurDAG->getRegister(EBC::r0, MVT::i64);
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    SDValue Op2IdxN = CurDAG->getTargetConstant(FI, DL, MVT::i16);
    SDValue Op2IdxC = CurDAG->getTargetConstant(0, DL, MVT::i16);
    ArrayRef<SDValue> Ops = {Op2, Op2IdxN, Op2IdxC};
    ReplaceNode(Node, CurDAG->getMachineNode(EBC::MOVqwOp1DOp2DIdx,
                                             DL, VT, Ops));
    return;
  }
  }

  // Select the default instruction.
  SelectCode(Node);
}

// This pass converts a legalized DAG into a EBC-specific DAG, ready
// for instruction scheduling.
FunctionPass *llvm::createEBCISelDag(EBCTargetMachine &TM) {
  return new EBCDAGToDAGISel(TM);
}
