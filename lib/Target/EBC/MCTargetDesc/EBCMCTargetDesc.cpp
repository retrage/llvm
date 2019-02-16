//===-- EBCMCTargetDesc.cpp - EBC Target Descriptions -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// This file provides EBC-specific target descriptions.
///
//===----------------------------------------------------------------------===//

#include "EBCMCTargetDesc.h"
#include "EBCMCAsmInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "EBCGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "EBCGenRegisterInfo.inc"

using namespace llvm;

static MCInstrInfo *createEBCMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitEBCMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createEBCMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitEBCMCRegisterInfo(X, EBC::R1);
  return X;
}

static MCAsmInfo *createEBCMCAsmInfo(const MCRegisterInfo &MRI,
                                       const Triple &TT) {
  return new EBCMCAsmInfo();
}

extern "C" void LLVMInitializeEBCTargetMC() {
  Target *T = &getTheEBCTarget();
  TargetRegistry::RegisterMCAsmInfo(*T, createEBCMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(*T, createEBCMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(*T, createEBCMCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(*T, createEBCAsmBackend);
  TargetRegistry::RegisterMCCodeEmitter(*T, createEBCMCCodeEmitter);
}
