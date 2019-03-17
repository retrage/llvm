//===-- EBC.h - Top-level interface for EBC -----------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// EBC back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_EBC_H
#define LLVM_LIB_TARGET_EBC_EBC_H

#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class EBCTargetMachine;
class MCInst;
class MachineInstr;

void LowerEBCMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI);

FunctionPass *createEBCISelDag(EBCTargetMachine &TM);
}

#endif
