//===-- EBCInstrInfo.h - EBC Instruction Information --------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_EBC_EBCINSTRINFO_H
#define LLVM_LIB_TARGET_EBC_EBCINSTRINFO_H

#include "EBCRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "EBCGenInstrInfo.inc"

namespace llvm {

class EBCInstrInfo : public EBCGenInstrInfo {

public:
  EBCInstrInfo();
};
}

#endif
