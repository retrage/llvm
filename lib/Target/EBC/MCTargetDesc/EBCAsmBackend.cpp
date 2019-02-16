//===-- EBCAsmBackend.cpp - EBC Assembler Backend ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
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

  unsigned getNumFixupKinds() const override { return 1; }

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

void EBCAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                              const MCValue &Target,
                              MutableArrayRef<char> Data,
                              uint64_t Value, bool IsResolved,
                              const MCSubtargetInfo *STI) const {
  return;
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

} // end anonymous namespace

MCAsmBackend *llvm::createEBCAsmBackend(const Target &T,
                                          const MCSubtargetInfo &STI,
                                          const MCRegisterInfo &MRI,
                                          const MCTargetOptions &Options) {
  return new EBCAsmBackend();
}
