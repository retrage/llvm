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

let OperandNamespace = "EBC" in {

let OperandType = "OPERAND_IMM16" in
def imm16 : Operand<i16> {
  let ParserMatchClass = ImmAsmOperand<16>;
}

} // OperandNamespace = "EBC"

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

multiclass EBCPOPBase<bits<6> opcode, bit is64Bit, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, 0, is64Bit, 0, (outs GPR:$op1), (ins),
                opcodestr # !if(is64Bit, "64", "32"), "$op1">;
  def Op1I : EBCInst1Op<opcode, 0, is64Bit, 1, (outs GPR:$op1), (ins),
                opcodestr # !if(is64Bit, "64", "32"), "@$op1">;
  def Op1DImm : EBCInst1Op<opcode, 1, is64Bit, 0,
                (outs GPR:$op1), (ins imm16:$imm),
                opcodestr # !if(is64Bit, "64", "32"), "$op1 $imm">;
}

multiclass EBCPUSHBase<bits<6> opcode, bit is64Bit, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, 0, is64Bit, 0, (outs), (ins GPR:$op1),
                opcodestr # !if(is64Bit, "64", "32"), "$op1">;
  def Op1I : EBCInst1Op<opcode, 0, is64Bit, 1, (outs), (ins GPR:$op1),
                opcodestr # !if(is64Bit, "64", "32"), "@$op1">;
  def Op1DImm : EBCInst1Op<opcode, 1, is64Bit, 0,
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

multiclass EBCPOPn<bits<6> opcode, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, 0, 0, 0,
                (outs GPR:$op1), (ins), opcodestr, "$op1">;
  def Op1I : EBCInst1Op<opcode, 0, 0, 1,
                (outs GPR:$op1), (ins), opcodestr, "@$op1">;
  def Op1DImm : EBCInst1Op<opcode, 1, 0, 0,
                (outs GPR:$op1), (ins imm16:$imm), opcodestr, "$op1 $imm">;
}

multiclass EBCPUSHn<bits<6> opcode, string opcodestr> {
  def Op1D : EBCInst1Op<opcode, 0, 0, 0,
                (outs), (ins GPR:$op1), opcodestr, "$op1">;
  def Op1I : EBCInst1Op<opcode, 0, 0, 1,
                (outs), (ins GPR:$op1), opcodestr, "@$op1">;
  def Op1DImm : EBCInst1Op<opcode, 1, 0, 0,
                (outs), (ins GPR:$op1, imm16:$imm), opcodestr, "$op1 $imm">;
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

defm pop    : EBCPOP<0b101100, "pop">;
defm push   : EBCPUSH<0b101011, "push">;

defm popn   : EBCPOPn<0b110110, "popn">;
defm pushn  : EBCPUSHn<0b110101, "pushn">;
