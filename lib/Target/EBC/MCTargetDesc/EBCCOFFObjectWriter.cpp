//===-- EBCCOFFObjectWriter.cpp - EBC COFF Writer -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/BinaryFormat/COFF.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCWinCOFFObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {

class EBCCOFFObjectWriter : public MCWinCOFFObjectTargetWriter {
public:
  EBCCOFFObjectWriter()
    : MCWinCOFFObjectTargetWriter(COFF::IMAGE_FILE_MACHINE_EBC) {}

  ~EBCCOFFObjectWriter() override = default;

  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsCrossSection,
                        const MCAsmBackend &MAB) const override;

  bool recordRelocation(const MCFixup &) const override;
};

} // end anonymous namespace

unsigned EBCCOFFObjectWriter::getRelocType(
    MCContext &Ctx, const MCValue &Target, const MCFixup &Fixup,
    bool IsCrossSection, const MCAsmBackend &MAB) const {
  report_fatal_error("invalid fixup kind!");
}

bool EBCCOFFObjectWriter::recordRelocation(const MCFixup &Fixup) const {
  return true;
}

namespace llvm {

std::unique_ptr<MCObjectTargetWriter> createEBCCOFFObjectWriter() {
  return llvm::make_unique<EBCCOFFObjectWriter>();
}

} // end namespace llvm
