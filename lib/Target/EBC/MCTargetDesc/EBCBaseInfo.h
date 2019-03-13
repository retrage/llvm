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
  enum OP {
    OP_BREAK = 0x00,
    OP_JMP,
    OP_JMP8,
    OP_CALL,
    OP_RET,
    OP_CMPeq,
    OP_CMPlte,
    OP_CMPgte,
    OP_CMPulte,
    OP_CMPugte,
    OP_NOT,
    OP_NEG,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_MULU,
    OP_DIV,
    OP_DIVU,
    OP_MOD,
    OP_MODU,
    OP_AND,
    OP_OR,
    OP_XOR,
    OP_SHL,
    OP_SHR,
    OP_ASHR,
    OP_EXTNDB,
    OP_EXTNDW,
    OP_EXTNDD,
    OP_MOVbw,
    OP_MOVww,
    OP_MOVdw,
    OP_MOVqw,
    OP_MOVbd,
    OP_MOVwd,
    OP_MOVdd,
    OP_MOVqd,
    OP_MOVsnw,
    OP_MOVsnd,
    OP_NOP, // dummy
    OP_MOVqq,
    OP_LOADSP,
    OP_STORESP,
    OP_PUSH,
    OP_POP,
    OP_CMPIeq,
    OP_CMPIlte,
    OP_CMPIgte,
    OP_CMPIulte,
    OP_CMPIugte,
    OP_MOVnw,
    OP_MOVnd,
    OP_NOP2, // dummy
    OP_PUSHn,
    OP_POPn,
    OP_MOVI,
    OP_MOVIn,
    OP_MOVREL,
  };
}

}

#endif
