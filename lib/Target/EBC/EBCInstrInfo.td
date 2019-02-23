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

let OperandType = "OPERAND_IMM8" in
def imm8 : Operand<i8> {
  let ParserMatchClass = ImmAsmOperand<8>;
}

let OperandType = "OPERAND_IMM16" in
def imm16 : Operand<i16> {
  let ParserMatchClass = ImmAsmOperand<16>;
}

let OperandType = "OPERAND_IMM32" in
def imm32 : Operand<i32> {
  let ParserMatchClass = ImmAsmOperand<32>;
}

let OperandType = "OPERAND_IMM64" in
def imm64 : Operand<i64> {
  let ParserMatchClass = ImmAsmOperand<64>;
}

let OperandType = "OPERAND_IDXN16" in
def idxn16 : Operand<i16> {
  let ParserMatchClass = IdxNAsmOperand<16>;
}

let OperandType = "OPERAND_IDXC16" in
def idxc16 : Operand<i16> {
  let ParserMatchClass = IdxCAsmOperand<16>;
}

let OperandType = "OPERAND_IDXN32" in
def idxn32 : Operand<i32> {
  let ParserMatchClass = IdxNAsmOperand<32>;
}

let OperandType = "OPERAND_IDXC32" in
def idxc32 : Operand<i32> {
  let ParserMatchClass = IdxCAsmOperand<32>;
}

let OperandType = "OPERAND_IDXN64" in
def idxn64 : Operand<i64> {
  let ParserMatchClass = IdxNAsmOperand<64>;
}

let OperandType = "OPERAND_IDXC64" in
def idxc64 : Operand<i64> {
  let ParserMatchClass = IdxCAsmOperand<64>;
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

multiclass EBCCMPIBaseCommon<bits<6> opcode, bit is64Bit,
                dag outs, dag ins, dag imm16ins, dag imm32ins, dag idxins,
                string opsuffix, string op1str,
                string imm16str, string imm32str, string idxstr> {
  def wOp1D : EBCInst1Op<opcode, 0, is64Bit, 0,
                outs, !con(ins, imm16ins),
                "cmpi" # !if(is64Bit, "64", "32") # "w" # opsuffix,
                op1str # ", " # imm16str> {
    let Inst{7} = 0;
    let Inst{12} = 0;
  }
  def wOp1I : EBCInst1Op<opcode, 0, is64Bit, 1,
                outs, !con(ins, imm16ins),
                "cmpi" # !if(is64Bit, "64", "32") # "w" # opsuffix,
                "@" # op1str # ", " # imm16str> {
    let Inst{7} = 0;
    let Inst{12} = 0;
  }
  def wOp1IIdx : EBCInst1Op<opcode, 0, is64Bit, 1,
                outs, !con(ins, imm16ins, idxins),
                "cmpi" # !if(is64Bit, "64", "32") # "w" # opsuffix,
                "@" # op1str # " " # idxstr # ", " # imm16str> {
    let Inst{7} = 0;
    let Inst{12} = 1;
  }
  def dOp1D : EBCInst1Op<opcode, 0, is64Bit, 0,
                outs, !con(ins, imm32ins),
                "cmpi" # !if(is64Bit, "64", "32") # "d" # opsuffix,
                op1str # ", " # imm32str> {
    let Inst{7} = 1;
    let Inst{12} = 0;
  }
  def dOp1I : EBCInst1Op<opcode, 0, is64Bit, 1,
                outs, !con(ins, imm32ins),
                "cmpi" # !if(is64Bit, "64", "32") # "d" # opsuffix,
                "@" # op1str # " " # imm32str> {
    let Inst{7} = 1;
    let Inst{12} = 0;
  }
  def dOp1IIdx : EBCInst1Op<opcode, 0, is64Bit, 1,
                outs, !con(ins, imm32ins, idxins),
                "cmpi" # !if(is64Bit, "64", "32") # "d" # opsuffix,
                "@" # op1str # " " # idxstr # ", " # imm16str> {
    let Inst{7} = 1;
    let Inst{12} = 1;
  }
}

multiclass EBCMOVBase<bits<6> opcode, bits<2> idxlen, bits<2> movlen,
                dag outs, dag ins, dag op1idxins, dag op2idxins,
                string opcodestr, string op1str, string op2str,
                string op1idxstr, string op2idxstr> {
  def Op1DOp2D
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 0, 0,
                  outs, ins,
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  op1str # ", " # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IOp2D
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 0,
                  outs, ins,
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # ", " # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1DOp2I
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 0, 1,
                  outs, ins,
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  op1str # ", " # "@" # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IOp2I
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 1,
                  outs, ins,
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # ", " # "@" # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IIdxOp2D
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 0,
                  outs, !con(ins, op1idxins),
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # " " # op1idxstr # ", " # op2str> {
    let Inst{7} = 1;
    let Inst{6} = 0;
  }
  def Op1IIdxOp2I
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 1,
                  outs, !con(ins, op1idxins),
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # " " # op1idxstr # ", " # "@" # op2str> {
    let Inst{7} = 1;
    let Inst{6} = 0;
  }
  def Op1DOp2IIdx
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 0, 1,
                  outs, !con(ins, op2idxins),
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  op1str # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{7} = 0;
    let Inst{6} = 1;
  }
  def Op1IOp2IIdx
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 1,
                  outs, !con(ins, op2idxins),
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{7} = 0;
    let Inst{6} = 1;
  }
  def Op1IIdxOp2IIdx
        # !cond(!eq(movlen, 0b00) : "b",
                !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d",
                !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w",
                !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q")
      : EBCInst2Op<!add(opcode, !shl(idxlen, 2), movlen), 0, 0, 1, 1,
                  outs, !con(ins, op1idxins, op2idxins),
                  opcodestr
                    # !cond(!eq(movlen, 0b00) : "b",
                            !eq(movlen, 0b01) : "w",
                            !eq(movlen, 0b10) : "d",
                            !eq(movlen, 0b11) : "q")
                    # !cond(!eq(idxlen, 0b01) : "w",
                            !eq(idxlen, 0b10) : "d",
                            !eq(idxlen, 0b11) : "q"),
                  "@" # op1str # " " # op1idxstr # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{7} = 1;
    let Inst{6} = 1;
  }
}

multiclass EBCMOVIBaseCommon<bits<6> opcode, bits<2> immlen, bits<2> movlen,
                dag outs, dag ins, dag idxins, dag immins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  def Op1D
      # !cond(!eq(movlen, 0b00) : "b",
              !eq(movlen, 0b01) : "w",
              !eq(movlen, 0b10) : "d",
              !eq(movlen, 0b11) : "q")
      # !cond(!eq(immlen, 0b01) : "w",
              !eq(immlen, 0b10) : "d",
              !eq(immlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 0,
                outs, !con(ins, immins),
                opcodestr
                  # !cond(!eq(movlen, 0b00) : "b",
                          !eq(movlen, 0b01) : "w",
                          !eq(movlen, 0b10) : "d",
                          !eq(movlen, 0b11) : "q")
                  # !cond(!eq(immlen, 0b01) : "w",
                          !eq(immlen, 0b10) : "d",
                          !eq(immlen, 0b11) : "q"),
                op1str # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{13-12} = movlen;
  }
  def Op1I
      # !cond(!eq(movlen, 0b00) : "b",
              !eq(movlen, 0b01) : "w",
              !eq(movlen, 0b10) : "d",
              !eq(movlen, 0b11) : "q")
      # !cond(!eq(immlen, 0b01) : "w",
              !eq(immlen, 0b10) : "d",
              !eq(immlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, immins),
                opcodestr
                  # !cond(!eq(movlen, 0b00) : "b",
                          !eq(movlen, 0b01) : "w",
                          !eq(movlen, 0b10) : "d",
                          !eq(movlen, 0b11) : "q")
                  # !cond(!eq(immlen, 0b01) : "w",
                          !eq(immlen, 0b10) : "d",
                          !eq(immlen, 0b11) : "q"),
                "@" # op1str # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{13-12} = movlen;
  }
  def Op1IIdx
      # !cond(!eq(movlen, 0b00) : "b",
              !eq(movlen, 0b01) : "w",
              !eq(movlen, 0b10) : "d",
              !eq(movlen, 0b11) : "q")
      # !cond(!eq(immlen, 0b01) : "w",
              !eq(immlen, 0b10) : "d",
              !eq(immlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, immins, idxins),
                opcodestr
                  # !cond(!eq(movlen, 0b00) : "b",
                          !eq(movlen, 0b01) : "w",
                          !eq(movlen, 0b10) : "d",
                          !eq(movlen, 0b11) : "q")
                  # !cond(!eq(immlen, 0b01) : "w",
                          !eq(immlen, 0b10) : "d",
                          !eq(immlen, 0b11) : "q"),
                "@" # op1str # " " #  idxstr # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{13-12} = movlen;
  }
}

multiclass EBCMOVInBase<bits<6> opcode, bits<2> op2idxlen,
                dag outs, dag ins, dag op1idxins, dag op2idxins,
                string opcodestr, string op1str,
                string op1idxstr, string op2idxstr> {
  def OP1D
      # !cond(!eq(op2idxlen, 0b01) : "w",
              !eq(op2idxlen, 0b10) : "d",
              !eq(op2idxlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 0,
                outs, !con(ins, op2idxins),
                opcodestr
                  # !cond(!eq(op2idxlen, 0b01) : "w",
                          !eq(op2idxlen, 0b10) : "d",
                          !eq(op2idxlen, 0b11) : "q"),
                  op1str # ", " # op2idxstr> {
    let Inst{7-6} = op2idxlen;
    let Inst{14} = 0;
  }
  def OP1I
      # !cond(!eq(op2idxlen, 0b01) : "w",
              !eq(op2idxlen, 0b10) : "d",
              !eq(op2idxlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, op2idxins),
                opcodestr
                  # !cond(!eq(op2idxlen, 0b01) : "w",
                          !eq(op2idxlen, 0b10) : "d",
                          !eq(op2idxlen, 0b11) : "q"),
                  "@" # op1str # ", " # op2idxstr> {
    let Inst{7-6} = op2idxlen;
    let Inst{14} = 0;
  }
  def OP1IIdx
      # !cond(!eq(op2idxlen, 0b01) : "w",
              !eq(op2idxlen, 0b10) : "d",
              !eq(op2idxlen, 0b11) : "q") : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, op1idxins, op2idxins),
                opcodestr
                  # !cond(!eq(op2idxlen, 0b01) : "w",
                          !eq(op2idxlen, 0b10) : "d",
                          !eq(op2idxlen, 0b11) : "q"),
                  "@" # op1str # " " # op1idxstr  # ", " # op2idxstr> {
    let Inst{7-6} = op2idxlen;
    let Inst{14} = 1;
  }
}

multiclass EBCMOVnBase<bits<6> opcode,
                dag outs, dag ins, dag op1idxins, dag op2idxins,
                string opcodestr, string op1str, string op2str,
                string op1idxstr, string op2idxstr> {
  def Op1DOp2D : EBCInst2Op<opcode, 0, 0, 0, 0, outs, ins,
                opcodestr, op1str # ", " # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IOp2D : EBCInst2Op<opcode, 0, 0, 1, 0, outs, ins,
                opcodestr, "@" # op1str # ", " # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1DOp2I : EBCInst2Op<opcode, 0, 0, 0, 1, outs, ins,
                opcodestr, op1str # ", @" # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IOp2I : EBCInst2Op<opcode, 0, 0, 1, 1, outs, ins,
                opcodestr, "@" # op1str # ", @" # op2str> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def Op1IIdxOp2D : EBCInst2Op<opcode, 0, 0, 1, 0,
                outs, !con(ins, op1idxins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", " # op2str> {
    let Inst{7} = 1;
    let Inst{6} = 0;
  }
  def Op1DOp2IIdx : EBCInst2Op<opcode, 0, 0, 0, 1,
                outs, !con(ins, op2idxins), opcodestr,
                op1str # ", @" # op2str # " " # op2idxstr> {
    let Inst{7} = 1;
    let Inst{6} = 0;
  }
  def Op1IIdxOp2IIdx : EBCInst2Op<opcode, 0, 0, 1, 1,
                outs, !con(ins, op1idxins, op2idxins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", @" # op2str # " " # op2idxstr> {
    let Inst{7} = 1;
    let Inst{6} = 1;
  }
}

multiclass EBCMOVRELBase<bits<6> opcode, bits<2> immlen,
                dag outs, dag ins,
                dag immins, dag idxins,
                string opcodestr, string op1str,
                string immstr, string idxstr> {
  def !cond(!eq(immlen, 0b01) : "w",
            !eq(immlen, 0b10) : "d",
            !eq(immlen, 0b11) : "q")
        # Op1D : EBCInst1Op<opcode, 0, 0, 0,
                outs, !con(ins, immins),
                opcodestr # !cond(!eq(immlen, 0b01) : "w",
                                  !eq(immlen, 0b10) : "d",
                                  !eq(immlen, 0b11) : "q"),
                op1str # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{14} = 0;
  }
  def !cond(!eq(immlen, 0b01) : "w",
            !eq(immlen, 0b10) : "d",
            !eq(immlen, 0b11) : "q")
        # Op1I : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, immins),
                opcodestr # !cond(!eq(immlen, 0b01) : "w",
                                  !eq(immlen, 0b10) : "d",
                                  !eq(immlen, 0b11) : "q"),
                "@" # op1str # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{14} = 0;
  }
  def !cond(!eq(immlen, 0b01) : "w",
            !eq(immlen, 0b10) : "d",
            !eq(immlen, 0b11) : "q")
        # Op1IIdx : EBCInst1Op<opcode, 0, 0, 1,
                outs, !con(ins, immins, idxins),
                opcodestr # !cond(!eq(immlen, 0b01) : "w",
                                  !eq(immlen, 0b10) : "d",
                                  !eq(immlen, 0b11) : "q"),
                "@" # op1str # " " # idxstr # ", " # immstr> {
    let Inst{7-6} = immlen;
    let Inst{14} = 1;
  }
}

multiclass EBCMOVsnBase<bits<6> opcode,
                dag outs, dag ins,
                dag op1idxins, dag op2idxins, dag op2immins,
                string opcodestr, string op1str, string op2str,
                string op1idxstr, string op2idxstr, string op2immstr> {
  def Op1DOp2D : EBCInst2Op<opcode, 0, 0, 0, 0, outs, ins,
                opcodestr, op1str # ", " # op2str>;
  def Op1IOp2D : EBCInst2Op<opcode, 0, 0, 1, 0, outs, ins,
                opcodestr, "@" # op1str # ", " # op2str>;
  def Op1DOp2I : EBCInst2Op<opcode, 0, 0, 0, 1, outs, ins,
                opcodestr, op1str # ", " # "@" # op2str>;
  def Op1IOp2I : EBCInst2Op<opcode, 0, 0, 1, 1, outs, ins,
                opcodestr, "@" # op1str # ", " # "@" # op2str>;
  def Op1IIdxOp2D : EBCInst2Op<opcode, 0, 0, 1, 0,
                outs, !con(ins, op1idxins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", " # op2str> {
    let Inst{7} = 1;
  }
  def Op1IIdxOp2I : EBCInst2Op<opcode, 0, 0, 1, 1,
                outs, !con(ins, op1idxins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", " # "@" # op2str> {
    let Inst{7} = 1;
  }
  def Op1DOp2IIdx : EBCInst2Op<opcode, 0, 0, 0, 1,
                outs, !con(ins, op2idxins), opcodestr,
                op1str # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{6} = 1;
  }
  def Op1IOp2IIdx : EBCInst2Op<opcode, 0, 0, 1, 1,
                outs, !con(ins, op2idxins), opcodestr,
                "@" # op1str # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{6} = 1;
  }
  def Op1IIdxOp2IIdx : EBCInst2Op<opcode, 0, 0, 1, 1,
                outs, !con(ins, op1idxins, op2idxins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", " # "@" # op2str # " " # op2idxstr> {
    let Inst{7} = 1;
    let Inst{6} = 1;
  }
  def Op1DOp2DImm : EBCInst2Op<opcode, 0, 0, 0, 0,
                outs, !con(ins, op2immins), opcodestr,
                op1str # ", " # op2str # " " # op2immstr> {
    let Inst{6} = 1;
  }
  def Op1IOp2DImm : EBCInst2Op<opcode, 0, 0, 1, 0,
                outs, !con(ins, op2immins), opcodestr,
                "@" # op1str # ", " # op2str # " " # op2immstr> {
    let Inst{6} = 1;
  }
  def Op1IIdxOp2DImm : EBCInst2Op<opcode, 0, 0, 1, 0,
                outs, !con(ins, op1idxins, op2immins), opcodestr,
                "@" # op1str # " " # op1idxstr # ", " # op2str # " " # op2immstr> {
    let Inst{7} = 1;
    let Inst{6} = 1;
  }
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

multiclass EBCCMPIBase<bits<6> opcode, string opsuffix> {
  defm _32 : EBCCMPIBaseCommon<opcode, 0,
                (outs), (ins GPR:$op1),
                (ins imm16:$imm), (ins imm32:$imm),
                (ins idxn16:$idxn, idxc16:$idxc),
                opsuffix, "$op1", "$imm", "$imm", "(${idxn},${idxc})">;
  defm _64 : EBCCMPIBaseCommon<opcode, 1,
                (outs), (ins GPR:$op1),
                (ins imm16:$imm), (ins imm32:$imm),
                (ins idxn16:$idxn, idxc16:$idxc),
                opsuffix, "$op1", "$imm", "$imm", "(${idxn},${idxc})">;
}

multiclass EBCJMPBaseCommon<bits<6> opcode,
                bit hasImmIdx, bit is64Bit, bit Op1Indirect,
                dag outs, dag ins, string opcodestr, string argstr> {
  def UncondAbs : EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # "a", argstr> {
    let Inst{15} = 0;
    let Inst{14} = 0;
    let Inst{12} = 0;
  }
  def CondCCAbs: EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # "cca", argstr> {
    let Inst{15} = 1;
    let Inst{14} = 0;
    let Inst{12} = 0;
  }
  def CondCSAbs: EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # "csa", argstr> {
    let Inst{15} = 1;
    let Inst{14} = 1;
    let Inst{12} = 0;
  }
  def UncondRel : EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32"), argstr> {
    let Inst{15} = 0;
    let Inst{14} = 0;
    let Inst{12} = 1;
  }
  def CondCCRel: EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # "cc", argstr> {
    let Inst{15} = 1;
    let Inst{14} = 0;
    let Inst{12} = 1;
  }
  def CondCSRel: EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # "cs", argstr> {
    let Inst{15} = 1;
    let Inst{14} = 1;
    let Inst{12} = 1;
  }
}

multiclass EBCCALLBaseCommon<bits<6> opcode,
                bit hasImmIdx, bit is64Bit, bit isNative, bit Op1Indirect,
                dag outs, dag ins, string opcodestr, string argstr> {
  def Abs : EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # !if(isNative, "ex", "")# "a", argstr> {
    let Inst{13} = isNative;
    let Inst{12} = 0;
  }
  def Rel : EBCInst1Op<opcode,
                hasImmIdx, is64Bit, Op1Indirect, outs, ins,
                opcodestr # !if(is64Bit, "64", "32") # !if(isNative, "ex", ""), argstr> {
    let Inst{13} = isNative;
    let Inst{12} = 1;
  }
}

multiclass EBCJMPBase<bits<6> opcode, string opcodestr> {
  defm _32Op1D : EBCJMPBaseCommon<opcode, 0, 0, 0,
                (outs), (ins GPR:$op1), opcodestr, "$op1">;
  defm _32Op1I : EBCJMPBaseCommon<opcode, 0, 0, 1,
                (outs), (ins GPR:$op1), opcodestr, "@" # "$op1">;
  defm _32Op1DImm : EBCJMPBaseCommon<opcode, 1, 0, 0,
                (outs), (ins GPR:$op1, imm32:$imm),
                opcodestr, "$op1" # " " # "$imm">;
  defm _32Op1IIdx : EBCJMPBaseCommon<opcode, 1, 0, 1,
                (outs), (ins GPR:$op1, idxn32:$idxn, idxc32:$idxc),
                opcodestr, "@" # "$op1" # " " # "(${idxn},${idxc})">;
  defm _64 : EBCJMPBaseCommon<opcode, 1, 1, 1,
                (outs), (ins imm64:$imm), opcodestr, "$imm">;
}

multiclass EBCJMP8Base<bits<6> opcode, string opcodestr> {
  def Uncond : EBCInst8<opcode,
                  (outs), (ins imm8:$imm), opcodestr, "$imm", []> {
    let Inst{7} = 0;
    let Inst{6} = 0;
  }
  def CondCC : EBCInst8<opcode,
                  (outs), (ins imm8:$imm), opcodestr # "cc", "$imm", []> {
    let Inst{7} = 1;
    let Inst{6} = 0;
  }
  def CondCS : EBCInst8<opcode,
                  (outs), (ins imm8:$imm), opcodestr # "cs", "$imm", []> {
    let Inst{7} = 1;
    let Inst{6} = 1;
  }
}

multiclass EBCCALLBase<bits<6> opcode, string opcodestr> {
  defm _32EBCOp1D : EBCCALLBaseCommon<opcode, 0, 0, 0, 0,
                (outs), (ins GPR:$op1), opcodestr, "$op1">;
  defm _32NativeOp1D : EBCCALLBaseCommon<opcode, 0, 0, 1, 0,
                (outs), (ins GPR:$op1), opcodestr, "$op1">;
  defm _32EBCOp1I : EBCCALLBaseCommon<opcode, 0, 0, 0, 1,
                (outs), (ins GPR:$op1), opcodestr, "@$op1">;
  defm _32NativeOp1I : EBCCALLBaseCommon<opcode, 0, 0, 1, 1,
                (outs), (ins GPR:$op1), opcodestr, "@$op1">;
  defm _32EBCOp1DImm : EBCCALLBaseCommon<opcode, 1, 0, 0, 0,
                (outs), (ins GPR:$op1, imm32:$imm),
                opcodestr, "$op1 $imm">;
  defm _32NativeOp1DImm : EBCCALLBaseCommon<opcode, 1, 0, 1, 0,
                (outs), (ins GPR:$op1, imm32:$imm),
                opcodestr, "$op1 $imm">;
  defm _32EBCOp1IIdx : EBCCALLBaseCommon<opcode, 1, 0, 0, 1,
                (outs), (ins GPR:$op1, idxn32:$idxn, idxc32:$idxc),
                opcodestr, "@$op1 (${idxn},${idxc})">;
  defm _32NativeOp1IIdx : EBCCALLBaseCommon<opcode, 1, 0, 1, 1,
                (outs), (ins GPR:$op1, idxn32:$idxn, idxc32:$idxc),
                opcodestr, "@$op1 (${idxn},${idxc})">;
  defm _64EBCImm : EBCCALLBaseCommon<opcode, 1, 1, 0, 0,
                (outs), (ins imm64:$imm), opcodestr, "$imm">;
  defm _64NativeImm : EBCCALLBaseCommon<opcode, 1, 1, 1, 0,
                (outs), (ins imm64:$imm), opcodestr, "$imm">;
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

defm call   : EBCCALLBase<0b000011, "call">;

defm jmp    : EBCJMPBase<0x000001, "jmp">;
defm jmp8   : EBCJMP8Base<0x000010, "jmp8">;

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

defm cmpieq   : EBCCMPIBase<0b101101, "eq">;
defm cmpilte  : EBCCMPIBase<0b101110, "lte">;
defm cmpigte  : EBCCMPIBase<0b101111, "gte">;
defm cmpiulte : EBCCMPIBase<0b110000, "ulte">;
defm cmpiugte : EBCCMPIBase<0b110001, "ugte">;

defm movnw  : EBCMOVnBase<0b110010,
                (outs GPR:$op1), (ins GPR:$op2),
                (ins idxn16:$op1idxn, idxc16:$op1idxc),
                (ins idxn16:$op2idxn, idxc16:$op2idxc),
                "movnw", "$op1", "$op2",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
defm movnd  : EBCMOVnBase<0b110011,
                (outs GPR:$op1), (ins GPR:$op2),
                (ins idxn32:$op1idxn, idxc32:$op1idxc),
                (ins idxn32:$op2idxn, idxc32:$op2idxc),
                "movnd", "$op1", "$op2",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;

foreach immlen = [0b01, 0b10, 0b11] in
defm movrel : EBCMOVRELBase<0b111001, immlen,
                (outs GPR:$op1), (ins),
                !cond(!eq(immlen, 0b01) : (ins imm16:$imm),
                      !eq(immlen, 0b10) : (ins imm32:$imm),
                      !eq(immlen, 0b11) : (ins imm64:$imm)),
                (ins idxn16:$op1idxn, idxc16:$op1idxc),
                "movrel", "$op1", "$imm", "(${op1idxn},${op1idxc})">;

defm movsnw : EBCMOVsnBase<0b100101,
                (outs GPR:$op1), (ins GPR:$op2),
                (ins idxn16:$op1idxn, idxc16:$op1idxc),
                (ins idxn16:$op2idxn, idxc16:$op2idxc),
                (ins imm16:$imm),
                "movsnw", "$op1", "$op2",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})",
                "$imm">;
defm movsnd : EBCMOVsnBase<0b100110,
                (outs GPR:$op1), (ins GPR:$op2),
                (ins idxn16:$op1idxn, idxc16:$op1idxc),
                (ins idxn32:$op2idxn, idxc32:$op2idxc),
                (ins imm32:$imm),
                "movsnd", "$op1", "$op2",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})",
                "$imm">;

foreach immlen = [0b01, 0b10, 0b11] in {
  foreach movlen = [0b00, 0b01, 0b10, 0b11] in 
  defm movi : EBCMOVIBaseCommon<0b110111, immlen, movlen,
                (outs GPR:$op1), (ins),
                (ins idxn16:$idxn, idxc16:$idxc),
                !cond(!eq(immlen, 0b01) : (ins imm16:$imm),
                      !eq(immlen, 0b10) : (ins imm32:$imm),
                      !eq(immlen, 0b11) : (ins imm64:$imm)),
                "movi", "$op1", "$imm", "(${idxn},${idxc})">;
}

foreach op2idxlen = [0b01, 0b10, 0b11] in
defm movin : EBCMOVInBase<0b111000, op2idxlen,
                (outs GPR:$op1), (ins),
                (ins idxn16:$op1idxn, idxc16:$op1idxc),
                !cond(
  !eq(op2idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
  !eq(op2idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc),
  !eq(op2idxlen, 0b11) : (ins idxn64:$op2idxn, idxc64:$op2idxc)),
                "movin", "$op1",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;

foreach idxlen = [0b01, 0b10] in {
  foreach movlen = [0b00, 0b01, 0b10, 0b11] in
  defm mov : EBCMOVBase<0b011000, idxlen, movlen,
                (outs GPR:$op1), (ins GPR:$op2),
                !cond(
    !eq(idxlen, 0b01) : (ins idxn16:$op1idxn, idxc16:$op1idxc),
    !eq(idxlen, 0b10) : (ins idxn32:$op1idxn, idxc32:$op1idxc)),
                !cond(
    !eq(idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
    !eq(idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc)),
                "mov", "$op1", "$op2",
                "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
}

defm mov : EBCMOVBase<0b011000, 0b11, 0b11,
              (outs GPR:$op1), (ins GPR:$op2),
              (ins idxn64:$op1idxn, idxc64:$op1idxc),
              (ins idxn64:$op2idxn, idxc64:$op2idxc),
              "mov", "$op1", "$op2",
              "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
