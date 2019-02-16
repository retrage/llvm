//===-- EBCVMCAsmInfo.cpp - EBC Asm properties -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the RISCVMCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "EBCMCAsmInfo.h"
using namespace llvm;

void EBCMCAsmInfo::anchor() {}

EBCMCAsmInfo::EBCMCAsmInfo() {
  AlignmentIsInBytes = false;
  SupportsDebugInformation = true;
  CodePointerSize = 8;

  CommentString = ";";
}
