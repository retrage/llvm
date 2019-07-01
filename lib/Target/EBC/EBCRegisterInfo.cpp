//===-- EBCRegisterInfo.cpp - EBC Register Information ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the EBC implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "EBCRegisterInfo.h"
#include "EBC.h"
#include "EBCSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"

#define GET_REGINFO_TARGET_DESC
#include "EBCGenRegisterInfo.inc"

using namespace llvm;

EBCRegisterInfo::EBCRegisterInfo(unsigned HwMode)
  : EBCGenRegisterInfo(EBC::r1, /*DwarfFlavour*/0, /*EHFlavor*/0,
                      /*PC*/0, HwMode) {}

const MCPhysReg *
EBCRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

const uint32_t *
EBCRegisterInfo::getCallPreservedMask(const MachineFunction & /*MF*/,
                                      CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}

BitVector EBCRegisterInfo::getReservedRegs(const MachineFunction &MF) const  {
  BitVector Reserved(getNumRegs());

  // Use markSuperRegs to ensure any register aliases are also reserved
  markSuperRegs(Reserved, EBC::r0);
  markSuperRegs(Reserved, EBC::r6);
  markSuperRegs(Reserved, EBC::ip);
  markSuperRegs(Reserved, EBC::flags);
  assert(checkAllSuperRegsMarked(Reserved));
  return Reserved;
}

void EBCRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");

  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  unsigned FrameReg;
  int Offset =
    getFrameLowering(MF)->getFrameIndexReference(MF, FrameIndex, FrameReg) +
    MI.getOperand(FIOperandNum + 2).getImm();

  if (isInt<16>(Offset)) {
    MI.getOperand(FIOperandNum)
        .ChangeToRegister(FrameReg, false, false, false);
    MI.getOperand(FIOperandNum + 2).ChangeToImmediate(Offset);
  } else {
    report_fatal_error(
        "Frame offsets outside of the signed 16-bit range not supported");
  }
}

unsigned EBCRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? EBC::r6 : EBC::r0;
}
