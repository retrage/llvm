//===-- EBCCOFFStreamer.cpp - EBC Target COFF Streamer ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "EBCCOFFStreamer.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCWin64EH.h"
#include "llvm/MC/MCWinCOFFStreamer.h"

using namespace llvm;

namespace {

class EBCCOFFStreamer : public MCWinCOFFStreamer {

public:
  EBCCOFFStreamer(MCContext &C, std::unique_ptr<MCAsmBackend> AB,
                  std::unique_ptr<MCCodeEmitter> CE,
                  std::unique_ptr<MCObjectWriter> OW)
    : MCWinCOFFStreamer(C, std::move(AB), std::move(CE), std::move(OW)) {}
};

} // end anonymous namespace

namespace llvm {

MCWinCOFFStreamer *createEBCCOFFStreamer(
    MCContext &Context, std::unique_ptr<MCAsmBackend> MAB,
    std::unique_ptr<MCObjectWriter> OW,
    std::unique_ptr<MCCodeEmitter> Emitter,
    bool RelaxAll, bool IncrementalLinkerCompatible) {
  auto *S = new EBCCOFFStreamer(Context, std::move(MAB),
                                std::move(Emitter), std::move(OW));
  S->getAssembler().setIncrementalLinkerCompatible(IncrementalLinkerCompatible);
  return S;
}
} // end llvm namespace
