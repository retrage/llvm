//===-- EBCMCTargetDesc.h - EBC Target Descriptions ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides EBC specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCMCTARGETDESC_H
#define LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCMCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCTargetStreamer;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;

Target &getTheEBCTarget();

MCCodeEmitter *createEBCMCCodeEmitter(const MCInstrInfo &MCII,
                                        const MCRegisterInfo &MRI,
                                        MCContext &Ctx);

MCAsmBackend *createEBCAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                    const MCRegisterInfo &MRI,
                                    const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter> createEBCCOFFObjectWriter();

namespace EBC {
enum OperandType {
  /// break code
  OPERAND_BREAKCODE,
  /// 16-bit immediates
  OPERAND_IMM16,
  /// 32-bit immediates
  OPERAND_IMM32,
  /// 64-bit immediates
  OPERAND_IMM64,
  /// 16-bit index natural units
  OPERAND_IDXN16,
  /// 16-bit index constant units
  OPERAND_IDXC16,
  /// 32-bit index natural units
  OPERAND_IDXN32,
  /// 32-bit index constant units
  OPERAND_IDXC32,
  /// 64-bit index natural units
  OPERAND_IDXN64,
  /// 64-bit index constant units
  OPERAND_IDXC64,
  /// 8-bit immediates for JMP8
  OPERAND_IMM8_JMP,
  /// 64-bit immediates for JMP64
  OPERAND_IMM64_JMP,
};
}

}

// Defines symbolic names for EBC registers.
#define GET_REGINFO_ENUM
#include "EBCGenRegisterInfo.inc"

// Defines symbolic names for EBC instructions.
#define GET_INSTRINFO_ENUM
#include "EBCGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "EBCGenSubtargetInfo.inc"

#endif
