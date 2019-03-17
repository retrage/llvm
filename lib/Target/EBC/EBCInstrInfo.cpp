//===-- EBCInstrInfo.cpp - EBC Instruction Information ------*- C++ -*-===//
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

#include "EBCInstrInfo.h"
#include "EBC.h"
#include "EBCSubtarget.h"
#include "EBCTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "EBCGenInstrInfo.inc"

using namespace llvm;

EBCInstrInfo::EBCInstrInfo() : EBCGenInstrInfo() {}
