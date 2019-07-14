//===-- EBCCOFFObjectWriter.cpp - EBC COFF Writer -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCFixupKinds.h"
#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/ADT/Twine.h"
#include "llvm/BinaryFormat/COFF.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
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
  auto Modifier = Target.isAbsolute() ? MCSymbolRefExpr::VK_None
                                      : Target.getSymA()->getKind();

  switch (static_cast<unsigned>(Fixup.getKind())) {
  default: {
    const MCFixupKindInfo &Info = MAB.getFixupKindInfo(Fixup.getKind());
    report_fatal_error(Twine("unsupported relocation type: ") + Info.Name);
  }
  case FK_Data_4:
    switch (Modifier) {
    default:
      return COFF::IMAGE_REL_EBC_ADDR32;
    case MCSymbolRefExpr::VK_COFF_IMGREL32:
      return COFF::IMAGE_REL_EBC_ADDR32NB;
    case MCSymbolRefExpr::VK_SECREL:
      return COFF::IMAGE_REL_EBC_SECREL;
    }
  case FK_Data_8:
    return COFF::IMAGE_REL_EBC_ADDR64;
  case EBC::fixup_ebc_pcrel_imm8:
    return COFF::IMAGE_REL_EBC_REL8;
  case EBC::fixup_ebc_pcrel_imm16:
    return COFF::IMAGE_REL_EBC_REL16;
  case EBC::fixup_ebc_pcrel_imm32:
    return COFF::IMAGE_REL_EBC_REL32;
  case EBC::fixup_ebc_pcrel_imm64:
    return COFF::IMAGE_REL_EBC_REL64;
  case FK_SecRel_2:
    return COFF::IMAGE_REL_EBC_SECTION;
  case FK_SecRel_4:
    return COFF::IMAGE_REL_EBC_SECREL;
  case EBC::fixup_ebc_pcrel_call32:
    return COFF::IMAGE_REL_EBC_CALL32;
  case EBC::fixup_ebc_pcrel_jmp64:
    return COFF::IMAGE_REL_EBC_JMP64;
  }
}

bool EBCCOFFObjectWriter::recordRelocation(const MCFixup &Fixup) const {
  return true;
}

namespace llvm {

std::unique_ptr<MCObjectTargetWriter> createEBCCOFFObjectWriter() {
  return llvm::make_unique<EBCCOFFObjectWriter>();
}

} // end namespace llvm
