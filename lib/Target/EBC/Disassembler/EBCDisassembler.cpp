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

#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/TargetRegistry.h"

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

#include "EBCGenDisassemblerTables.inc"

DecodeStatus EBCDisassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                               ArrayRef<uint8_t> Bytes,
                                               uint64_t Address,
                                               raw_ostream &OS,
                                               raw_ostream &CS) const {
  uint16_t Inst = support::endian::read16le(Bytes.data());

  return decodeInstruction(DecoderTable16, MI, Inst, Address, this, STI);
}
