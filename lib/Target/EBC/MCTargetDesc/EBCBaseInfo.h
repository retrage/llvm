//===-- EBCBaseInfo.h - Top level definitions for EBC -------- --*- C++ -*-===//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCBASEINFO_H
#define LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCBASEINFO_H

#include "EBCMCTargetDesc.h"

namespace llvm {

namespace EBC {
  enum OPDATA {
    BreakCode = 1 << 0,
    Op1Imm8   = 1 << 1,
    Op1Imm16  = 1 << 2,
    Op1Imm32  = 1 << 3,
    Op1Imm64  = 1 << 4,
    Op1Idx16  = 1 << 5,
    Op1Idx32  = 1 << 6,
    Op1Idx64  = 1 << 7,
    Op2Imm16  = 1 << 8,
    Op2Imm32  = 1 << 9,
    Op2Imm64  = 1 << 10,
    Op2Idx16  = 1 << 11,
    Op2Idx32  = 1 << 12,
    Op2Idx64  = 1 << 13,
  };
}

}

#endif
