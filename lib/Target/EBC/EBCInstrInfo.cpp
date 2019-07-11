//===-- EBCInstrInfo.cpp - EBC Instruction Information ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the EBC implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "EBC.h"
#include "EBCInstrInfo.h"
#include "EBCSubtarget.h"
#include "EBCTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "EBCGenInstrInfo.inc"

using namespace llvm;

EBCInstrInfo::EBCInstrInfo()
    : EBCGenInstrInfo(EBC::ADJCALLSTACKDOWN, EBC::ADJCALLSTACKUP) {}

void EBCInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator MBBI,
                               const DebugLoc &DL, unsigned DstReg,
                               unsigned SrcReg, bool KillSrc) const {
  assert(EBC::GPRRegClass.contains(DstReg, SrcReg) &&
         "Impossible reg-to-reg copy");

  BuildMI(MBB, MBBI, DL, get(EBC::MOVqqOp1DOp2D), DstReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
}

void EBCInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator MBBI,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (MBBI != MBB.end()) {
    DL = MBBI->getDebugLoc();
  }

  if (RC == &EBC::GPRRegClass) {
    BuildMI(MBB, MBBI, DL, get(EBC::MOVqwOp1IIdxOp2D))
        .addFrameIndex(FI)
        .addImm(0)
        .addImm(8) // FIXME: It must be determined by eliminateFrameIndex
        .addReg(SrcReg, getKillRegState(IsKill));
  } else {
    llvm_unreachable("Can't store this register to stack slot");
  }
}

void EBCInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator MBBI,
                                        unsigned DstReg, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (MBBI != MBB.end()) {
    DL = MBBI->getDebugLoc();
  }

  if (RC == &EBC::GPRRegClass) {
    BuildMI(MBB, MBBI, DL, get(EBC::MOVqwOp1DOp2IIdx), DstReg)
        .addFrameIndex(FI)
        .addImm(0)
        .addImm(8); // FIXME: It must be determined by eliminateFrameIndex
  } else {
    llvm_unreachable("Can't load this register from stack slot");
  }
}
