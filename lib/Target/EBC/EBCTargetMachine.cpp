//===-- EBCTargetMachine.cpp - Define TargetMachine for EBC -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements the info about EBC target spec.
//
//===----------------------------------------------------------------------===//

#include "EBC.h"
#include "EBCTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

extern "C" void LLVMInitializeEBCTarget() {
  RegisterTargetMachine<EBCTargetMachine> X(getTheEBCTarget());
}

static std::string computeDataLayout(const Triple &TT) {
  assert(TT.isArch64Bit() && "only 64-bit is supported");
  return "e-m:w-p:64:64-i32:32-i64:64-i128:128-n32:64-S128";
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

EBCTargetMachine::EBCTargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Optional<Reloc::Model> RM,
                                       Optional<CodeModel::Model> CM,
                                       CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT), TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(make_unique<TargetLoweringObjectFileCOFF>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
class EBCPassConfig : public TargetPassConfig {
public:
  EBCPassConfig(EBCTargetMachine &TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  EBCTargetMachine &getEBCTargetMachine() const {
    return getTM<EBCTargetMachine>();
  }
  bool addInstSelector() override;
};
}

TargetPassConfig *EBCTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new EBCPassConfig(*this, PM);
}

bool EBCPassConfig::addInstSelector() {
  addPass(createEBCISelDag(getEBCTargetMachine()));

  return false;
}
