//===-- EBCInstrInfo.td - Target Description for EBC ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the EBC instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

include "EBCInstrFormats.td"

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

class ImmAsmOperand<int width> : AsmOperandClass {
  let Name = "Imm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def imm16 : Operand<i16> {
  let ParserMatchClass = ImmAsmOperand<16>;
}

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCall = 1 in
def ret : EBCInst16<OPC_RET, (outs), (ins), "ret", "">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def loadsp : EBCInst2Op<OPC_LOADSP, (outs FR:$op1), (ins GPR:$op2),
                      "loadsp", "$op1, $op2">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def storesp : EBCInst2Op<OPC_STORESP, (outs GPR:$op1), (ins DR:$op2),
                      "storesp", "$op1, $op2">;
