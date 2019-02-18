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

multiclass EBCInst1OpDQ<bits<6> opcode, bit Op1Indirect,
                    dag outs, dag ins, string opcodestr, string argstr> {
  def _32 : EBCInst1Op<opcode, 0, Op1Indirect,
                    outs, ins, opcodestr # "32", argstr>;
  def _64 : EBCInst1Op<opcode, 1, Op1Indirect,
                    outs, ins, opcodestr # "64", argstr>;
}

multiclass EBCInst1OpDI<bits<6> opcode,
                    dag outs, dag ins, string opcodestr, string argstr> {
  defm Op1D : EBCInst1OpDQ<opcode, 0,
                    outs, ins, opcodestr, argstr>;
  defm Op1I : EBCInst1OpDQ<opcode, 1,
                    outs, ins, opcodestr, "@" # argstr>;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCall = 1 in
def ret : EBCInst16<0b000100, (outs), (ins), "ret", "">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def loadsp : EBCInst2Op<0b101001, 0, 0, 0,
                (outs FR:$op1), (ins GPR:$op2), "loadsp", "$op1, $op2">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def storesp : EBCInst2Op<0b101010, 0, 0, 0,
                (outs GPR:$op1), (ins DR:$op2), "storesp", "$op1, $op2">;

defm pop : EBCInst1OpDI<0b101100,
                (outs GPR:$op1), (ins), "pop", "$op1">;
defm push : EBCInst1OpDI<0b101011,
                (outs), (ins GPR:$op1), "push", "$op1">;
