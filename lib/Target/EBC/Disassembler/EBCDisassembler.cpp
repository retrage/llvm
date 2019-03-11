//===-- EBCDisassembler.cpp - Disassembler for EBC --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the EBCDisassembler class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCBaseInfo.h"
#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/TargetRegistry.h"

#include <cstdint>

using namespace llvm;

#define DEBUG_TYPE "ebc-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

#include "EBCGenDisassemblerTables.inc"

namespace {
class EBCDisassembler : public MCDisassembler {

public:
  EBCDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
} // end anonymous namespace

static MCDisassembler *createEBCDisassembler(const Target &T,
                                               const MCSubtargetInfo &STI,
                                               MCContext &Ctx) {
  return new EBCDisassembler(STI, Ctx);
}

extern "C" void LLVMInitializeEBCDisassembler() {
  // Register the disassembler for each target.
  TargetRegistry::RegisterMCDisassembler(getTheEBCTarget(),
                                         createEBCDisassembler);
}

static const unsigned GPRDecoderTable[] = {
  EBC::r0, EBC::r1, EBC::r2, EBC::r3,
  EBC::r4, EBC::r5, EBC::r6, EBC::r7,
};

static DecodeStatus DecodeGPRRegisterClass(MCInst &Inst, uint64_t RegNo) {
  if (RegNo > sizeof(GPRDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static const unsigned DRDecoderTable[] = {
  EBC::flags, EBC::ip,
};

static DecodeStatus DecodeDRRegisterClass(MCInst &Inst, uint64_t RegNo) {
  if (RegNo > sizeof(DRDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = DRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeFRRegisterClass(MCInst &Inst, uint64_t RegNo) {
  if (RegNo != 0)
    return MCDisassembler::Fail;

  unsigned Reg = EBC::flags;
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static void setRegFlags(uint8_t Byte, bool &hasOp1GPR, bool &hasOp2GPR) {
  switch (Byte & 0x3f) {
  case 0x01:
  case 0x03:
    if (Byte & 0x40)
      break;
  case 0x2b:
  case 0x2c:
  case 0x2d:
  case 0x2e:
  case 0x2f:
  case 0x30:
  case 0x31:
  case 0x35:
  case 0x36:
  case 0x37:
  case 0x38:
  case 0x39:
    hasOp1GPR = true;
    break;
  default:
    hasOp1GPR = true;
    hasOp2GPR = true;
    break;
  }
}

static DecodeStatus decodeRegs(MCInst &Inst, ArrayRef<uint8_t> Bytes) {
  unsigned Opcode = Inst.getOpcode();
  bool hasOp1GPR = false;
  bool hasOp2GPR = false;
  bool hasOp1FR = false;
  bool hasOp2DR = false;

  switch (Opcode) {
  case EBC::BREAK:
  case EBC::RET:
    return MCDisassembler::Success;
  case EBC::LOADSP:
    hasOp1FR = true;
    hasOp2GPR = true;
    break;
  case EBC::STORESP:
    hasOp1GPR = true;
    hasOp2DR = true;
    break;
  default:
    setRegFlags(Bytes[0], hasOp1GPR, hasOp2GPR);
    break;
  }

  uint8_t tmp;
  DecodeStatus Result;

  tmp = Bytes[1] & 0x07;
  if (hasOp1GPR)
    Result = DecodeGPRRegisterClass(Inst, tmp);
  else if (hasOp1FR)
    Result = DecodeFRRegisterClass(Inst, tmp);

  if (Result != MCDisassembler::Success)
    return Result;

  tmp = (Bytes[1] & 0x70) >> 4;
  if (hasOp2GPR)
    Result = DecodeGPRRegisterClass(Inst, tmp);
  else if (hasOp2DR)
    Result = DecodeDRRegisterClass(Inst, tmp);

  return Result;
}

static void setFlags(MCInst &MI) {
  unsigned Opcode = MI.getOpcode();
  unsigned Flags = 0;

  switch (Opcode) {
  case EBC::BREAK:
    Flags |= EBC::BreakCode;
    break;
  case EBC::JMP8CC:
  case EBC::JMP8CS:
  case EBC::JMP8Uncond:
    Flags |= EBC::Op1Imm8;
    break;
  case EBC::POP32Op1DImm:
  case EBC::POP64Op1DImm:
  case EBC::PUSH32Op1DImm:
  case EBC::PUSH64Op1DImm:
  case EBC::POPnOp1DImm:
  case EBC::PUSHnOp1DImm:
    Flags |= EBC::Op1Imm16;
    break;
  case EBC::ADD32Op1DOp2DImm:
  case EBC::ADD32Op1IOp2DImm:
  case EBC::ADD64Op1DOp2DImm:
  case EBC::ADD64Op1IOp2DImm:
  case EBC::AND32Op1DOp2DImm:
  case EBC::AND32Op1IOp2DImm:
  case EBC::AND64Op1DOp2DImm:
  case EBC::AND64Op1IOp2DImm:
  case EBC::ASHR32Op1DOp2DImm:
  case EBC::ASHR32Op1IOp2DImm:
  case EBC::ASHR64Op1DOp2DImm:
  case EBC::ASHR64Op1IOp2DImm:
  case EBC::DIV32Op1DOp2DImm:
  case EBC::DIV32Op1IOp2DImm:
  case EBC::DIV64Op1DOp2DImm:
  case EBC::DIV64Op1IOp2DImm:
  case EBC::DIVU32Op1DOp2DImm:
  case EBC::DIVU32Op1IOp2DImm:
  case EBC::DIVU64Op1DOp2DImm:
  case EBC::DIVU64Op1IOp2DImm:
  case EBC::MOD32Op1DOp2DImm:
  case EBC::MOD32Op1IOp2DImm:
  case EBC::MOD64Op1DOp2DImm:
  case EBC::MOD64Op1IOp2DImm:
  case EBC::MODU32Op1DOp2DImm:
  case EBC::MODU32Op1IOp2DImm:
  case EBC::MODU64Op1DOp2DImm:
  case EBC::MODU64Op1IOp2DImm:
  case EBC::MUL32Op1DOp2DImm:
  case EBC::MUL32Op1IOp2DImm:
  case EBC::MUL64Op1DOp2DImm:
  case EBC::MUL64Op1IOp2DImm:
  case EBC::MULU32Op1DOp2DImm:
  case EBC::MULU32Op1IOp2DImm:
  case EBC::MULU64Op1DOp2DImm:
  case EBC::MULU64Op1IOp2DImm:
  case EBC::NEG32Op1DOp2DImm:
  case EBC::NEG32Op1IOp2DImm:
  case EBC::NEG64Op1DOp2DImm:
  case EBC::NEG64Op1IOp2DImm:
  case EBC::NOT32Op1DOp2DImm:
  case EBC::NOT32Op1IOp2DImm:
  case EBC::NOT64Op1DOp2DImm:
  case EBC::NOT64Op1IOp2DImm:
  case EBC::OR32Op1DOp2DImm:
  case EBC::OR32Op1IOp2DImm:
  case EBC::OR64Op1DOp2DImm:
  case EBC::OR64Op1IOp2DImm:
  case EBC::SHL32Op1DOp2DImm:
  case EBC::SHL32Op1IOp2DImm:
  case EBC::SHL64Op1DOp2DImm:
  case EBC::SHL64Op1IOp2DImm:
  case EBC::SHR32Op1DOp2DImm:
  case EBC::SHR32Op1IOp2DImm:
  case EBC::SHR64Op1DOp2DImm:
  case EBC::SHR64Op1IOp2DImm:
  case EBC::SUB32Op1DOp2DImm:
  case EBC::SUB32Op1IOp2DImm:
  case EBC::SUB64Op1DOp2DImm:
  case EBC::SUB64Op1IOp2DImm:
  case EBC::XOR32Op1DOp2DImm:
  case EBC::XOR32Op1IOp2DImm:
  case EBC::XOR64Op1DOp2DImm:
  case EBC::XOR64Op1IOp2DImm:
  case EBC::EXTNDB32Op1DOp2DImm:
  case EBC::EXTNDB32Op1IOp2DImm:
  case EBC::EXTNDB64Op1DOp2DImm:
  case EBC::EXTNDB64Op1IOp2DImm:
  case EBC::EXTNDW32Op1DOp2DImm:
  case EBC::EXTNDW32Op1IOp2DImm:
  case EBC::EXTNDW64Op1DOp2DImm:
  case EBC::EXTNDW64Op1IOp2DImm:
  case EBC::EXTNDD32Op1DOp2DImm:
  case EBC::EXTNDD32Op1IOp2DImm:
  case EBC::EXTNDD64Op1DOp2DImm:
  case EBC::EXTNDD64Op1IOp2DImm:
  case EBC::CMPeq32Op2DImm:
  case EBC::CMPeq64Op2DImm:
  case EBC::CMPlte32Op2DImm:
  case EBC::CMPlte64Op2DImm:
  case EBC::CMPgte32Op2DImm:
  case EBC::CMPgte64Op2DImm:
  case EBC::CMPulte32Op2DImm:
  case EBC::CMPulte64Op2DImm:
  case EBC::CMPugte32Op2DImm:
  case EBC::CMPugte64Op2DImm:
    Flags |= EBC::Op2Imm16;
    break;
  case EBC::POP32Op1IIdx:
  case EBC::POP64Op1IIdx:
  case EBC::PUSH32Op1IIdx:
  case EBC::PUSH64Op1IIdx:
  case EBC::POPnOp1IIdx:
  case EBC::PUSHnOp1IIdx:
    Flags |= EBC::Op1Idx16;
    break;
  case EBC::ADD32Op1DOp2IIdx:
  case EBC::ADD32Op1IOp2IIdx:
  case EBC::ADD64Op1DOp2IIdx:
  case EBC::ADD64Op1IOp2IIdx:
  case EBC::AND32Op1DOp2IIdx:
  case EBC::AND32Op1IOp2IIdx:
  case EBC::AND64Op1DOp2IIdx:
  case EBC::AND64Op1IOp2IIdx:
  case EBC::ASHR32Op1DOp2IIdx:
  case EBC::ASHR32Op1IOp2IIdx:
  case EBC::ASHR64Op1DOp2IIdx:
  case EBC::ASHR64Op1IOp2IIdx:
  case EBC::DIV32Op1DOp2IIdx:
  case EBC::DIV32Op1IOp2IIdx:
  case EBC::DIV64Op1DOp2IIdx:
  case EBC::DIV64Op1IOp2IIdx:
  case EBC::DIVU32Op1DOp2IIdx:
  case EBC::DIVU32Op1IOp2IIdx:
  case EBC::DIVU64Op1DOp2IIdx:
  case EBC::DIVU64Op1IOp2IIdx:
  case EBC::MOD32Op1DOp2IIdx:
  case EBC::MOD32Op1IOp2IIdx:
  case EBC::MOD64Op1DOp2IIdx:
  case EBC::MOD64Op1IOp2IIdx:
  case EBC::MODU32Op1DOp2IIdx:
  case EBC::MODU32Op1IOp2IIdx:
  case EBC::MODU64Op1DOp2IIdx:
  case EBC::MODU64Op1IOp2IIdx:
  case EBC::MUL32Op1DOp2IIdx:
  case EBC::MUL32Op1IOp2IIdx:
  case EBC::MUL64Op1DOp2IIdx:
  case EBC::MUL64Op1IOp2IIdx:
  case EBC::MULU32Op1DOp2IIdx:
  case EBC::MULU32Op1IOp2IIdx:
  case EBC::MULU64Op1DOp2IIdx:
  case EBC::MULU64Op1IOp2IIdx:
  case EBC::NEG32Op1DOp2IIdx:
  case EBC::NEG32Op1IOp2IIdx:
  case EBC::NEG64Op1DOp2IIdx:
  case EBC::NEG64Op1IOp2IIdx:
  case EBC::NOT32Op1DOp2IIdx:
  case EBC::NOT32Op1IOp2IIdx:
  case EBC::NOT64Op1DOp2IIdx:
  case EBC::NOT64Op1IOp2IIdx:
  case EBC::OR32Op1DOp2IIdx:
  case EBC::OR32Op1IOp2IIdx:
  case EBC::OR64Op1DOp2IIdx:
  case EBC::OR64Op1IOp2IIdx:
  case EBC::SHL32Op1DOp2IIdx:
  case EBC::SHL32Op1IOp2IIdx:
  case EBC::SHL64Op1DOp2IIdx:
  case EBC::SHL64Op1IOp2IIdx:
  case EBC::SHR32Op1DOp2IIdx:
  case EBC::SHR32Op1IOp2IIdx:
  case EBC::SHR64Op1DOp2IIdx:
  case EBC::SHR64Op1IOp2IIdx:
  case EBC::SUB32Op1DOp2IIdx:
  case EBC::SUB32Op1IOp2IIdx:
  case EBC::SUB64Op1DOp2IIdx:
  case EBC::SUB64Op1IOp2IIdx:
  case EBC::XOR32Op1DOp2IIdx:
  case EBC::XOR32Op1IOp2IIdx:
  case EBC::XOR64Op1DOp2IIdx:
  case EBC::XOR64Op1IOp2IIdx:
  case EBC::EXTNDB32Op1DOp2IIdx:
  case EBC::EXTNDB32Op1IOp2IIdx:
  case EBC::EXTNDB64Op1DOp2IIdx:
  case EBC::EXTNDB64Op1IOp2IIdx:
  case EBC::EXTNDW32Op1DOp2IIdx:
  case EBC::EXTNDW32Op1IOp2IIdx:
  case EBC::EXTNDW64Op1DOp2IIdx:
  case EBC::EXTNDW64Op1IOp2IIdx:
  case EBC::EXTNDD32Op1DOp2IIdx:
  case EBC::EXTNDD32Op1IOp2IIdx:
  case EBC::EXTNDD64Op1DOp2IIdx:
  case EBC::EXTNDD64Op1IOp2IIdx:
  case EBC::CMPeq32Op2IIdx:
  case EBC::CMPeq64Op2IIdx:
  case EBC::CMPlte32Op2IIdx:
  case EBC::CMPlte64Op2IIdx:
  case EBC::CMPgte32Op2IIdx:
  case EBC::CMPgte64Op2IIdx:
  case EBC::CMPulte32Op2IIdx:
  case EBC::CMPulte64Op2IIdx:
  case EBC::CMPugte32Op2IIdx:
  case EBC::CMPugte64Op2IIdx:
    Flags |= EBC::Op2Idx16;
    break;
  case EBC::CALL32Op1DEBCAbsImm: 
  case EBC::CALL32Op1DEBCRelImm:
  case EBC::CALL32Op1DNativeAbsImm:
  case EBC::CALL32Op1DNativeRelImm:
  case EBC::JMP32CCAbsOp1DImm:
  case EBC::JMP32CCRelOp1DImm:
  case EBC::JMP32CSAbsOp1DImm:
  case EBC::JMP32CSRelOp1DImm:
  case EBC::JMP32UncondAbsOp1DImm:
  case EBC::JMP32UncondRelOp1DImm:
    Flags |= EBC::Op1Imm32;
    break;
  case EBC::CALL32Op1IEBCAbsIdx:
  case EBC::CALL32Op1IEBCRelIdx:
  case EBC::CALL32Op1INativeAbsIdx:
  case EBC::CALL32Op1INativeRelIdx:
  case EBC::JMP32CCAbsOp1IIdx:
  case EBC::JMP32CCRelOp1IIdx:
  case EBC::JMP32CSAbsOp1IIdx:
  case EBC::JMP32CSRelOp1IIdx:
  case EBC::JMP32UncondAbsOp1IIdx:
  case EBC::JMP32UncondRelOp1IIdx:
    Flags |= EBC::Op1Idx32;
    break;
  case EBC::CALL64EBCAbsImm:
  case EBC::CALL64EBCRelImm: 
  case EBC::CALL64NativeAbsImm:
  case EBC::CALL64NativeRelImm:
  case EBC::JMP64CCAbsImm:
  case EBC::JMP64CCRelImm:
  case EBC::JMP64CSAbsImm:
  case EBC::JMP64CSRelImm:
  case EBC::JMP64UncondAbsImm:
  case EBC::JMP64UncondRelImm:
    Flags |= EBC::Op1Imm64;
    break;
  case EBC::CMPIeq32wOp1IIdx:
  case EBC::CMPIeq64wOp1IIdx:
  case EBC::CMPIlte32wOp1IIdx:
  case EBC::CMPIlte64wOp1IIdx:
  case EBC::CMPIgte32wOp1IIdx:
  case EBC::CMPIgte64wOp1IIdx:
  case EBC::CMPIulte32wOp1IIdx:
  case EBC::CMPIulte64wOp1IIdx:
  case EBC::CMPIugte32wOp1IIdx:
  case EBC::CMPIugte64wOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::CMPIeq32wOp1D:
  case EBC::CMPIeq32wOp1I:
  case EBC::CMPIeq64wOp1D:
  case EBC::CMPIeq64wOp1I:
  case EBC::CMPIlte32wOp1D:
  case EBC::CMPIlte32wOp1I:
  case EBC::CMPIlte64wOp1D:
  case EBC::CMPIlte64wOp1I:
  case EBC::CMPIgte32wOp1D:
  case EBC::CMPIgte32wOp1I:
  case EBC::CMPIgte64wOp1D:
  case EBC::CMPIgte64wOp1I:
  case EBC::CMPIulte32wOp1D:
  case EBC::CMPIulte32wOp1I:
  case EBC::CMPIulte64wOp1D:
  case EBC::CMPIulte64wOp1I:
  case EBC::CMPIugte32wOp1D:
  case EBC::CMPIugte32wOp1I:
  case EBC::CMPIugte64wOp1D:
  case EBC::CMPIugte64wOp1I:
    Flags |= EBC::Op2Imm16;
    break;
  case EBC::CMPIeq32dOp1IIdx:
  case EBC::CMPIeq64dOp1IIdx:
  case EBC::CMPIlte32dOp1IIdx:
  case EBC::CMPIlte64dOp1IIdx:
  case EBC::CMPIgte32dOp1IIdx:
  case EBC::CMPIgte64dOp1IIdx:
  case EBC::CMPIulte32dOp1IIdx:
  case EBC::CMPIulte64dOp1IIdx:
  case EBC::CMPIugte32dOp1IIdx:
  case EBC::CMPIugte64dOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::CMPIeq32dOp1D:
  case EBC::CMPIeq32dOp1I:
  case EBC::CMPIeq64dOp1D:
  case EBC::CMPIeq64dOp1I:
  case EBC::CMPIlte32dOp1D:
  case EBC::CMPIlte32dOp1I:
  case EBC::CMPIlte64dOp1D:
  case EBC::CMPIlte64dOp1I:
  case EBC::CMPIgte32dOp1D:
  case EBC::CMPIgte32dOp1I:
  case EBC::CMPIgte64dOp1D:
  case EBC::CMPIgte64dOp1I:
  case EBC::CMPIulte32dOp1D:
  case EBC::CMPIulte32dOp1I:
  case EBC::CMPIulte64dOp1D:
  case EBC::CMPIulte64dOp1I:
  case EBC::CMPIugte32dOp1D:
  case EBC::CMPIugte32dOp1I:
  case EBC::CMPIugte64dOp1D:
  case EBC::CMPIugte64dOp1I:
    Flags |= EBC::Op2Imm32;
    break;
  case EBC::MOVbwOp1IIdxOp2D:
  case EBC::MOVbwOp1IIdxOp2I:
  case EBC::MOVwwOp1IIdxOp2D:
  case EBC::MOVwwOp1IIdxOp2I:
  case EBC::MOVdwOp1IIdxOp2D:
  case EBC::MOVdwOp1IIdxOp2I:
  case EBC::MOVqwOp1IIdxOp2D:
  case EBC::MOVqwOp1IIdxOp2I:
  case EBC::MOVnwOp1IIdxOp2D:
  case EBC::MOVnwOp1IIdxOp2I:
    Flags |= EBC::Op1Idx16;
    break;
  case EBC::MOVbwOp1DOp2DIdx:
  case EBC::MOVbwOp1IOp2DIdx:
  case EBC::MOVwwOp1DOp2DIdx:
  case EBC::MOVwwOp1IOp2DIdx:
  case EBC::MOVdwOp1DOp2DIdx:
  case EBC::MOVdwOp1IOp2DIdx:
  case EBC::MOVqwOp1DOp2DIdx:
  case EBC::MOVqwOp1IOp2DIdx:
  case EBC::MOVbwOp1DOp2IIdx:
  case EBC::MOVbwOp1IOp2IIdx:
  case EBC::MOVwwOp1DOp2IIdx:
  case EBC::MOVwwOp1IOp2IIdx:
  case EBC::MOVdwOp1DOp2IIdx:
  case EBC::MOVdwOp1IOp2IIdx:
  case EBC::MOVqwOp1DOp2IIdx:
  case EBC::MOVqwOp1IOp2IIdx:
  case EBC::MOVnwOp1DOp2IIdx:
  case EBC::MOVnwOp1IOp2IIdx:
    Flags |= EBC::Op2Idx16;
    break;
  case EBC::MOVbwOp1IIdxOp2DIdx:
  case EBC::MOVwwOp1IIdxOp2DIdx:
  case EBC::MOVdwOp1IIdxOp2DIdx:
  case EBC::MOVqwOp1IIdxOp2DIdx:
  case EBC::MOVbwOp1IIdxOp2IIdx:
  case EBC::MOVwwOp1IIdxOp2IIdx:
  case EBC::MOVdwOp1IIdxOp2IIdx:
  case EBC::MOVqwOp1IIdxOp2IIdx:
  case EBC::MOVnwOp1IIdxOp2IIdx:
    Flags |= EBC::Op1Idx16;
    Flags |= EBC::Op2Idx16;
    break;
  case EBC::MOVbdOp1IIdxOp2D:
  case EBC::MOVbdOp1IIdxOp2I:
  case EBC::MOVwdOp1IIdxOp2D:
  case EBC::MOVwdOp1IIdxOp2I:
  case EBC::MOVddOp1IIdxOp2D:
  case EBC::MOVddOp1IIdxOp2I:
  case EBC::MOVqdOp1IIdxOp2D:
  case EBC::MOVqdOp1IIdxOp2I:
  case EBC::MOVndOp1IIdxOp2D:
  case EBC::MOVndOp1IIdxOp2I:
    Flags |= EBC::Op1Idx32;
    break;
  case EBC::MOVbdOp1DOp2DIdx:
  case EBC::MOVbdOp1IOp2DIdx:
  case EBC::MOVwdOp1DOp2DIdx:
  case EBC::MOVwdOp1IOp2DIdx:
  case EBC::MOVddOp1DOp2DIdx:
  case EBC::MOVddOp1IOp2DIdx:
  case EBC::MOVqdOp1DOp2DIdx:
  case EBC::MOVqdOp1IOp2DIdx:
  case EBC::MOVbdOp1DOp2IIdx:
  case EBC::MOVbdOp1IOp2IIdx:
  case EBC::MOVwdOp1DOp2IIdx:
  case EBC::MOVwdOp1IOp2IIdx:
  case EBC::MOVddOp1DOp2IIdx:
  case EBC::MOVddOp1IOp2IIdx:
  case EBC::MOVqdOp1DOp2IIdx:
  case EBC::MOVqdOp1IOp2IIdx:
  case EBC::MOVndOp1DOp2IIdx:
  case EBC::MOVndOp1IOp2IIdx:
    Flags |= EBC::Op2Idx32;
    break;
  case EBC::MOVbdOp1IIdxOp2DIdx:
  case EBC::MOVwdOp1IIdxOp2DIdx:
  case EBC::MOVddOp1IIdxOp2DIdx:
  case EBC::MOVqdOp1IIdxOp2DIdx:
  case EBC::MOVbdOp1IIdxOp2IIdx:
  case EBC::MOVwdOp1IIdxOp2IIdx:
  case EBC::MOVddOp1IIdxOp2IIdx:
  case EBC::MOVqdOp1IIdxOp2IIdx:
  case EBC::MOVndOp1IIdxOp2IIdx:
    Flags |= EBC::Op1Idx32;
    Flags |= EBC::Op2Idx32;
    break;
  case EBC::MOVqqOp1IIdxOp2D:
  case EBC::MOVqqOp1IIdxOp2I:
    Flags |= EBC::Op1Idx64;
    break;
  case EBC::MOVqqOp1DOp2DIdx:
  case EBC::MOVqqOp1IOp2DIdx:
  case EBC::MOVqqOp1DOp2IIdx:
  case EBC::MOVqqOp1IOp2IIdx:
    Flags |= EBC::Op2Idx64;
    break;
  case EBC::MOVqqOp1IIdxOp2DIdx:
  case EBC::MOVqqOp1IIdxOp2IIdx:
    Flags |= EBC::Op1Idx64;
    Flags |= EBC::Op2Idx64;
    break;
  case EBC::MOVIbwOp1IIdx:
  case EBC::MOVIwwOp1IIdx:
  case EBC::MOVIdwOp1IIdx:
  case EBC::MOVIqwOp1IIdx:
  case EBC::MOVRELwOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVIbwOp1D:
  case EBC::MOVIbwOp1I:
  case EBC::MOVIwwOp1D:
  case EBC::MOVIwwOp1I:
  case EBC::MOVIdwOp1D:
  case EBC::MOVIdwOp1I:
  case EBC::MOVIqwOp1D:
  case EBC::MOVIqwOp1I:
  case EBC::MOVRELwOp1D:
  case EBC::MOVRELwOp1I:
    Flags |= EBC::Op2Imm16;
    break;
  case EBC::MOVIbdOp1IIdx:
  case EBC::MOVIwdOp1IIdx:
  case EBC::MOVIddOp1IIdx:
  case EBC::MOVIqdOp1IIdx:
  case EBC::MOVRELdOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVIbdOp1D:
  case EBC::MOVIbdOp1I:
  case EBC::MOVIwdOp1D:
  case EBC::MOVIwdOp1I:
  case EBC::MOVIddOp1D:
  case EBC::MOVIddOp1I:
  case EBC::MOVIqdOp1D:
  case EBC::MOVIqdOp1I:
  case EBC::MOVRELdOp1D:
  case EBC::MOVRELdOp1I:
    Flags |= EBC::Op2Imm32;
    break;
  case EBC::MOVIbqOp1IIdx:
  case EBC::MOVIwqOp1IIdx:
  case EBC::MOVIdqOp1IIdx:
  case EBC::MOVIqqOp1IIdx:
  case EBC::MOVRELqOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVIbqOp1D:
  case EBC::MOVIbqOp1I:
  case EBC::MOVIwqOp1D:
  case EBC::MOVIwqOp1I:
  case EBC::MOVIdqOp1D:
  case EBC::MOVIdqOp1I:
  case EBC::MOVIqqOp1D:
  case EBC::MOVIqqOp1I:
  case EBC::MOVRELqOp1D:
  case EBC::MOVRELqOp1I:
    Flags |= EBC::Op2Imm64;
    break;
  case EBC::MOVsnwOp1IIdxOp2DImm:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVsnwOp1DOp2DImm:
  case EBC::MOVsnwOp1IOp2DImm:
    Flags |= EBC::Op2Imm16;
    break;
  case EBC::MOVsnwOp1IIdxOp2IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVsnwOp1DOp2IIdx:
  case EBC::MOVsnwOp1IOp2IIdx:
    Flags |= EBC::Op2Idx16;
    break;
  case EBC::MOVsndOp1IIdxOp2DImm:
    Flags |= EBC::Op1Idx32;
    // Fall through
  case EBC::MOVsndOp1DOp2DImm:
  case EBC::MOVsndOp1IOp2DImm:
    Flags |= EBC::Op2Imm32;
    break;
  case EBC::MOVsndOp1IIdxOp2IIdx:
    Flags |= EBC::Op1Idx32;
    // Fall through
  case EBC::MOVsndOp1DOp2IIdx:
  case EBC::MOVsndOp1IOp2IIdx:
    Flags |= EBC::Op2Idx32;
    break;
  case EBC::MOVInwOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVInwOp1D:
  case EBC::MOVInwOp1I:
    Flags |= EBC::Op2Idx16;
    break;
  case EBC::MOVIndOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVIndOp1D:
  case EBC::MOVIndOp1I:
    Flags |= EBC::Op2Idx32;
    break;
  case EBC::MOVInqOp1IIdx:
    Flags |= EBC::Op1Idx16;
    // Fall through
  case EBC::MOVInqOp1D:
  case EBC::MOVInqOp1I:
    Flags |= EBC::Op2Idx64;
    break;
  }

  MI.setFlags(Flags);
}

static DecodeStatus decodeBreakCode(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint8_t BreakCode = Bytes[0];
  assert(isUInt<8>(BreakCode) && "Invalid break code");
  MI.addOperand(MCOperand::createImm(BreakCode));
  Size += 1;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm8(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint8_t Imm = Bytes[0];
  assert(isInt<8>(Imm) && "Invalid immediate");
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 1;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm16(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint16_t Imm = support::endian::read16le(Bytes.data());
  assert(isInt<16>(Imm) && "Invalid immediate");
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 2;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm32(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint32_t Imm = support::endian::read32le(Bytes.data());
  assert(isInt<32>(Imm) && "Invalid immediate");
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 4;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm64(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint64_t Imm = support::endian::read64le(Bytes.data());
  assert(isInt<64>(Imm) && "Invalid immediate");
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 8;
  return MCDisassembler::Success;
}

static DecodeStatus decodeIdx16(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint16_t Idx = support::endian::read16le(Bytes.data());

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit
  bool Sign = Idx >> 15;
  uint8_t Assigned = (Idx & (0x7 << 12)) >> 12;
  unsigned NaturalLen = Assigned * 2;
  unsigned ConstantLen = 16 - (UsedBits + NaturalLen);
  uint16_t NaturalMask = UINT16_MAX >> (UsedBits + ConstantLen);
  uint16_t ConstantMask = (UINT16_MAX >> (UsedBits + NaturalLen)) << NaturalLen;

  int16_t Natural = (Sign ? -1 : 1) * (Idx & NaturalMask);
  int16_t Constant = (Sign ? -1 : 1) * ((Idx & ConstantMask) >> NaturalLen);

  MI.addOperand(MCOperand::createImm(Natural));
  MI.addOperand(MCOperand::createImm(Constant));
  Size += 2;
  
  return MCDisassembler::Success;
}

static DecodeStatus decodeIdx32(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint32_t Idx = support::endian::read32le(Bytes.data());

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit
  bool Sign = Idx >> 31;
  uint8_t Assigned = (Idx & (0x7 << 28)) >> 28;
  unsigned NaturalLen = Assigned * 4;
  unsigned ConstantLen = 32 - (UsedBits + NaturalLen);
  uint32_t NaturalMask = UINT32_MAX >> (UsedBits + ConstantLen);
  uint32_t ConstantMask = (UINT32_MAX >> (UsedBits + NaturalLen)) << NaturalLen;

  int32_t Natural = (Sign ? -1 : 1) * (Idx & NaturalMask);
  int32_t Constant = (Sign ? -1 : 1) * ((Idx & ConstantMask) >> NaturalLen);

  MI.addOperand(MCOperand::createImm(Natural));
  MI.addOperand(MCOperand::createImm(Constant));
  Size += 4;
  
  return MCDisassembler::Success;
}

static DecodeStatus decodeIdx64(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  uint64_t Idx = support::endian::read64le(Bytes.data());

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit
  bool Sign = Idx >> 63;
  uint8_t Assigned = (Idx & ((uint64_t)0x7 << 60)) >> 60;
  unsigned NaturalLen = Assigned * 8;
  unsigned ConstantLen = 64 - (UsedBits + NaturalLen);
  uint64_t NaturalMask = UINT64_MAX >> (UsedBits + ConstantLen);
  uint64_t ConstantMask = (UINT64_MAX >> (UsedBits + NaturalLen)) << NaturalLen;

  int64_t Natural = (Sign ? -1 : 1) * (Idx & NaturalMask);
  int64_t Constant = (Sign ? -1 : 1) * ((Idx & ConstantMask) >> NaturalLen);

  MI.addOperand(MCOperand::createImm(Natural));
  MI.addOperand(MCOperand::createImm(Constant));
  Size += 8;
  
  return MCDisassembler::Success;
}

static DecodeStatus setOperands(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  DecodeStatus Result = MCDisassembler::Success;
  unsigned Flags = MI.getFlags();

  ArrayRef<uint8_t> OpBytes = Bytes.slice(Size);

  if (Flags & EBC::BreakCode)
    return decodeBreakCode(MI, Size, Bytes);

  if (Flags & EBC::Op1Imm8)
    Result = decodeImm8(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Imm16)
    Result = decodeImm16(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Imm32)
    Result = decodeImm32(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Imm64)
    Result = decodeImm64(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Idx16)
    Result = decodeIdx16(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Idx32)
    Result = decodeIdx32(MI, Size, OpBytes);
  else if (Flags & EBC::Op1Idx64)
    Result = decodeIdx64(MI, Size, OpBytes);

  OpBytes = Bytes.slice(Size);

  if (Result != MCDisassembler::Success)
    return Result;

  if (Flags & EBC::Op2Imm16)
    Result = decodeImm16(MI, Size, OpBytes);
  else if (Flags & EBC::Op2Imm32)
    Result = decodeImm32(MI, Size, OpBytes);
  else if (Flags & EBC::Op2Imm64)
    Result = decodeImm64(MI, Size, OpBytes);
  else if (Flags & EBC::Op2Idx16)
    Result = decodeIdx16(MI, Size, OpBytes);
  else if (Flags & EBC::Op2Idx32)
    Result = decodeIdx32(MI, Size, OpBytes);
  else if (Flags & EBC::Op2Idx64)
    Result = decodeIdx64(MI, Size, OpBytes);

  return Result;
}

DecodeStatus EBCDisassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                               ArrayRef<uint8_t> Bytes,
                                               uint64_t Address,
                                               raw_ostream &OS,
                                               raw_ostream &CS) const {
  DecodeStatus Result;

  if (Bytes.size() < 2) {
    Size = 0;
    return MCDisassembler::Fail;
  }

  {
    uint8_t Insn = Bytes[0];
    LLVM_DEBUG(dbgs() << "Trying EBC 8-bit table :\n");
    Result = decodeInstruction(DecoderTable8, MI, Insn, Address, this, STI);
    if (Result == MCDisassembler::Success) {
      Size = 1;
      if (decodeRegs(MI, Bytes) != MCDisassembler::Success)
        return MCDisassembler::Fail;
      setFlags(MI);
      return setOperands(MI, Size, Bytes);
    }
  }

  {
    uint16_t Insn = support::endian::read16le(Bytes.data());
    LLVM_DEBUG(dbgs() << "Trying EBC 16-bit table :\n");
    Result = decodeInstruction(DecoderTable16, MI, Insn, Address, this, STI);

    if (Result == MCDisassembler::Success) {
      Size = 2;
      if (decodeRegs(MI, Bytes) != MCDisassembler::Success)
        return MCDisassembler::Fail;
      setFlags(MI);
      return setOperands(MI, Size, Bytes);
    }
  }

  return MCDisassembler::Fail;
}
