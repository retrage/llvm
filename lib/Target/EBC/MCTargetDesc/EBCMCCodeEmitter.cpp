//===-- EBCMCCodeEmitter.cpp - Convert EBC code to machine code -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the EBCMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCFixupKinds.h"
#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");
STATISTIC(MCNumFixups, "Number of MC fixups created");

namespace {

class EBCMCCodeEmitter : public MCCodeEmitter {
  EBCMCCodeEmitter(const EBCMCCodeEmitter &) = delete;
  void operator=(const EBCMCCodeEmitter &) = delete;
  MCContext &Ctx;
  MCInstrInfo const &MCII;

public:
  EBCMCCodeEmitter(MCContext &ctx, MCInstrInfo const &MCII)
    : Ctx(ctx), MCII(MCII) {}

  ~EBCMCCodeEmitter() override {}

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  /// TableGen'erated function for getting the binary encoding for an
  /// instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  /// Return binary encoding of operand. If the machine operand requires
  /// relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  uint16_t getIdx16Value(const MCOperand &NMO, const MCOperand &CMO) const;
  uint32_t getIdx32Value(const MCOperand &NMO, const MCOperand &CMO) const;
  uint64_t getIdx64Value(const MCOperand &NMO, const MCOperand &CMO) const;

};

} // end anonymous namespace

MCCodeEmitter *llvm::createEBCMCCodeEmitter(const MCInstrInfo &MCII,
                                              const MCRegisterInfo &MRI,
                                              MCContext &Ctx) {
  return new EBCMCCodeEmitter(Ctx, MCII);
}

void EBCMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                           SmallVectorImpl<MCFixup> &Fixups,
                                           const MCSubtargetInfo &STI) const {
  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());
  // Get byte count of instruction
  unsigned Size = Desc.getSize();

  switch (Size) {
  default:
    llvm_unreachable("Unhandled encodeInstruction length!");
  case 1: {
    uint8_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
    support::endian::write<uint8_t>(OS, Bits, support::little);
    break;
  }
  case 2: {
    uint16_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
    support::endian::write<uint16_t>(OS, Bits, support::little);
    break;
  }
  }

  for (unsigned I = 0, E = MI.getNumOperands(); I < E; ++I)
    getMachineOpValue(MI, MI.getOperand(I), Fixups, STI);

  // Emit Indexes
  for (unsigned I = 0, E = MI.getNumOperands(); I < E; ++I) {
    const MCOperand &MO = MI.getOperand(I);
    if (MO.isReg()) {
      /* nothing to encode */
    } else if (MO.isImm()) {
      const MCOperandInfo &Info = Desc.OpInfo[I];
      switch (Info.OperandType) {
      case EBC::OPERAND_BREAKCODE:
      case EBC::OPERAND_IMM8:
      case EBC::OPERAND_IMM16:
      case EBC::OPERAND_IMM32:
      case EBC::OPERAND_IMM64:
      case EBC::OPERAND_JMP64:
        break;
      case EBC::OPERAND_IDXN16: {
          // Assume next operand is OPERAND_IDXC16
          const MCOperand &CMO = MI.getOperand(I + 1);
          uint16_t Index = getIdx16Value(MO, CMO);
          support::endian::write<uint16_t>(OS, Index, support::little);
          // Skip next operand
          ++I;
          break;
        }
      case EBC::OPERAND_IDXN32: {
          // Assume next operand is OPERAND_IDXC32
          const MCOperand &CMO = MI.getOperand(I + 1);
          uint32_t Index = getIdx32Value(MO, CMO);
          support::endian::write<uint32_t>(OS, Index, support::little);
          // Skip next operand
          ++I;
          break;
        }
      case EBC::OPERAND_IDXN64: {
          // Assume next operand is OPERAND_IDXC64
          const MCOperand &CMO = MI.getOperand(I + 1);
          uint64_t Index = getIdx64Value(MO, CMO);
          support::endian::write<uint64_t>(OS, Index, support::little);
          // Skip next operand
          ++I;
          break;
        }
      case EBC::OPERAND_IDXC16:
      case EBC::OPERAND_IDXC32:
      case EBC::OPERAND_IDXC64:
      default:
        llvm_unreachable("Unhandled OperandType!");
      }
    }
  }

  // Emit 0 for fixups
  for (unsigned I = 0, E = Fixups.size(); I < E; ++I) {
    unsigned Kind = Fixups[I].getKind();
    switch (Kind) {
    case EBC::fixup_ebc_invalid:
    default:
      llvm_unreachable("Unhandled FixupKind!");
    case EBC::fixup_ebc_pcrel_imm8:
      support::endian::write<uint8_t>(OS, 0, support::little);
      break;
    case EBC::fixup_ebc_imm16:
    case EBC::fixup_ebc_pcrel_imm16:
      support::endian::write<uint16_t>(OS, 0, support::little);
      break;
    case EBC::fixup_ebc_imm32:
    case EBC::fixup_ebc_pcrel_imm32:
    case EBC::fixup_ebc_pcrel_call32:
      support::endian::write<uint32_t>(OS, 0, support::little);
      break;
    case EBC::fixup_ebc_imm64:
    case EBC::fixup_ebc_pcrel_imm64:
      support::endian::write<uint64_t>(OS, 0, support::little);
      break;
    }
  }

  // Emit Immediates
  for (unsigned I = 0, E = MI.getNumOperands(); I < E; ++I) {
    const MCOperand &MO = MI.getOperand(I);
    if (MO.isReg()) {
      /* nothing to encode */
    } else if (MO.isImm()) {
      const MCOperandInfo &Info = Desc.OpInfo[I];
      switch (Info.OperandType) {
      case EBC::OPERAND_BREAKCODE:
      case EBC::OPERAND_IMM8:
        support::endian::write<uint8_t>(OS, MO.getImm(), support::little);
        break;
      case EBC::OPERAND_IMM16:
        support::endian::write<uint16_t>(OS, MO.getImm(), support::little);
        break;
      case EBC::OPERAND_IMM32:
        support::endian::write<uint32_t>(OS, MO.getImm(), support::little);
        break;
      case EBC::OPERAND_IMM64:
      case EBC::OPERAND_JMP64:
        support::endian::write<uint64_t>(OS, MO.getImm(), support::little);
        break;
      case EBC::OPERAND_IDXN16:
      case EBC::OPERAND_IDXC16:
      case EBC::OPERAND_IDXN32:
      case EBC::OPERAND_IDXC32:
      case EBC::OPERAND_IDXN64:
      case EBC::OPERAND_IDXC64:
        break;
      default:
        llvm_unreachable("Unhandled OperandType!");
      }
    }
  }

  ++MCNumEmitted; // Keep track of the # of mi's emitted.
}

unsigned
EBCMCCodeEmitter::getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                                      SmallVectorImpl<MCFixup> &Fixups,
                                      const MCSubtargetInfo &STI) const {

  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());

  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  assert(MO.isExpr() &&
         "getMachineOpValue expects only expressions or immediates");
  MCInstrDesc const &Desc = MCII.get(MI.getOpcode());
  unsigned TSFlags = Desc.TSFlags;
  const MCExpr *Expr = MO.getExpr();
  MCExpr::ExprKind Kind = Expr->getKind();
  EBC::Fixups FixupKind = EBC::fixup_ebc_invalid;
  unsigned Offset = 2;
  if (Kind == MCExpr::SymbolRef &&
      cast<MCSymbolRefExpr>(Expr)->getKind() == MCSymbolRefExpr::VK_None) {
    // Check if it has fixup and not native call
    if (TSFlags & 0x01 && !(TSFlags & 0x10)) {
      // Check if the fixup is pcrel
      if (TSFlags & 0x02) {
        switch ((TSFlags & 0x0c) >> 2) {
        case 0x00:
          FixupKind = EBC::fixup_ebc_pcrel_imm8;
          Offset = 1;
          break;
        case 0x01:
          FixupKind = EBC::fixup_ebc_pcrel_imm16;
          break;
        case 0x02:
          if (TSFlags & 0x100)
            FixupKind = EBC::fixup_ebc_pcrel_call32;
          else
            FixupKind = EBC::fixup_ebc_pcrel_imm32;
          break;
        case 0x03:
          FixupKind = EBC::fixup_ebc_pcrel_imm64;
          break;
        }
      } else {
        switch ((TSFlags & 0x0c) >> 2) {
        case 0x01:
          FixupKind = EBC::fixup_ebc_imm16;
          break;
        case 0x02:
          FixupKind = EBC::fixup_ebc_imm32;
          break;
        case 0x03:
          FixupKind = EBC::fixup_ebc_imm64;
          break;
        }
      }
    }
  }

  assert(FixupKind != EBC::fixup_ebc_invalid && "Unhandled expression!");

  Fixups.push_back(
      MCFixup::create(Offset, Expr, MCFixupKind(FixupKind), MI.getLoc()));
  ++MCNumFixups;

  return 0;
}

uint16_t
EBCMCCodeEmitter::getIdx16Value(const MCOperand &NMO, const MCOperand &CMO) const {
  int16_t Natural = NMO.getImm();
  int16_t Constant = CMO.getImm();

  assert(((Natural >= 0 && Constant >= 0)
        || (Natural <= 0 && Constant <= 0))
        && "Both natural and constant must have same signs");

  bool Sign = (Natural <= 0 && Constant <= 0);

  uint16_t AbsNatural = abs(Natural);
  uint16_t AbsConstant = abs(Constant);

  unsigned NaturalLen = 0;
  while (AbsNatural) {
    ++NaturalLen;
    AbsNatural >>= 1;
  }
  NaturalLen = alignTo(NaturalLen, 2);

  unsigned ConstantLen = 0;
  while (AbsConstant) {
    ++ConstantLen;
    AbsConstant >>= 1;
  }
  ConstantLen = alignTo(ConstantLen, 2);

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit

  assert((UsedBits + NaturalLen + ConstantLen <= 16)
        && "Unit length is too long");

  uint8_t Assigned = NaturalLen / 2;

  uint16_t Index = ((Sign ? 1 : 0) << 15) + (Assigned << 12)
                  + (abs(Constant) << NaturalLen) + abs(Natural);

  return Index;
}

uint32_t
EBCMCCodeEmitter::getIdx32Value(const MCOperand &NMO, const MCOperand &CMO) const {
  int32_t Natural = NMO.getImm();
  int32_t Constant = CMO.getImm();

  assert(((Natural >= 0 && Constant >= 0)
        || (Natural <= 0 && Constant <= 0))
        && "Both natural and constant must have same signs");

  bool Sign = (Natural <= 0 && Constant <= 0);

  uint32_t AbsNatural = abs(Natural);
  uint32_t AbsConstant = abs(Constant);

  unsigned NaturalLen = 0;
  while (AbsNatural) {
    ++NaturalLen;
    AbsNatural >>= 1;
  }
  NaturalLen = alignTo(NaturalLen, 4);

  unsigned ConstantLen = 0;
  while (AbsConstant) {
    ++ConstantLen;
    AbsConstant >>= 1;
  }
  ConstantLen = alignTo(ConstantLen, 4);

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit

  assert((UsedBits + NaturalLen + ConstantLen <= 32)
        && "Unit length is too long");

  uint8_t Assigned = NaturalLen / 4;

  uint32_t Index = ((Sign ? 1 : 0) << 31) + (Assigned << 28)
                  + (abs(Constant) << NaturalLen) + abs(Natural);

  return Index;
}

uint64_t
EBCMCCodeEmitter::getIdx64Value(const MCOperand &NMO, const MCOperand &CMO) const {
  int64_t Natural = NMO.getImm();
  int64_t Constant = CMO.getImm();

  assert(((Natural >= 0 && Constant >= 0)
        || (Natural <= 0 && Constant <= 0))
        && "Both natural and constant must have same signs");

  bool Sign = (Natural <= 0 && Constant <= 0);

  uint64_t AbsNatural = Natural < 0 ? -Natural : Natural;
  uint64_t AbsConstant = Constant < 0 ? -Constant : Constant;

  unsigned NaturalLen = 0;
  while (AbsNatural) {
    ++NaturalLen;
    AbsNatural >>= 1;
  }
  NaturalLen = alignTo(NaturalLen, 8);

  unsigned ConstantLen = 0;
  while (AbsConstant) {
    ++ConstantLen;
    AbsConstant >>= 1;
  }
  ConstantLen = alignTo(ConstantLen, 8);

  unsigned UsedBits = 4; // Sign bit + 3-bit assigned to natural unit

  assert((UsedBits + NaturalLen + ConstantLen <= 64)
        && "Unit length is too long");

  uint8_t Assigned = NaturalLen / 8;

  AbsNatural = Natural < 0 ? -Natural : Natural;
  AbsConstant = Constant < 0 ? -Constant : Constant;

  uint64_t Index = ((uint64_t)(Sign ? 1 : 0) << 63) + ((uint64_t)Assigned << 60)
                  + (AbsConstant << NaturalLen) + AbsNatural;

  return Index;
}

#include "EBCGenMCCodeEmitter.inc"
