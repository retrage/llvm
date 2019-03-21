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

static DecodeStatus DecodeGPRRegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > sizeof(GPRDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static const unsigned DRDecoderTable[] = {
  EBC::flags, EBC::ip,
};

static DecodeStatus DecodeDRRegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > sizeof(DRDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = DRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeFRRegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo != 0)
    return MCDisassembler::Fail;

  unsigned Reg = EBC::flags;
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

#include "EBCGenDisassemblerTables.inc"

static void setFlags(MCInst &MI, ArrayRef<uint8_t> Bytes) {
  if (Bytes.size() < 2)
    return;

  unsigned Flags = 0;

  switch (Bytes[0] & 0x3f) {
  case EBC::OP_BREAK:
    Flags |= EBC::BreakCode;
    break;
  case EBC::OP_JMP8:
    Flags |= EBC::Op1Imm8;
    break;
  case EBC::OP_POP:
  case EBC::OP_PUSH:
  case EBC::OP_POPn:
  case EBC::OP_PUSHn:
    if (Bytes[0] & 0x80) {
      if (Bytes[1] & 0x08)
        Flags |= EBC::Op1Idx16;
      else
        Flags |= EBC::Op1Imm16;
    }
    break;
  case EBC::OP_ADD:
  case EBC::OP_AND:
  case EBC::OP_ASHR:
  case EBC::OP_DIV:
  case EBC::OP_DIVU:
  case EBC::OP_MOD:
  case EBC::OP_MODU:
  case EBC::OP_MUL:
  case EBC::OP_MULU:
  case EBC::OP_NEG:
  case EBC::OP_NOT:
  case EBC::OP_OR:
  case EBC::OP_SHL:
  case EBC::OP_SHR:
  case EBC::OP_SUB:
  case EBC::OP_XOR:
  case EBC::OP_EXTNDB:
  case EBC::OP_EXTNDW:
  case EBC::OP_EXTNDD:
  case EBC::OP_CMPeq:
  case EBC::OP_CMPlte:
  case EBC::OP_CMPgte:
  case EBC::OP_CMPulte:
  case EBC::OP_CMPugte:
    if (Bytes[0] & 0x80) {
      if (Bytes[1] & 0x80)
        Flags |= EBC::Op2Idx16;
      else
        Flags |= EBC::Op2Imm16;
    }
    break;
  case EBC::OP_CALL:
  case EBC::OP_JMP:
    if ((Bytes[0] & 0x80) && !(Bytes[0] & 0x40)) {
      if (Bytes[1] & 0x08)
        Flags |= EBC::Op1Idx32;
      else
        Flags |= EBC::Op1Imm32;
    } else if ((Bytes[0] & 0x80) && (Bytes[0] & 0x40))
      Flags |= EBC::Op1Imm64;
    break;
  case EBC::OP_CMPIeq:
  case EBC::OP_CMPIlte:
  case EBC::OP_CMPIgte:
  case EBC::OP_CMPIulte:
  case EBC::OP_CMPIugte:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op2Imm32;
    else
      Flags |= EBC::Op2Imm16;
    if (Bytes[1] & 0x10)
      Flags |= EBC::Op1Idx16;
    break;
  case EBC::OP_MOVbw:
  case EBC::OP_MOVww:
  case EBC::OP_MOVdw:
  case EBC::OP_MOVqw:
  case EBC::OP_MOVnw:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op1Idx16;
    if (Bytes[0] & 0x40)
      Flags |= EBC::Op2Idx16;
    break;
  case EBC::OP_MOVbd:
  case EBC::OP_MOVwd:
  case EBC::OP_MOVdd:
  case EBC::OP_MOVqd:
  case EBC::OP_MOVnd:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op1Idx32;
    if (Bytes[0] & 0x40)
      Flags |= EBC::Op2Idx32;
    break;
  case EBC::OP_MOVqq:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op1Idx64;
    if (Bytes[0] & 0x40)
      Flags |= EBC::Op2Idx64;
    break;
  case EBC::OP_MOVI:
  case EBC::OP_MOVREL:
    switch ((Bytes[0] & 0xc0) >> 6) {
    case 0x01:
      Flags |= EBC::Op2Imm16;
      break;
    case 0x02:
      Flags |= EBC::Op2Imm32;
      break;
    case 0x03:
      Flags |= EBC::Op2Imm64;
      break;
    }
    if (Bytes[1] & 0x40)
      Flags |= EBC::Op1Idx16;
    break;
  case EBC::OP_MOVsnw:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op1Idx16;
    if (Bytes[0] & 0x40) {
      if (Bytes[1] & 0x80)
        Flags |= EBC::Op2Idx16;
      else
        Flags |= EBC::Op2Imm16;
    }
    break;
  case EBC::OP_MOVsnd:
    if (Bytes[0] & 0x80)
      Flags |= EBC::Op1Idx32;
    if (Bytes[0] & 0x40) {
      if (Bytes[1] & 0x80)
        Flags |= EBC::Op2Idx32;
      else
        Flags |= EBC::Op2Imm32;
    }
    break;
  case EBC::OP_MOVIn:
    switch ((Bytes[0] & 0xc0) >> 6) {
    case 0x01:
      Flags |= EBC::Op2Idx16;
      break;
    case 0x02:
      Flags |= EBC::Op2Idx32;
      break;
    case 0x03:
      Flags |= EBC::Op2Idx64;
      break;
    }
    if (Bytes[1] & 0x40)
      Flags |= EBC::Op1Idx16;
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
  int8_t Imm = Bytes[0];
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 1;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm16(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  int16_t Imm = support::endian::read16le(Bytes.data());
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 2;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm32(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  int32_t Imm = support::endian::read32le(Bytes.data());
  MI.addOperand(MCOperand::createImm(Imm));
  Size += 4;
  return MCDisassembler::Success;
}

static DecodeStatus decodeImm64(MCInst &MI, uint64_t &Size,
                                                ArrayRef<uint8_t> Bytes) {
  int64_t Imm = support::endian::read64le(Bytes.data());
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
    return decodeBreakCode(MI, Size, OpBytes);

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

  if (Result != MCDisassembler::Success)
    return Result;

  OpBytes = Bytes.slice(Size);

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
      setFlags(MI, Bytes);
      return setOperands(MI, Size, Bytes);
    }
  }

  {
    uint16_t Insn = support::endian::read16le(Bytes.data());
    LLVM_DEBUG(dbgs() << "Trying EBC 16-bit table :\n");
    Result = decodeInstruction(DecoderTable16, MI, Insn, Address, this, STI);

    if (Result == MCDisassembler::Success) {
      Size = 2;
      setFlags(MI, Bytes);
      return setOperands(MI, Size, Bytes);
    }
  }

  return MCDisassembler::Fail;
}
