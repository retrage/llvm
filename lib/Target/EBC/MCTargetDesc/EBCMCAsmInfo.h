//===-- EBCMCAsmInfo.h - EBC Asm Info ----------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the EBCMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCMCASMINFO_H
#define LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCMCASMINFO_H

#include "llvm/MC/MCAsmInfoCOFF.h"

namespace llvm {

struct EBCMCAsmInfo : public MCAsmInfoCOFF {
  void anchor() override;

public:
  explicit EBCMCAsmInfo();
};

} // namespace llvm

#endif
