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

class BreakCodeAsmOperand<int width> : AsmOperandClass {
  let Name = "BreakCode" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

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

let OperandType = "OPERAND_BREAKCODE" in
def breakcode : Operand<i8> {
  let ParserMatchClass = BreakCodeAsmOperand<8>;
}

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

multiclass EBC1OpBaseCommon<bits<6> opcode, bit is64Bit,
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

multiclass EBC2OpBaseCommon<bits<6> opcode, bit is64Bit,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str, string op2str,
                string immstr, string idxstr> {
  def Op1DOp2D : EBCInst2Op<opcode, 0, is64Bit, 0, 0, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"),
                op1str # ", " # op2str>;
  def Op1IOp2D : EBCInst2Op<opcode, 0, is64Bit, 1, 0, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"),
                "@" # op1str # ", " # op2str>;
  def Op1DOp2I : EBCInst2Op<opcode, 0, is64Bit, 0, 1, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"),
                op1str # ", " # "@" # op2str>;
  def Op1IOp2I : EBCInst2Op<opcode, 0, is64Bit, 1, 1, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"),
                "@" # op1str # ", " # "@" # op2str>;
  def Op1DOp2DImm : EBCInst2Op<opcode, 0, is64Bit, 0, 0,
                outs, !con(ins, immins),
                opcodestr # !if(is64Bit, "64", "32"),
                op1str # ", " # op2str # " " # immstr>;
  def Op1IOp2DImm : EBCInst2Op<opcode, 0, is64Bit, 1, 0,
                outs, !con(ins, immins),
                opcodestr # !if(is64Bit, "64", "32"),
                "@" # op1str # ", " # op2str # " " # immstr>;
  def Op1DOp2IIdx : EBCInst2Op<opcode, 0, is64Bit, 0, 1,
                outs, !con(ins, idxins),
                opcodestr # !if(is64Bit, "64", "32"),
                op1str # ", " # "@" # op2str # " " # idxstr>;
  def Op1IOp2IIdx : EBCInst2Op<opcode, 0, is64Bit, 1, 1,
                outs, !con(ins, idxins),
                opcodestr # !if(is64Bit, "64", "32"),
                "@" # op1str # ", " # "@" # op2str # " " # idxstr>;
}

multiclass EBCCMPBaseCommon<bits<6> opcode, bit is64Bit,
                dag outs, dag ins, dag immins, dag idxins,
                string opsuffix, string op1str, string op2str,
                string immstr, string idxstr> {
  def Op1DOp2D : EBCInst2Op<opcode, 0, is64Bit, 0, 0, outs, ins,
                "cmp" # !if(is64Bit, "64", "32") # opsuffix,
                op1str # ", " # op2str>;
  def Op1DOp2I : EBCInst2Op<opcode, 0, is64Bit, 0, 1, outs, ins,
                "cmp" # !if(is64Bit, "64", "32") # opsuffix,
                op1str # ", " # "@" # op2str>;
  def Op1DOp2DImm : EBCInst2Op<opcode, 0, is64Bit, 0, 0,
                outs, !con(ins, immins),
                "cmp" # !if(is64Bit, "64", "32") # opsuffix,
                op1str # ", " # op2str # " " # immstr>;
  def Op1DOp2IIdx : EBCInst2Op<opcode, 0, is64Bit, 0, 1,
                outs, !con(ins, idxins),
                "cmp" # !if(is64Bit, "64", "32") # opsuffix,
                op1str # ", " # "@" # op2str # " " # idxstr>;
}

multiclass EBC2OpBase<bits<6> opcode, string opcodestr> {
  defm _32 : EBC2OpBaseCommon<opcode, 0,
                (outs GPR:$dst), (ins GPR:$op1, GPR:$op2),
                (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
                opcodestr, "$op1", "$op2", "$imm", "(${idxn},${idxc})">;
  defm _64 : EBC2OpBaseCommon<opcode, 1,
                (outs GPR:$dst), (ins GPR:$op1, GPR:$op2),
                (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
                opcodestr, "$op1", "$op2", "$imm", "(${idxn},${idxc})">;
}

multiclass EBCCMPBase<bits<6> opcode, string opsuffix> {
  defm _32 : EBCCMPBaseCommon<opcode, 0,
                (outs), (ins GPR:$op1, GPR:$op2),
                (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
                opsuffix, "$op1", "$op2", "$imm", "(${idxn},${idxc})">;
  defm _64 : EBCCMPBaseCommon<opcode, 1,
                (outs), (ins GPR:$op1, GPR:$op2),
                (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
                opsuffix, "$op1", "$op2", "$imm", "(${idxn},${idxc})">;
}

multiclass EBC1OpBase<bits<6> opcode,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  defm _32 : EBC1OpBaseCommon<opcode, 0, outs, ins, immins, idxins,
                opcodestr, op1str, immstr, idxstr>;
  defm _64 : EBC1OpBaseCommon<opcode, 1, outs, ins, immins, idxins,
                opcodestr, op1str, immstr, idxstr>;
}

multiclass EBC1OpnBase<bits<6> opcode,
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

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
def ebcbreak : EBCInst<0b000000,
                (outs), (ins breakcode:$code), "break", "$code", []> {
  field bits<8> Inst;
  field bits<8> SoftFail = 0;
  let Size = 1;

  let Inst{5-0} = Opcode;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCall = 1 in
def ret : EBCInst16<0b000100, (outs), (ins), "ret", "", []>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def loadsp : EBCInst2Op<0b101001, 0, 0, 0, 0,
                (outs FR:$op1), (ins GPR:$op2), "loadsp", "$op1, $op2">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def storesp : EBCInst2Op<0b101010, 0, 0, 0, 0,
                (outs GPR:$op1), (ins DR:$op2), "storesp", "$op1, $op2">;

defm pop    : EBC1OpBase<0b101100,
            (outs GPR:$op1), (ins),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "pop", "$op1", "$imm", "(${idxn},${idxc})">;
defm push   : EBC1OpBase<0b101011,
            (outs), (ins GPR:$op1),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "push", "$op1", "$imm", "(${idxn},${idxc})">;

defm popn   : EBC1OpnBase<0b110110,
            (outs GPR:$op1), (ins),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "popn", "$op1", "$imm", "(${idxn},${idxc})">;
defm pushn  : EBC1OpnBase<0b110101,
            (outs), (ins GPR:$op1),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            "pushn", "$op1", "$imm", "(${idxn},${idxc})">;

let Constraints = "$dst = $op1" in {
defm not    : EBC2OpBase<0b001010, "not">;
defm neg    : EBC2OpBase<0b001011, "neg">;
defm add    : EBC2OpBase<0b001100, "add">;
defm sub    : EBC2OpBase<0b001101, "sub">;
defm mul    : EBC2OpBase<0b001110, "mul">;
defm mulu   : EBC2OpBase<0b001111, "mulu">;
defm div    : EBC2OpBase<0b010000, "div">;
defm divu   : EBC2OpBase<0b010001, "divu">;
defm mod    : EBC2OpBase<0b010010, "mod">;
defm modu   : EBC2OpBase<0b010011, "modu">;
defm and    : EBC2OpBase<0b010100, "and">;
defm or     : EBC2OpBase<0b010101, "or">;
defm xor    : EBC2OpBase<0b010110, "xor">;
defm shl    : EBC2OpBase<0b010111, "shl">;
defm shr    : EBC2OpBase<0b011000, "shr">;
defm ashr   : EBC2OpBase<0b011001, "ashr">;

defm extndb : EBC2OpBase<0b011010, "extndb">;
defm extndw : EBC2OpBase<0b011011, "extndw">;
defm extndd : EBC2OpBase<0b011100, "extndd">;
}

defm cmpeq  : EBCCMPBase<0b000101, "eq">;
defm cmplte : EBCCMPBase<0b000110, "lte">;
defm cmpgte : EBCCMPBase<0b000111, "gte">;
defm cmpulte: EBCCMPBase<0b001000, "ulte">;
defm cmpugte: EBCCMPBase<0b001001, "ugte">;
