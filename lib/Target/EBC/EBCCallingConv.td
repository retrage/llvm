//===-- EBCCallingConv.td - Calling Conventions EBC ----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the EBC architecture.
//
//===----------------------------------------------------------------------===//

// EBC C return-value convention.
def RetCC_EBC : CallingConv<[CCIfType<[i64], CCAssignToReg<[r7]>>]>;

// EBC C Calling convention.
def CC_EBC : CallingConv<[
  // Promote i8/i16/i32 args to i64
  CCIfType<[i8, i16, i32], CCPromoteToType<i64>>,

// All arguments get passed to the stack in 8-byte aligned units
  CCAssignToStack<8, 8>
]>;

def CSR : CalleeSavedRegs<(add (sequence "r%u", 1, 5))>;
