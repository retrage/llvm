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

def imm16 : Operand<i16>;

def nat16 : Operand<i16>;

def con16 : Operand<i16>;

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

multiclass ALUXX<bits<6> opcode, string opcodestr, bit is64> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def Op1DOp2D : EBCInst16Op1Op2<opcode, is64, 0, 0,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2),
            opcodestr # !if(is64, "64", "32"), "$src1, $src2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def Op1IOp2D : EBCInst16Op1Op2<opcode, is64, 1, 0,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2),
            opcodestr # !if(is64, "64", "32"), "@$src1, $src2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def Op1DOp2I : EBCInst16Op1Op2<opcode, is64, 0, 1,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2),
            opcodestr # !if(is64, "64", "32"), "$src1, @$src2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def Op1IOp2I : EBCInst16Op1Op2<opcode, is64, 1, 1,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2),
            opcodestr # !if(is64, "64", "32"), "@$src1, @$src2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def Op1DOp2DImm : EBCInst16Op1Op2<opcode, is64, 0, 0,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2, imm16:$imm),
            opcodestr # !if(is64, "64", "32"), "$src1, $src2 $imm">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def Op1IOp2DImm : EBCInst16Op1Op2<opcode, is64, 1, 0,
            (outs GPR:$dst), (ins GPR:$src1, GPR:$src2, imm16:$imm),
            opcodestr # !if(is64, "64", "32"), "@$src1, $src2 $imm">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def Op1DOp2IIdx : EBCInst16Op1Op2<opcode, is64, 0, 1,
      (outs GPR:$dst), (ins GPR:$src1, GPR:$src2, nat16:$nat, con16:$con),
      opcodestr # !if(is64, "64", "32"), "$src1, @$src2 ($nat, $con)">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def Op1IOp2IIdx : EBCInst16Op1Op2<opcode, is64, 1, 1,
      (outs GPR:$dst), (ins GPR:$src1, GPR:$src2, nat16:$nat, con16:$con),
      opcodestr # !if(is64, "64", "32"), "@$src1, @$src2 ($nat, $con)">;
}

multiclass ALU<bits<6> opcode, string opcodestr> {
  defm ALU32 : ALUXX<opcode, opcodestr, 0>;
  defm ALU64 : ALUXX<opcode, opcodestr, 1>;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let Constraints = "$src1 = $dst" in {
  defm NOT  : ALU<0b001010, "NOT">;
  defm NEG  : ALU<0b001011, "NEG">;
  defm ADD  : ALU<0b001100, "ADD">;
  defm SUB  : ALU<0b001101, "SUB">;
  defm MUL  : ALU<0b001110, "MUL">;
  defm MULU : ALU<0b001111, "MULU">;
  defm DIV  : ALU<0b010000, "DIV">;
  defm DIVU : ALU<0b010001, "DIVU">;
  defm MOD  : ALU<0b010010, "MOD">;
  defm MODU : ALU<0b010011, "MODU">;
  defm AND  : ALU<0b010100, "AND">;
  defm OR   : ALU<0b010101, "OR">;
  defm XOR  : ALU<0b010110, "XOR">;
  defm SHL  : ALU<0b010111, "SHL">;
  defm SHR  : ALU<0b011000, "SHR">;
  defm ASHR : ALU<0b011001, "ASHR">;
}
