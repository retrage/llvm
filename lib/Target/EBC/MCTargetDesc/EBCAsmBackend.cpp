//===-- EBCAsmBackend.cpp - EBC Assembler Backend ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCFixupKinds.h"
#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCWinCOFFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class EBCAsmBackend : public MCAsmBackend {
public:
  EBCAsmBackend() : MCAsmBackend(support::little) {}
  ~EBCAsmBackend() override {}

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target,
                  MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    return false;
  }

  unsigned getNumFixupKinds() const override {
    return EBC::NumTargetFixupKinds;
  }

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override {
    const static MCFixupKindInfo Infos[EBC::NumTargetFixupKinds] = {
      // This table *must* be in the order that the fixup_* kinds are defined in
      // EBCFixupKinds.h
      //
      // name                offset bits   flags
      { "fixup_ebc_pcrel_imm8",   0,   8,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_ebc_pcrel_imm16",  0,  16,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_ebc_pcrel_imm32",  0,  32,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_ebc_pcrel_imm64",  0,  64,  MCFixupKindInfo::FKF_IsPCRel },
      { "fixup_ebc_pcrel_call32", 0,  32,  MCFixupKindInfo::FKF_IsPCRel },
    };

      if (Kind < FirstTargetFixupKind)
        return MCAsmBackend::getFixupKindInfo(Kind);

      assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
             "Invalid kind!");
      return Infos[Kind - FirstTargetFixupKind];
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {
    report_fatal_error("EBCAsmBackend::relaxInstruction() unimplemented");
  }

  bool mayNeedRelaxation(const MCInst &Inst,
                        const MCSubtargetInfo &STI) const override {
    return false;
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

} // end anonymous namespace

static unsigned getFixupKindNumBytes(unsigned Kind) {
  switch (Kind) {
  default:
    llvm_unreachable("Unknown fixup kind!");
  case EBC::fixup_ebc_pcrel_imm8:
  case FK_Data_1:
    return 1;
  case EBC::fixup_ebc_pcrel_imm16:
  case FK_Data_2:
    return 2;
  case EBC::fixup_ebc_pcrel_imm32:
  case EBC::fixup_ebc_pcrel_call32:
  case FK_Data_4:
    return 4;
  case EBC::fixup_ebc_pcrel_imm64:
  case FK_Data_8:
    return 8;
  }
}

static uint64_t adjustFixupValue(const MCFixup &Fixup, uint64_t Value,
                                 MCContext &Ctx) {
  unsigned Kind = Fixup.getKind();
  int64_t SignedValue = static_cast<int64_t>(Value);
  switch (Kind) {
    default:
      llvm_unreachable("Unknown fixup kind!");
    case FK_Data_1:
    case FK_Data_2:
    case FK_Data_4:
    case FK_Data_8:
      return Value;
    case EBC::fixup_ebc_pcrel_imm8:
      if (SignedValue % 2)
        Ctx.reportError(Fixup.getLoc(), "fixup must be 2-byte aligned");
      if ((SignedValue > INT8_MAX * 2) || (SignedValue < INT8_MIN * 2))
        Ctx.reportError(Fixup.getLoc(), "fixup must be in range [-256, 254]");
      return SignedValue / 2;
    case EBC::fixup_ebc_pcrel_imm16:
    case EBC::fixup_ebc_pcrel_imm32:
    case EBC::fixup_ebc_pcrel_imm64:
      SignedValue += 2;
      if (SignedValue % 2)
        Ctx.reportError(Fixup.getLoc(), "fixup must be 2-byte aligned");
      return SignedValue;
    case EBC::fixup_ebc_pcrel_call32:
      SignedValue -= 4;
      if (SignedValue % 2)
        Ctx.reportError(Fixup.getLoc(), "fixup must be 2-byte aligned");
      return SignedValue;
  }
}

void EBCAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                              const MCValue &Target,
                              MutableArrayRef<char> Data,
                              uint64_t Value, bool IsResolved,
                              const MCSubtargetInfo *STI) const {
  unsigned NumBytes = getFixupKindNumBytes(Fixup.getKind());
  if (!Value)
    return; // Doesn't change encoding.
  MCContext &Ctx = Asm.getContext();
  // Apply any target-specific value adjustments.
  Value = adjustFixupValue(Fixup, Value, Ctx);

  unsigned Offset = Fixup.getOffset();
  assert(Offset + NumBytes <= Data.size() && "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value.
  for (unsigned i = 0; i != NumBytes; ++i) {
    Data[Offset + i] |= uint8_t((Value >> (i * 8)) & 0xff);
  }
}

std::unique_ptr<MCObjectTargetWriter>
EBCAsmBackend::createObjectTargetWriter() const {
  return createEBCCOFFObjectWriter();
}

bool EBCAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  // nop on EBC is MOVqq R0, R0
  Count /= 2;
  for (uint64_t i = 0; i != Count; ++i)
    OS.write("\x28\0", 2);

  return true;
}

MCAsmBackend *llvm::createEBCAsmBackend(const Target &T,
                                          const MCSubtargetInfo &STI,
                                          const MCRegisterInfo &MRI,
                                          const MCTargetOptions &Options) {
  return new EBCAsmBackend();
}
