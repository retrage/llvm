//===-- EBCFrameLowering.cpp - EBC Frame Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the EBC implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "EBCFrameLowering.h"
#include "EBCMachineFunctionInfo.h"
#include "EBCSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

bool EBCFrameLowering::hasFP(const MachineFunction &MF) const {
  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();

  const MachineFrameInfo &MFI = MF.getFrameInfo();
  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         RegInfo->needsStackRealignment(MF) || MFI.hasVarSizedObjects() ||
         MFI.isFrameAddressTaken();
}

// Determines the size of the frame and maximum call frame size.
void EBCFrameLowering::determineFrameLayout(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const EBCRegisterInfo *RI = STI.getRegisterInfo();

  // Get the number of bytes to allocate from the FrameInfo.
  uint64_t FrameSize = MFI.getStackSize();

  // Get the alignment.
  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

  // Make sure the frame is aligned.
  FrameSize = alignTo(FrameSize, StackAlign);

  // Update frame info.
  MFI.setStackSize(FrameSize);
}

void EBCFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI,
                                 const DebugLoc &DL, unsigned DestReg,
                                 unsigned SrcReg, int64_t Val,
                                 MachineInstr::MIFlag Flag) const {
  const EBCInstrInfo *TII = STI.getInstrInfo();

  if (DestReg == SrcReg && Val == 0)
    return;

  unsigned Opc;
  if (isInt<16>(Val)) {
    Opc = EBC::MOVqwOp1DOp2DIdx;
  } else if (isInt<32>(Val)) {
    Opc = EBC::MOVqdOp1DOp2DIdx;
  } else if (isInt<60>(Val)) {
    Opc = EBC::MOVqqOp1DOp2DIdx;
  } else {
    report_fatal_error("adjustReg cannot handle adjustments > 60 bits");
  }

  BuildMI(MBB, MBBI, DL, TII->get(Opc), DestReg)
      .addReg(SrcReg)
      .addImm(0)
      .addImm(Val)
      .setMIFlag(Flag);
}

unsigned EBCFrameLowering::getCalleeSavedFrameSize(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const EBCRegisterInfo *RI = STI.getRegisterInfo();

  unsigned CalleeFrameSize = 0;
  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
    unsigned Reg = CSI[I].getReg();
    CalleeFrameSize += RI->getRegSizeInBits(Reg, MRI) / 8;
  }

  // Get the alignment.
  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

  // Make sure the frame is aligned.
  CalleeFrameSize = alignTo(CalleeFrameSize, StackAlign);

  return CalleeFrameSize;
}

// Returns the register used to hold the frame pointer.
static unsigned getFPReg() { return EBC::r1; }

// Returns the register used to hold the stack pointer.
static unsigned getSPReg() { return EBC::r0; }

void EBCFrameLowering::emitPrologue(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  MachineFrameInfo &MFI = MF.getFrameInfo();
  auto *EBCFI = MF.getInfo<EBCMachineFunctionInfo>();
  MachineBasicBlock::iterator MBBI = MBB.begin();

  unsigned FPReg = getFPReg();
  unsigned SPReg = getSPReg();

  // Debug location must be unknown since the first debug location is used
  // to determine the end of the prologue.
  DebugLoc DL;

  // Determine the correct frame layout
  determineFrameLayout(MF);
  EBCFI->setCalleeSavedFrameSize(getCalleeSavedFrameSize(MF));

  // FIXME (note copied from Lanai): This appears to be overallocating. Needs
  // investigation. Get the number of bytes to allocate from the FrameInfo.
  uint64_t StackSize = MFI.getStackSize() - EBCFI->getCalleeSavedFrameSize();

  // Early exit if there is no need to allocate on the stack
  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  // Allocate space on the stack if necessary.
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, -StackSize, MachineInstr::FrameSetup);

  // The frame pointer is callee-saved, and code has been generated for us to
  // save it to the stack. We need to skip over the storing of callee-saved
  // registers as the frame pointer must be modified after it has been saved
  // to the stack, not before.
  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  std::advance(MBBI, CSI.size());

  // Generate new FP.
  if (hasFP(MF))
    adjustReg(MBB, MBBI, DL, FPReg, SPReg,
              StackSize - EBCFI->getVarArgsSaveSize(),
              MachineInstr::FrameSetup);
}

void EBCFrameLowering::emitEpilogue(MachineFunction &MF,
                                      MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const EBCRegisterInfo *RI = STI.getRegisterInfo();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  auto *EBCFI = MF.getInfo<EBCMachineFunctionInfo>();
  DebugLoc DL = MBBI->getDebugLoc();
  unsigned FPReg = getFPReg();
  unsigned SPReg = getSPReg();

  // Skip to before the restores of callee-saved registers
  auto LastFrameDestroy = std::prev(MBBI, MFI.getCalleeSavedInfo().size());

  uint64_t StackSize = MFI.getStackSize() - EBCFI->getCalleeSavedFrameSize();

  // Restore the stack pointer using the value of the frame pointer. Only
  // necessary if the stack pointer was modified, meaning the stack size is
  // unknown.
  if (RI->needsStackRealignment(MF) || MFI.hasVarSizedObjects()) {
    assert(hasFP(MF) && "frame pointer should not have been eliminated");
    adjustReg(MBB, LastFrameDestroy, DL, SPReg, FPReg,
              -StackSize + EBCFI->getVarArgsSaveSize(),
              MachineInstr::FrameDestroy);
  }

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, StackSize, MachineInstr::FrameDestroy);
}
