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

class IdxNAsmOperand<int width> : AsmOperandClass {
  let Name = "IdxN" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

class IdxCAsmOperand<int width> : AsmOperandClass {
  let Name = "IdxC" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

let OperandNamespace = "EBC" in {

let OperandType = "OPERAND_IMM16" in
def imm16 : Operand<i16> {
  let ParserMatchClass = ImmAsmOperand<16>;
}

let OperandType = "OPERAND_IDXN16" in
def idxn16 : Operand<i16> {
  let ParserMatchClass = IdxNAsmOperand<16>;
}

let OperandType = "OPERAND_IDXC16" in
def idxc16 : Operand<i16> {
  let ParserMatchClass = IdxCAsmOperand<16>;
}

} // OperandNamespace = "EBC"

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

multiclass EBCOp1BaseCommon<bits<6> opcode, bit is64Bit,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  def Op1D : EBCInst1Op<opcode, 0, is64Bit, 0, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"), op1str>;
  def Op1I : EBCInst1Op<opcode, 0, is64Bit, 1, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"), "@" # op1str>;
  def Op1DImm : EBCInst1Op<opcode, 1, is64Bit, 0, outs, !con(ins, immins),
                opcodestr # !if(is64Bit, "64", "32"),
                op1str # " " # immstr>;
  def Op1IIdx : EBCInst1Op<opcode, 1, is64Bit, 1, outs, !con(ins, idxins),
                opcodestr # !if(is64Bit, "64", "32"),
                "@" # op1str # " " # idxstr>;
}

multiclass EBCOp1Base<bits<6> opcode,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  defm _32 : EBCOp1BaseCommon<opcode, 0, outs, ins, immins, idxins,
                opcodestr, op1str, immstr, idxstr>;
  defm _64 : EBCOp1BaseCommon<opcode, 1, outs, ins, immins, idxins,
                opcodestr, op1str, immstr, idxstr>;
}

multiclass EBCOp1nBase<bits<6> opcode,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  def Op1D : EBCInst1Op<opcode, 0, 0, 0,
                outs, ins, opcodestr, op1str>;
  def Op1I : EBCInst1Op<opcode, 0, 0, 1,
                outs, ins, opcodestr, "@" # op1str>;
  def Op1DImm : EBCInst1Op<opcode, 1, 0, 0,
                outs, !con(ins, immins), opcodestr, op1str # " " # immstr>;
  def Op1IIdx : EBCInst1Op<opcode, 1, 0, 1, outs, !con(ins, idxins),
                opcodestr, "@" # op1str # " " # idxstr>;
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

defm pop    : EBCOp1Base<0b101100,
            (outs GPR:$op1), (ins),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "pop", "$op1", "$imm", "(${idxn},${idxc})">;
defm push   : EBCOp1Base<0b101011,
            (outs), (ins GPR:$op1),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "push", "$op1", "$imm", "(${idxn},${idxc})">;

defm popn   : EBCOp1nBase<0b110110,
            (outs GPR:$op1), (ins),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "popn", "$op1", "$imm", "(${idxn},${idxc})">;
defm pushn  : EBCOp1nBase<0b110101,
            (outs), (ins GPR:$op1),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "pushn", "$op1", "$imm", "(${idxn},${idxc})">;
