//===-- EBCTargetInfo.cpp - EBC Target Implementation -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target &getTheEBCTarget() {
  static Target TheEBCTarget;
  return TheEBCTarget;
}
}

extern "C" void LLVMInitializeEBCTargetInfo() {
  RegisterTarget<Triple::ebc> X(getTheEBCTarget(), "ebc",
                                    "EFI Byte Code", "EBC");
}
