//===-- EBCSubtarget.cpp - EBC Subtarget Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the EBC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "EBCSubtarget.h"
#include "EBC.h"
#include "EBCFrameLowering.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "ebc-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "EBCGenSubtargetInfo.inc"

void EBCSubtarget::anchor() {}

EBCSubtarget &EBCSubtarget::initializeSubtargetDependencies(StringRef CPU,
                                                                StringRef FS) {
  return *this;
}

EBCSubtarget::EBCSubtarget(const Triple &TT, const std::string &CPU,
                               const std::string &FS, const TargetMachine &TM)
    : EBCGenSubtargetInfo(TT, CPU, FS),
      FrameLowering(initializeSubtargetDependencies(CPU, FS)),
      InstrInfo(), RegInfo(getHwMode()), TLInfo(TM, *this) {}
