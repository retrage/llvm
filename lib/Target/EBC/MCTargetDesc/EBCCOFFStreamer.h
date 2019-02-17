//===-- EBCWinCOFFStreamer.h - WinCOFF Streamer for EBC -*- C++ -*-===////
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements WinCOFF streamer information for the EBC backend.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCWINCOFFSTREAMER_H
#define LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCWINCOFFSTREAMER_H

#include "llvm/MC/MCWinCOFFStreamer.h"

namespace llvm {

MCWinCOFFStreamer *createEBCCOFFStreamer(
    MCContext &Context, std::unique_ptr<MCAsmBackend> TAB,
    std::unique_ptr<MCObjectWriter> OW,
    std::unique_ptr<MCCodeEmitter> Emitter,
    bool RelaxAll, bool IncrementalLinkerCompatible);
} // end llvm namespace

#endif  
