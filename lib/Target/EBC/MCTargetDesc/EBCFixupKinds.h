//===-- EBCFixupKinds.h - EBC Specific Fixup Entries --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCFIXUPKINDS_H
#define LLVM_LIB_TARGET_EBC_MCTARGETDESC_EBCFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

#undef EBC

namespace llvm {
namespace EBC {
enum Fixups {
  fixup_ebc_jmp8 = FirstTargetFixupKind,
  fixup_ebc_jmp64rel,
  fixup_ebc_call64rel,

  // fixup_ebc_invalid - used as a sentinel and a marker, must be last fixup
  fixup_ebc_invalid,
  NumTargetFixupKinds = fixup_ebc_invalid - FirstTargetFixupKind
};
} // end namespace EBC
} // end namespace llvm

#endif
