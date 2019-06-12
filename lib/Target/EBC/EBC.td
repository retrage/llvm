//===-- EBC.td - Describe the EBC Target Machine -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register file, calling conventions, instruction descriptions.
//===----------------------------------------------------------------------===//

include "EBCRegisterInfo.td"
include "EBCCallingConv.td"
include "EBCInstrInfo.td"

//===----------------------------------------------------------------------===//
// EBC processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic-ebc", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Define the EBC target.
//===----------------------------------------------------------------------===//

def EBCInstrInfo : InstrInfo;

def EBCAsmParser : AsmParser;

def EBCAsmWriter : AsmWriter;

def EBC : Target {
  let InstructionSet = EBCInstrInfo;
  let AssemblyParsers = [EBCAsmParser];
  let AssemblyWriters = [EBCAsmWriter];
}
