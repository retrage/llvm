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

multiclass EBC1OpBase<bits<6> opcode, bit is64Bit,
                    dag outs, dag ins, string opcodestr, string argstr> {
  def Op1D : EBCInst1Op<opcode, is64Bit, 0, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"), argstr>;
  def Op1I : EBCInst1Op<opcode, is64Bit, 1, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"), "@" # argstr>;
  def Op1DImm : EBCInst1OpImm<opcode, is64Bit, 0,
                outs, !con(ins, !dag(ins, [imm16], ["imm"])),
                opcodestr # !if(is64Bit, "64", "32"), argstr # " $imm">;
}

multiclass EBCPOPBase<bits<6> opcode, bit is64Bit, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, is64Bit, 0, (outs GPR:$op1), (ins),
                opcodestr # !if(is64Bit, "64", "32"), "$op1">;
  def Op1I : EBCInst1Op<opcode, is64Bit, 1, (outs GPR:$op1), (ins),
                opcodestr # !if(is64Bit, "64", "32"), "@$op1">;
  def Op1DImm : EBCInst1OpImm<opcode, is64Bit, 0,
                (outs GPR:$op1), (ins imm16:$imm),
                opcodestr # !if(is64Bit, "64", "32"), "$op1 $imm">;
}

multiclass EBCPUSHBase<bits<6> opcode, bit is64Bit, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, is64Bit, 0, (outs), (ins GPR:$op1),
                opcodestr # !if(is64Bit, "64", "32"), "$op1">;
  def Op1I : EBCInst1Op<opcode, is64Bit, 1, (outs), (ins GPR:$op1),
                opcodestr # !if(is64Bit, "64", "32"), "@$op1">;
  def Op1DImm : EBCInst1OpImm<opcode, is64Bit, 0,
                (outs), (ins GPR:$op1, imm16:$imm),
                opcodestr # !if(is64Bit, "64", "32"), "$op1 $imm">;
}

multiclass EBCPOP<bits<6> opcode, string opcodestr> {
  defm _32 : EBCPOPBase<opcode, 0, opcodestr>;
  defm _64 : EBCPOPBase<opcode, 1, opcodestr>;
}

multiclass EBCPUSH<bits<6> opcode, string opcodestr> {
  defm _32 : EBCPUSHBase<opcode, 0, opcodestr>;
  defm _64 : EBCPUSHBase<opcode, 1, opcodestr>;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCall = 1 in
def ret : EBCInst16<0b000100, (outs), (ins), "ret", "", []>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def loadsp : EBCInst2Op<0b101001, 0, 0, 0,
                (outs FR:$op1), (ins GPR:$op2), "loadsp", "$op1, $op2">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def storesp : EBCInst2Op<0b101010, 0, 0, 0,
                (outs GPR:$op1), (ins DR:$op2), "storesp", "$op1, $op2">;

defm pop  : EBCPOP<0b101100, "pop">;
defm push : EBCPUSH<0b101011, "push">;
