include "EBCInstrFormats.td"

// Forward definition
def breakcode;
def imm16;
def idx16;
def imm32;
def imm8;
def idx32;
def imm64;
def idx64;
def sn16;
def sn32;

multiclass EBCInstPOP<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1D : EBCInst16Op1<opcode, 0, 0,
            (outs GPR:$op1), (ins), !strconcat(opcodestr, "32"), "$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 32Op1I : EBCInst16Op1<opcode, 0, 1,
            (outs GPR:$op1), (ins), !strconcat(opcodestr, "32"), "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1D : EBCInst16Op1<opcode, 1, 0,
            (outs GPR:$op1), (ins), !strconcat(opcodestr, "64"), "$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 64Op1I : EBCInst16Op1<opcode, 1, 1,
            (outs GPR:$op1), (ins), !strconcat(opcodestr, "64"), "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DImm : EBCInst32Op1<opcode, 0, 0,
            (outs GPR:$op1, imm16:$immidx), (ins),
            !strconcat(opcodestr, "32"), "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 32Op1IIdx : EBCInst32Op1<opcode, 0, 1,
            (outs GPR:$op1, idx16:$immidx), (ins),
            !strconcat(opcodestr, "32"), "@$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DImm : EBCInst32Op1<opcode, 1, 0,
            (outs GPR:$op1, imm16:$immidx), (ins),
            !strconcat(opcodestr, "64"), "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 64Op1IIdx : EBCInst16Op1<opcode, 1, 1,
            (outs GPR:$op1, idx16:$immidx), (ins),
            !strconcat(opcodestr, "64"), "@$op1 $immidx">;
}

multiclass EBCInstPUSH<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1D : EBCInst16Op1<opcode, 0, 0,
            (outs), (ins GPR:$op1), !strconcat(opcodestr, "32"), "$op1">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1I : EBCInst16Op1<opcode, 0, 1,
            (outs), (ins GPR:$op1), !strconcat(opcodestr, "32"), "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1D : EBCInst16Op1<opcode, 1, 0,
            (outs), (ins GPR:$op1), !strconcat(opcodestr, "64"), "$op1">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1I : EBCInst16Op1<opcode, 1, 1,
            (outs), (ins GPR:$op1), !strconcat(opcodestr, "64"), "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DImm : EBCInst32Op1<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm16:$immidx),
            !strconcat(opcodestr, "32"), "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1IIdx : EBCInst32Op1<opcode, 0, 1,
            (outs), (ins GPR:$op1, idx16:$immidx),
            !strconcat(opcodestr, "32"), "@$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DImm : EBCInst32Op1<opcode, 1, 0,
            (outs), (ins GPR:$op1, imm16:$immidx),
            !strconcat(opcodestr, "64"), "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1IIdx : EBCInst16Op1<opcode, 1, 1,
            (outs), (ins GPR:$op1, idx16:$immidx),
            !strconcat(opcodestr, "64"), "@$op1 $immidx">;
}

multiclass EBCInstPOPn<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def nOp1D : EBCInst16Op1<opcode, 0, 0,
            (outs GPR:$op1), (ins), opcodestr, "$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def nOp1I : EBCInst16Op1<opcode, 0, 1,
            (outs GPR:$op1), (ins), opcodestr, "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def nOp1DImm : EBCInst32Op1<opcode, 0, 0,
            (outs GPR:$op1, imm16:$immidx), (ins),
            opcodestr, "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def nOp1IIdx : EBCInst32Op1<opcode, 0, 1,
            (outs GPR:$op1, idx16:$immidx), (ins),
            opcodestr, "@$op1 $immidx">;
}

multiclass EBCInstPUSHn<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def nOp1D : EBCInst16Op1<opcode, 0, 0,
            (outs), (ins GPR:$op1), opcodestr, "$op1">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def nOp1I : EBCInst16Op1<opcode, 0, 1,
            (outs), (ins GPR:$op1), opcodestr, "@$op1">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def nOp1DImm : EBCInst32Op1<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm16:$immidx),
            opcodestr, "$op1 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def nOp1IIdx : EBCInst32Op1<opcode, 0, 1,
            (outs), (ins GPR:$op1, idx16:$immidx),
            opcodestr, "@$op1 $immidx">;
}

multiclass EBCInstArith<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DOp2D : EBCInst16Op1Op2<opcode, 0, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "32"), "$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DOp2D : EBCInst16Op1Op2<opcode, 1, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "64"), "$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 32Op1IOp2D : EBCInst16Op1Op2<opcode, 0, 1, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "32"), "@$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 64Op1IOp2D : EBCInst16Op1Op2<opcode, 1, 1, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "64"), "@$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1DOp2I : EBCInst16Op1Op2<opcode, 0, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "32"), "$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1DOp2I : EBCInst16Op1Op2<opcode, 1, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "64"), "$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def 32Op1IOp2I : EBCInst16Op1Op2<opcode, 0, 1, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "32"), "@$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def 64Op1IOp2I : EBCInst16Op1Op2<opcode, 1, 1, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat(opcodestr, "64"), "@$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DOp2DImm : EBCInst16Op1Op2<opcode, 0, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat(opcodestr, "32"), "$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DOp2DImm : EBCInst16Op1Op2<opcode, 1, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat(opcodestr, "64"), "$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 32Op1IOp2DImm : EBCInst16Op1Op2<opcode, 0, 1, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat(opcodestr, "32"), "@$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
  def 64Op1IOp2DImm : EBCInst16Op1Op2<opcode, 1, 1, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat(opcodestr, "64"), "@$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1DOp2IIdx : EBCInst16Op1Op2<opcode, 0, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat(opcodestr, "32"), "$op1, @$op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1DOp2IIdx : EBCInst16Op1Op2<opcode, 1, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat(opcodestr, "64"), "$op1, @$op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def 32Op1IOp2IIdx : EBCInst16Op1Op2<opcode, 0, 1, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat(opcodestr, "32"), "@$op1, @$op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 1 in
  def 64Op1IOp2IIdx : EBCInst16Op1Op2<opcode, 1, 1, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat(opcodestr, "64"), "@$op1, @$op2 $immidx">;
}

multiclass EBCInstCMP<bits<6> opcode, string opcodestr> {
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DOp2D : EBCInst16Op1Op2<opcode, 0, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat("CMP", opcodestr, "32"), "$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DOp2D : EBCInst16Op1Op2<opcode, 1, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat("CMP", opcodestr, "64"), "$op1, $op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1DOp2I : EBCInst16Op1Op2<opcode, 0, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat("CMP", opcodestr, "32"), "$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1DOp2I : EBCInst16Op1Op2<opcode, 1, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2),
            !strconcat("CMP", opcodestr, "64"), "$op1, @$op2">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 32Op1DOp2DImm : EBCInst16Op1Op2<opcode, 0, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat("CMP", opcodestr, "32"), "$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
  def 64Op1DOp2DImm : EBCInst16Op1Op2<opcode, 1, 0, 0,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, imm16:$immidx),
            !strconcat("CMP", opcodestr, "64"), "$op1, $op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 32Op1DOp2IIdx : EBCInst16Op1Op2<opcode, 0, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat("CMP", opcodestr, "32"), "$op1, @$op2 $immidx">;
  let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
  def 64Op1DOp2IIdx : EBCInst16Op1Op2<opcode, 1, 0, 1,
            (outs GPR:$op1), (ins GPR:$op1, GPR:$op2, idx16:$immidx),
            !strconcat("CMP", opcodestr, "64"), "$op1, @$op2 $immidx">;
}

multiclass EBCInstCMPI<bits<6> opcode, string opcodestr> {
  def 32Op1D16Imm : EBCInstCMPI16<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm16:$imm),
            !strconcat("CMPI", "w", opcodestr, "32"), "$op1, $imm">;
  def 64Op1D16Imm : EBCInstCMPI16<opcode, 1, 0,
            (outs), (ins GPR:$op1, imm16:$imm),
            !strconcat("CMPI", "w", opcodestr, "64"), "$op1, $imm">;
  def 32Op1I16Imm : EBCInstCMPI16<opcode, 0, 1,
            (outs), (ins GPR:$op1, imm16:$imm),
            !strconcat("CMPI", "w", opcodestr, "32"), "@$op1, $imm">;
  def 64Op1I16Imm : EBCInstCMPI16<opcode, 1, 1,
            (outs), (ins GPR:$op1, imm16:$imm),
            !strconcat("CMPI", "w", opcodestr, "64"), "@$op1, $imm">;
  def 32Op1D32Imm : EBCInstCMPI32<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm32:$imm),
            !strconcat("CMPI", "d", opcodestr, "32"), "$op1, $imm">;
  def 64Op1D32Imm : EBCInstCMPI32<opcode, 1, 0,
            (outs), (ins GPR:$op1, imm32:$imm),
            !strconcat("CMPI", "d", opcodestr, "64"), "$op1, $imm">;
  def 32Op1I32Imm : EBCInstCMPI32<opcode, 0, 1,
            (outs), (ins GPR:$op1, imm32:$imm),
            !strconcat("CMPI", "d", opcodestr, "32"), "@$op1, $imm">;
  def 64Op1I32Imm : EBCInstCMPI32<opcode, 1, 1,
            (outs), (ins GPR:$op1, imm32:$imm),
            !strconcat("CMPI", "d", opcodestr, "64"), "@$op1, $imm">;
  def 32Op1D16ImmIdx : EBCInstCMPI16Idx<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm16:$imm, idx16:$idx),
            !strconcat("CMPI", "w", opcodestr, "32"), "$op1 $idx, $imm">;
  def 64Op1D16ImmIdx : EBCInstCMPI16Idx<opcode, 1, 0,
            (outs), (ins GPR:$op1, imm16:$imm, idx16:$idx),
            !strconcat("CMPI", "w", opcodestr, "64"), "$op1 $idx, $imm">;
  def 32Op1I16ImmIdx : EBCInstCMPI16Idx<opcode, 0, 1,
            (outs), (ins GPR:$op1, imm16:$imm, idx16:$idx),
            !strconcat("CMPI", "w", opcodestr, "32"), "@$op1 $idx, $imm">;
  def 64Op1I16ImmIdx : EBCInstCMPI16Idx<opcode, 1, 1,
            (outs), (ins GPR:$op1, imm16:$imm, idx16:$idx),
            !strconcat("CMPI", "w", opcodestr, "64"), "@$op1 $idx, $imm">;
  def 32Op1D32ImmIdx : EBCInstCMPI32Idx<opcode, 0, 0,
            (outs), (ins GPR:$op1, imm32:$imm, idx16:$idx),
            !strconcat("CMPI", "d", opcodestr, "32"), "$op1 $idx, $imm">;
  def 64Op1D32ImmIdx : EBCInstCMPI32Idx<opcode, 1, 0,
            (outs), (ins GPR:$op1, imm32:$imm, idx16:$idx),
            !strconcat("CMPI", "d", opcodestr, "64"), "$op1 $idx, $imm">;
  def 32Op1I32ImmIdx : EBCInstCMPI32Idx<opcode, 0, 1,
            (outs), (ins GPR:$op1, imm32:$imm, idx16:$idx),
            !strconcat("CMPI", "d", opcodestr, "32"), "@$op1 $idx, $imm">;
  def 64Op1I32ImmIdx : EBCInstCMPI32Idx<opcode, 1, 1,
            (outs), (ins GPR:$op1, imm32:$imm, idx16:$idx),
            !strconcat("CMPI", "d", opcodestr, "64"), "@$op1 $idx, $imm">;
}

// TODO: JMP mnemonic is not clearly define the abs/rel jmp
multiclass EBCInstJMP<bits<6> opcode> {
  def 32Op1DUnCondAbs : EBCInstJMP32<opcode, 0, 0, 0, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32"), "$op1">;
  def 32Op1DCondCCAbs : EBCInstJMP32<opcode, 1, 0, 0, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cc"), "$op1">;
  def 32Op1DCondCSAbs : EBCInstJMP32<opcode, 1, 1, 0, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cs"), "$op1">;
  def 32Op1DUnCondRel : EBCInstJMP32<opcode, 0, 0, 1, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32"), "$op1">;
  def 32Op1DCondCCRel : EBCInstJMP32<opcode, 1, 0, 1, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cc"), "$op1">;
  def 32Op1DCondCSRel : EBCInstJMP32<opcode, 1, 1, 1, 0,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cs"), "$op1">;

  def 32Op1IUnCondAbs : EBCInstJMP32<opcode, 0, 0, 0, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32"), "$op1">;
  def 32Op1ICondCCAbs : EBCInstJMP32<opcode, 1, 0, 0, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cc"), "$op1">;
  def 32Op1ICondCSAbs : EBCInstJMP32<opcode, 1, 1, 0, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cs"), "$op1">;
  def 32Op1IUnCondRel : EBCInstJMP32<opcode, 0, 0, 1, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32"), "$op1">;
  def 32Op1ICondCCRel : EBCInstJMP32<opcode, 1, 0, 1, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cc"), "$op1">;
  def 32Op1ICondCSRel : EBCInstJMP32<opcode, 1, 1, 1, 1,
            (outs), (ins GPR:$op1),
            !strconcat("JMP", "32", "cs"), "$op1">;

  def 32Op1DUnCondAbsImm : EBCInstJMP32ImmIdx<opcode, 0, 0, 0, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32"), "$op1 $immidx">;
  def 32Op1DCondCCAbsImm : EBCInstJMP32ImmIdx<opcode, 1, 0, 0, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32", "cc"), "$op1 $immidx">;
  def 32Op1DCondCSAbsImm : EBCInstJMP32ImmIdx<opcode, 1, 1, 0, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32", "cs"), "$op1 $immidx">;
  def 32Op1DUnCondRelImm : EBCInstJMP32ImmIdx<opcode, 0, 0, 1, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32"), "$op1 $immidx">;
  def 32Op1DCondCCRelImm : EBCInstJMP32ImmIdx<opcode, 1, 0, 1, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32", "cc"), "$op1 $immidx">;
  def 32Op1DCondCSRelImm : EBCInstJMP32ImmIdx<opcode, 1, 1, 1, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("JMP", "32", "cs"), "$op1 $immidx">;

  def 32Op1DUnCondAbsIdx : EBCInstJMP32ImmIdx<opcode, 0, 0, 0, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32"), "$op1 @$immidx">;
  def 32Op1DCondCCAbsIdx : EBCInstJMP32ImmIdx<opcode, 1, 0, 0, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32", "cc"), "$op1 @$immidx">;
  def 32Op1DCondCSAbsIdx : EBCInstJMP32ImmIdx<opcode, 1, 1, 0, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32", "cs"), "$op1 @$immidx">;
  def 32Op1DUnCondRelIdx : EBCInstJMP32ImmIdx<opcode, 0, 0, 1, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32"), "$op1 @$immidx">;
  def 32Op1DCondCCRelIdx : EBCInstJMP32ImmIdx<opcode, 1, 0, 1, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32", "cc"), "$op1 @$immidx">;
  def 32Op1DCondCSRelIdx : EBCInstJMP32ImmIdx<opcode, 1, 1, 1, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("JMP", "32", "cs"), "$op1 @$immidx">;

  def 64UnCondAbsImm : EBCInstJMP64<opcode, 0, 0, 0,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64"), "$imm">;
  def 64CondCCAbsImm : EBCInstJMP64<opcode, 1, 0, 0,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64", "cc"), "$imm">;
  def 64CondCSAbsImm : EBCInstJMP64<opcode, 1, 1, 0,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64", "cs"), "$imm">;
  def 64UnCondRelImm : EBCInstJMP64<opcode, 0, 0, 1,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64"), "$imm">;
  def 64CondCCRelImm : EBCInstJMP64<opcode, 1, 0, 1,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64", "cc"), "$imm">;
  def 64CondCSRelImm : EBCInstJMP64<opcode, 1, 1, 1,
            (outs), (ins GPR:$op1, imm64:$imm),
            !strconcat("JMP", "64", "cs"), "$imm">;
}

multiclass EBCInstCALL<bits<6> opcode> {
  def 32EBCAbsOp1D : EBCInstCALL32<opcode, 0, 0, 0,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "a"), "$op1">;
  def 32NativeAbsOp1D : EBCInstCALL32<opcode, 1, 0, 0,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "EX", "a"), "$op1">;
  def 32EBCRelOp1D : EBCInstCALL32<opcode, 0, 1, 0,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32"), "$op1">;
  def 32NativeRelOp1D : EBCInstCALL32<opcode, 1, 1, 0,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "EX"), "$op1">;

  def 32EBCAbsOp1I : EBCInstCALL32<opcode, 0, 0, 1,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "a"), "@$op1">;
  def 32NativeAbsOp1I : EBCInstCALL32<opcode, 1, 0, 1,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "EX", "a"), "@$op1">;
  def 32EBCRelOp1I : EBCInstCALL32<opcode, 0, 1, 1,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32"), "@$op1">;
  def 32NativeRelOp1I : EBCInstCALL32<opcode, 1, 1, 1,
            (outs), (ins GPR:$op1),
            !strconcat("CALL", "32", "EX"), "@$op1">;

  def 32EBCAbsOp1DImm : EBCInstCALL32ImmIdx<opcode, 0, 0, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("CALL", "32", "a"), "$op1 $immidx">;
  def 32NativeAbsOp1DImm : EBCInstCALL32ImmIdx<opcode, 1, 0, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("CALL", "32", "EX", "a"), "$op1 $immidx">;
  def 32EBCRelOp1DImm : EBCInstCALL32ImmIdx<opcode, 0, 1, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("CALL", "32"), "$op1 $immidx">;
  def 32NativeRelOp1DImm : EBCInstCALL32ImmIdx<opcode, 1, 1, 0,
            (outs), (ins GPR:$op1, imm32:$immidx),
            !strconcat("CALL", "32", "EX"), "$op1 $immidx">;

  def 32EBCAbsOp1DIdx : EBCInstCALL32ImmIdx<opcode, 0, 0, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("CALL", "32", "a"), "@$op1 $immidx">;
  def 32NativeAbsOp1DIdx : EBCInstCALL32ImmIdx<opcode, 1, 0, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("CALL", "32", "EX", "a"), "@$op1 $immidx">;
  def 32EBCRelOp1DIdx : EBCInstCALL32ImmIdx<opcode, 0, 1, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("CALL", "32"), "@$op1 $immidx">;
  def 32NativeRelOp1DIdx : EBCInstCALL32ImmIdx<opcode, 1, 1, 1,
            (outs), (ins GPR:$op1, idx32:$immidx),
            !strconcat("CALL", "32", "EX"), "@$op1 $immidx">;

  def 64EBCImm : EBCInstCALL64<opcode, 0,
            (outs), (ins imm64:$imm),
            !strconcat("CALL", "64", "a"), "$imm">;
  def 64NativeImm : EBCInstCALL64<opcode, 1,
            (outs), (ins imm64:$imm),
            !strconcat("CALL", "64", "EX", "a"), "$imm">;
}

multiclass EBCInstMOVxx<bits<6> opcode, string opcodestr> {
  def Op1DOp2D : EBCInstMOVx<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "$op1, $op2">;
  def Op1IOp2D : EBCInstMOVx<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1, $op2">;
  def Op1DOp2I : EBCInstMOVx<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "$op1, @$op2">;
  def Op1IOp2I : EBCInstMOVx<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1, @$op2">;
}

multiclass EBCInstMOVxw<bits<6> opcode, string opcodestr> {
  defm xw : EBCInstMOVxx<opcode, opcodestr>;
  def xwOp1Op1IOp2D : EBCInstMOVxwOp1<opcode, 0,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2">;
  def xwOp1Op1IOp2I : EBCInstMOVxwOp1<opcode, 1,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2">;
  def xwOp2Op1DOp2D : EBCInstMOVxwOp2<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, $op2 $op2idx">;
  def xwOp2Op1IOp2D : EBCInstMOVxwOp2<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, $op2 $op2idx">;
  def xwOp2Op1DOp2I : EBCInstMOVxwOp2<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, @$op2 $op2idx">;
  def xwOp2Op1IOp2I : EBCInstMOVxwOp2<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, @$op2 $op2idx">;
  def xwOp1Op2Op1IOp2D : EBCInstMOVxwOp1Op2<opcode, 0,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2 $op2idx">;
  def xwOp1Op2Op1IOp2I : EBCInstMOVxwOp1<opcode, 1,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2 $op2idx">;
}

multiclass EBCInstMOVxd<bits<6> opcode, string opcodestr> {
  defm xd : EBCInstMOVxx<opcode, opcodestr>;
  def xdOp1Op1IOp2D : EBCInstMOVxdOp1<opcode, 0,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2">;
  def xdOp1Op1IOp2I : EBCInstMOVxdOp1<opcode, 1,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2">;
  def xdOp2Op1DOp2D : EBCInstMOVxdOp2<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, $op2 $op2idx">;
  def xdOp2Op1IOp2D : EBCInstMOVxdOp2<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, $op2 $op2idx">;
  def xdOp2Op1DOp2I : EBCInstMOVxdOp2<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, @$op2 $op2idx">;
  def xdOp2Op1IOp2I : EBCInstMOVxdOp2<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, @$op2 $op2idx">;
  def xdOp1Op2Op1IOp2D : EBCInstMOVxdOp1Op2<opcode, 0,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2 $op2idx">;
  def xdOp1Op2Op1IOp2I : EBCInstMOVxdOp1<opcode, 1,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2 $op2idx">;
}

multiclass EBCInstMOVxq<bits<6> opcode, string opcodestr> {
  defm xq : EBCInstMOVxx<opcode, opcodestr>;
  def xqOp1Op1IOp2D : EBCInstMOVxqOp1<opcode, 0,
            (outs GPR:$op1, idx64:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2">;
  def xqOp1Op1IOp2I : EBCInstMOVxqOp1<opcode, 1,
            (outs GPR:$op1, idx64:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2">;
  def xqOp2Op1DOp2D : EBCInstMOVxqOp2<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, $op2 $op2idx">;
  def xqOp2Op1IOp2D : EBCInstMOVxqOp2<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, $op2 $op2idx">;
  def xqOp2Op1DOp2I : EBCInstMOVxqOp2<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, @$op2 $op2idx">;
  def xqOp2Op1IOp2I : EBCInstMOVxqOp2<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, @$op2 $op2idx">;
  def xqOp1Op2Op1IOp2D : EBCInstMOVxqOp1Op2<opcode, 0,
            (outs GPR:$op1, idx64:$op1idx), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2 $op2idx">;
  def xqOp1Op2Op1IOp2I : EBCInstMOVxqOp1<opcode, 1,
            (outs GPR:$op1, idx64:$op1idx), (ins GPR:$op2, idx64:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2 $op2idx">;
}

multiclass EBCInstMOVsnw<bits<6> opcode, string opcodestr> {
  defm snw : EBCInstMOVxx<opcode, opcodestr>;
  def snwOp1Op1IOp2D : EBCInstMOVxwOp1<opcode, 0,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2">;
  def snwOp1Op1IOp2I : EBCInstMOVxwOp1<opcode, 1,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2">;
  def snwOp2Op1DOp2D : EBCInstMOVxwOp2<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2, sn16:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, $op2 $op2idx">;
  def snwOp2Op1IOp2D : EBCInstMOVxwOp2<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2, sn16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, $op2 $op2idx">;
  def snwOp2Op1DOp2I : EBCInstMOVxwOp2<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, @$op2 $op2idx">;
  def snwOp2Op1IOp2I : EBCInstMOVxwOp2<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, @$op2 $op2idx">;
  def snwOp1Op2Op1IOp2D : EBCInstMOVxwOp1Op2<opcode, 0,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2, sn16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2 $op2idx">;
  def snwOp1Op2Op1IOp2I : EBCInstMOVxwOp1<opcode, 1,
            (outs GPR:$op1, idx16:$op1idx), (ins GPR:$op2, idx16:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2 $op2idx">;
}

multiclass EBCInstMOVsnd<bits<6> opcode, string opcodestr> {
  defm snd : EBCInstMOVxx<opcode, opcodestr>;
  def sndOp1Op1IOp2D : EBCInstMOVxdOp1<opcode, 0,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2">;
  def sndOp1Op1IOp2I : EBCInstMOVxdOp1<opcode, 1,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2">;
  def sndOp2Op1DOp2D : EBCInstMOVxdOp2<opcode, 0, 0,
            (outs GPR:$op1), (ins GPR:$op2, sn32:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, $op2 $op2idx">;
  def sndOp2Op1IOp2D : EBCInstMOVxdOp2<opcode, 1, 0,
            (outs GPR:$op1), (ins GPR:$op2, sn32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, $op2 $op2idx">;
  def sndOp2Op1DOp2I : EBCInstMOVxdOp2<opcode, 0, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "$op1, @$op2 $op2idx">;
  def sndOp2Op1IOp2I : EBCInstMOVxdOp2<opcode, 1, 1,
            (outs GPR:$op1), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1, @$op2 $op2idx">;
  def sndOp1Op2Op1IOp2D : EBCInstMOVxdOp1Op2<opcode, 0,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2, sn32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, $op2 $op2idx">;
  def sndOp1Op2Op1IOp2I : EBCInstMOVxdOp1<opcode, 1,
            (outs GPR:$op1, idx32:$op1idx), (ins GPR:$op2, idx32:$op2idx),
            !strconcat("MOV", opcodestr), "@$op1 $op1idx, @$op2 $op2idx">;
}

multiclass EBCInstMOVIxx<bits<6> opcode, string opcodestr, bits<2> move> {
  def xwOp1D : EBCInstMOVIxw<opcode, 0, move,
            (outs GPR:$op1), (ins imm16:$imm),
            !strconcat("MOVI", opcodestr), "$op1, $imm">;
  def xwOp1I : EBCInstMOVIxw<opcode, 1, move,
            (outs GPR:$op1), (ins imm16:$imm),
            !strconcat("MOVI", opcodestr), "@$op1, $imm">;
  def xwOp1 : EBCInstMOVIxwOp1<opcode, move,
            (outs GPR:$op1, idx16:$op1idx), (ins imm16:$imm),
            !strconcat("MOVI", opcodestr), "@$op1 $op1idx, $imm">;
  def xdOp1D : EBCInstMOVIxd<opcode, 0, move,
            (outs GPR:$op1), (ins imm32:$imm),
            !strconcat("MOVI", opcodestr), "$op1, $imm">;
  def xdOp1I : EBCInstMOVIxd<opcode, 1, move,
            (outs GPR:$op1), (ins imm32:$imm),
            !strconcat("MOVI", opcodestr), "@$op1, $imm">;
  def xdOp1 : EBCInstMOVIxdOp1<opcode, move,
            (outs GPR:$op1, idx16:$op1idx), (ins imm32:$imm),
            !strconcat("MOVI", opcodestr), "@$op1 $op1idx, $imm">;
  def xqOp1D : EBCInstMOVIxq<opcode, 0, move,
            (outs GPR:$op1), (ins imm64:$imm),
            !strconcat("MOVI", opcodestr), "$op1, $imm">;
  def xqOp1I : EBCInstMOVIxq<opcode, 1, move,
            (outs GPR:$op1), (ins imm64:$imm),
            !strconcat("MOVI", opcodestr), "@$op1, $imm">;
  def xqOp1 : EBCInstMOVIxqOp1<opcode, move,
            (outs GPR:$op1, idx16:$op1idx), (ins imm64:$imm),
            !strconcat("MOVI", opcodestr), "@$op1 $op1idx, $imm">;
}

multiclass EBCInstMOVIn<bits<6> opcode> {
  def xwOp1D : EBCInstMOVIxw<opcode, 0, 0b00,
            (outs GPR:$op1), (ins idx16:$imm),
            !strconcat("MOVIn", "w"), "$op1, $imm">;
  def xwOp1I : EBCInstMOVIxw<opcode, 1, 0b00,
            (outs GPR:$op1), (ins idx16:$imm),
            !strconcat("MOVIn", "w"), "@$op1, $imm">;
  def xwOp1 : EBCInstMOVIxwOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins idx16:$imm),
            !strconcat("MOVIn", "w"), "@$op1 $op1idx, $imm">;
  def xdOp1D : EBCInstMOVIxd<opcode, 0, 0b00,
            (outs GPR:$op1), (ins idx32:$imm),
            !strconcat("MOVIn", "d"), "$op1, $imm">;
  def xdOp1I : EBCInstMOVIxd<opcode, 1, 0b00,
            (outs GPR:$op1), (ins idx32:$imm),
            !strconcat("MOVIn", "d"), "@$op1, $imm">;
  def xdOp1 : EBCInstMOVIxdOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins idx32:$imm),
            !strconcat("MOVIn", "d"), "@$op1 $op1idx, $imm">;
  def xqOp1D : EBCInstMOVIxq<opcode, 0, 0b00,
            (outs GPR:$op1), (ins idx64:$imm),
            !strconcat("MOVIn", "q"), "$op1, $imm">;
  def xqOp1I : EBCInstMOVIxq<opcode, 1, 0b00,
            (outs GPR:$op1), (ins idx64:$imm),
            !strconcat("MOVIn", "q"), "@$op1, $imm">;
  def xqOp1 : EBCInstMOVIxqOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins idx64:$imm),
            !strconcat("MOVIn", "q"), "@$op1 $op1idx, $imm">;
}

multiclass EBCInstMOVREL<bits<6> opcode> {
  def xwOp1D : EBCInstMOVIxw<opcode, 0, 0b00,
            (outs GPR:$op1), (ins imm16:$imm),
            !strconcat("MOVREL", "w"), "$op1, $imm">;
  def xwOp1I : EBCInstMOVIxw<opcode, 1, 0b00,
            (outs GPR:$op1), (ins imm16:$imm),
            !strconcat("MOVREL", "w"), "@$op1, $imm">;
  def xwOp1 : EBCInstMOVIxwOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins imm16:$imm),
            !strconcat("MOVREL", "w"), "@$op1 $op1idx, $imm">;
  def xdOp1D : EBCInstMOVIxd<opcode, 0, 0b00,
            (outs GPR:$op1), (ins imm32:$imm),
            !strconcat("MOVREL", "d"), "$op1, $imm">;
  def xdOp1I : EBCInstMOVIxd<opcode, 1, 0b00,
            (outs GPR:$op1), (ins imm32:$imm),
            !strconcat("MOVREL", "d"), "@$op1, $imm">;
  def xdOp1 : EBCInstMOVIxdOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins imm32:$imm),
            !strconcat("MOVREL", "d"), "@$op1 $op1idx, $imm">;
  def xqOp1D : EBCInstMOVIxq<opcode, 0, 0b00,
            (outs GPR:$op1), (ins imm64:$imm),
            !strconcat("MOVREL", "q"), "$op1, $imm">;
  def xqOp1I : EBCInstMOVIxq<opcode, 1, 0b00,
            (outs GPR:$op1), (ins imm64:$imm),
            !strconcat("MOVREL", "q"), "@$op1, $imm">;
  def xqOp1 : EBCInstMOVIxqOp1<opcode, 0b00,
            (outs GPR:$op1, idx16:$op1idx), (ins imm64:$imm),
            !strconcat("MOVREL", "q"), "@$op1 $op1idx, $imm">;
}

defm POP  : EBCInstPOP<0b101100, "POP">;
defm PUSH : EBCInstPUSH<0b101011, "PUSH">;
defm POPn : EBCInstPOPn<0b110110, "POPn">;
defm PUSH : EBCInstPUSHn<0b110101, "PUSHn">;

defm NOT  : EBCInstArith<0b001010, "NOT">;
defm NEG  : EBCInstArith<0b001011, "NEG">;
defm ADD  : EBCInstArith<0b001100, "ADD">;
defm SUB  : EBCInstArith<0b001101, "SUB">;
defm MUL  : EBCInstArith<0b001110, "MUL">;
defm MULU : EBCInstArith<0b001111, "MULU">;
defm DIV  : EBCInstArith<0b010000, "DIV">;
defm DIVU : EBCInstArith<0b010001, "DIVU">;
defm MOD  : EBCInstArith<0b010010, "MOD">;
defm MODU : EBCInstArith<0b010011, "MODU">;
defm AND  : EBCInstArith<0b010100, "AND">;
defm OR   : EBCInstArith<0b010101, "OR">;
defm XOR  : EBCInstArith<0b010110, "XOR">;
defm SHL  : EBCInstArith<0b010111, "SHL">;
defm SHR  : EBCInstArith<0b011000, "SHR">;
defm ASHR : EBCInstArith<0b011001, "ASHR">;

defm CMPeq   : EBCInstCMP<0b000101, "eq">;
defm CMPlte  : EBCInstCMP<0b000110, "lte">;
defm CMPgte  : EBCInstCMP<0b000111, "gte">;
defm CMPulte : EBCInstCMP<0b001000, "ulte">;
defm CMPugte : EBCInstCMP<0b001001, "ugte">;

defm CMPIeq   : EBCInstCMPI<0b101101, "eq">;
defm CMPIlte  : EBCInstCMPI<0b101110, "lte">;
defm CMPIgte  : EBCInstCMPI<0b101111, "gte">;
defm CMPIulte : EBCInstCMPI<0b110000, "ulte">;
defm CMPIugte : EBCInstCMPI<0b110001, "ugte">;

defm EXTNDB  : EBCInstArith<0b011010, "EXTNDB">;
defm EXTNDW  : EBCInstArith<0b011011, "EXTNDW">;
defm EXTNDD  : EBCInstArith<0b011100, "EXTNDD">;

def JMP8Uncond : EBCInstJMP8<0x000010, 0, 0,
          (outs), (ins imm8:$imm), "JMP8", "$imm">;
def JMP8CondCC : EBCInstJMP8<0x000010, 1, 0,
          (outs), (ins imm8:$imm), !strconcat("JMP8", "cc"), "$imm">;
def JMP8CondCS : EBCInstJMP8<0x000010, 1, 1,
          (outs), (ins imm8:$imm), !strconcat("JMP8", "cs"), "$imm">;

defm JMP : EBCInstJMP<0b000001>;

defm CALL : EBCInstCALL<0b000011>;

defm MOVbw : EBCInstMOVxw<0b011101, "bw">;
defm MOVww : EBCInstMOVxw<0b011110, "ww">;
defm MOVdw : EBCInstMOVxw<0b011111, "dw">;
defm MOVqw : EBCInstMOVxw<0b100000, "qw">;

defm MOVbd : EBCInstMOVxd<0b100001, "bd">;
defm MOVwd : EBCInstMOVxd<0b100010, "wd">;
defm MOVdd : EBCInstMOVxd<0b100011, "dd">;
defm MOVqd : EBCInstMOVxd<0b100100, "qd">;

defm MOVqq : EBCInstMOVxq<0b101000, "qq">;

defm MOVnw : EBCInstMOVxw<0b110010, "nw">;
defm MOVnd : EBCInstMOVxd<0b110011, "nd">;

defm MOVsnw : EBCInstMOVsnw<0b100101, "snw">;
defm MOVsnd : EBCInstMOVsnw<0b100110, "snd">;

defm MOVIbw : EBCInstMOVIxx<0b110111, "bw", 0b00>;
defm MOVIww : EBCInstMOVIxx<0b110111, "ww", 0b01>;
defm MOVIdw : EBCInstMOVIxx<0b110111, "dw", 0b10>;
defm MOVIqw : EBCInstMOVIxx<0b110111, "qw", 0b11>;
defm MOVIbd : EBCInstMOVIxx<0b110111, "bd", 0b00>;
defm MOVIwd : EBCInstMOVIxx<0b110111, "wd", 0b01>;
defm MOVIdd : EBCInstMOVIxx<0b110111, "dd", 0b10>;
defm MOVIqd : EBCInstMOVIxx<0b110111, "qd", 0b11>;
defm MOVIbq : EBCInstMOVIxx<0b110111, "bq", 0b00>;
defm MOVIwq : EBCInstMOVIxx<0b110111, "wq", 0b01>;
defm MOVIdq : EBCInstMOVIxx<0b110111, "dq", 0b10>;
defm MOVIqq : EBCInstMOVIxx<0b110111, "qq", 0b11>;

defm MOVIn : EBCInstMOVIn<0b111000>;

defm MOVREL : EBCInstMOVREL<0b111001>;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
def BREAK : EBCInst16<0b000000,
            (outs), (ins breakcode:$breakcode), "BREAK", "$breakcode"> {
  bits<8> breakcode;

  let Inst{7-0} = breakcode;
}

let isCall = 1 in
def RET : EBCInst16<0b000100,
            (outs), (ins), "RET", "">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def LOADSP : EBCInst16<0b101001,
            (outs FLAGS:$op1), (ins GPR:$op2), "LOADSP", "$op1, $op2"> {
  bits<3> op1;
  bits<3> op2;

  let Inst{2-0} = op1;
  let Inst{6-4} = op2;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def STORESP : EBCInst16<0b101010,
              (outs GPR:$op1), (ins DR:$op2), "STORESP", "$op1, $op2"> {
  bits<3> op1;
  bits<3> op2;

  let Inst{2-0} = op1;
  let Inst{6-4} = op2;
}
