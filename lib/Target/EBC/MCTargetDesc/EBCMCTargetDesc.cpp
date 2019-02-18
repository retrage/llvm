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
#include "EBCCOFFStreamer.h"
#include "InstPrinter/EBCInstPrinter.h"
#include "EBCMCAsmInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCObjectWriter.h"
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
  InitEBCMCRegisterInfo(X, EBC::r1);
  return X;
}

static MCAsmInfo *createEBCMCAsmInfo(const MCRegisterInfo &MRI,
                                       const Triple &TT) {
  return new EBCMCAsmInfo();
}

static MCInstPrinter *createEBCMCInstPrinter(const Triple &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI) {
  return new EBCInstPrinter(MAI, MII, MRI);
}

static MCStreamer *
createCOFFStreamer(MCContext &Ctx, std::unique_ptr<MCAsmBackend> &&TAB,
                  std::unique_ptr<MCObjectWriter> &&OW,
                  std::unique_ptr<MCCodeEmitter> &&Emitter,
                  bool RelaxAll, bool IncrementalLinkerCompatible) {
  return createEBCCOFFStreamer(Ctx, std::move(TAB), std::move(OW),
                                std::move(Emitter), RelaxAll,
                                IncrementalLinkerCompatible);
}

extern "C" void LLVMInitializeEBCTargetMC() {
  Target *T = &getTheEBCTarget();
  TargetRegistry::RegisterMCAsmInfo(*T, createEBCMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(*T, createEBCMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(*T, createEBCMCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(*T, createEBCAsmBackend);
  TargetRegistry::RegisterMCCodeEmitter(*T, createEBCMCCodeEmitter);
  TargetRegistry::RegisterMCInstPrinter(*T, createEBCMCInstPrinter);
  TargetRegistry::RegisterCOFFStreamer(*T, createCOFFStreamer);
}
