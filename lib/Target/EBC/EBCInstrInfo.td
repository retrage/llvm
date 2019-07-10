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
// EBC specific DAG Nodes.
//===----------------------------------------------------------------------===//

def SDT_EBCCall : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;
def SDT_EBCCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i64>, SDTCisVT<1, i64>]>;
def SDT_EBCCallSeqEnd : SDCallSeqEnd<[SDTCisVT<0, i64>, SDTCisVT<1, i64>]>;
def SDT_EBCBrcond : SDTypeProfile<0, 1,
                                  [SDTCisVT<0, OtherVT>]>;
def SDT_EBCCmp : SDTypeProfile<0, 2,
                               [SDTCisSameAs<0, 1>]>;
def SDT_EBCSelectCC : SDTypeProfile<1, 6, [SDTCisSameAs<1, 2>,
                                           SDTCisSameAs<0, 5>,
                                           SDTCisVT<4, i64>,
                                           SDTCisSameAs<5, 6>]>;


def EBCcall : SDNode<"EBCISD::CALL", SDT_EBCCall,
                      [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                       SDNPVariadic]>;
def EBCcallseq_start : SDNode<"ISD::CALLSEQ_START", SDT_EBCCallSeqStart,
                              [SDNPHasChain, SDNPOutGlue]>;
def EBCcallseq_end : SDNode<"ISD::CALLSEQ_END", SDT_EBCCallSeqEnd,
                            [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
def EBCret_flag : SDNode<"EBCISD::RET_FLAG", SDTNone,
                         [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

def EBCbrcond : SDNode<"EBCISD::BRCOND", SDT_EBCBrcond,
                        [SDNPHasChain, SDNPInGlue]>;
def EBCcmp : SDNode<"EBCISD::CMP", SDT_EBCCmp, [SDNPOutGlue]>;
def EBCselectCC : SDNode<"EBCISD::SELECT_CC", SDT_EBCSelectCC,
                         [SDNPInGlue]>;

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

class AsmOperand<string prefix, int width> : AsmOperandClass {
  let Name = prefix # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

class BreakCodeAsmOperand<int width> : AsmOperand<"BreakCode", width> {}

class ImmAsmOperand<int width> : AsmOperand<"Imm", width> {}

class IdxNAsmOperand<int width> : AsmOperand<"IdxN", width> {}

class IdxCAsmOperand<int width> : AsmOperand<"IdxC", width> {}

let OperandNamespace = "EBC" in {

let OperandType = "OPERAND_BREAKCODE" in
def breakcode : Operand<i64> {
  let ParserMatchClass = BreakCodeAsmOperand<8>;
}

let OperandType = "OPERAND_IMM8" in
def imm8 : Operand<i64>, ImmLeaf<i64, [{return isInt<8>(Imm);}]> {
  let ParserMatchClass = ImmAsmOperand<8>;
  let MCOperandPredicate = [{
    int8_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<8>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

let OperandType = "OPERAND_IMM16" in
def imm16 : Operand<i64>, ImmLeaf<i64, [{return isInt<16>(Imm);}]> {
  let ParserMatchClass = ImmAsmOperand<16>;
  let MCOperandPredicate = [{
    int16_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<16>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

let OperandType = "OPERAND_IMM32" in
def imm32 : Operand<i64>, ImmLeaf<i64, [{return isInt<32>(Imm);}]> {
  let ParserMatchClass = ImmAsmOperand<32>;
  let MCOperandPredicate = [{
    int32_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<32>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

let OperandType = "OPERAND_IMM64" in
def imm64 : Operand<i64>, ImmLeaf<i64, [{return isInt<64>(Imm);}]> {
  let ParserMatchClass = ImmAsmOperand<64>;
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<64>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

let OperandType = "OPERAND_JMP64" in
def jmp64 : Operand<OtherVT> {
  let ParserMatchClass = ImmAsmOperand<64>;
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<64>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

let OperandType = "OPERAND_IDXN16" in
def idxn16 : Operand<i64> {
  let ParserMatchClass = IdxNAsmOperand<16>;
}

let OperandType = "OPERAND_IDXC16" in
def idxc16 : Operand<i64> {
  let ParserMatchClass = IdxCAsmOperand<16>;
}

let OperandType = "OPERAND_IDXN32" in
def idxn32 : Operand<i64> {
  let ParserMatchClass = IdxNAsmOperand<32>;
}

let OperandType = "OPERAND_IDXC32" in
def idxc32 : Operand<i64> {
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

// Note: TSFlags represent following attributes
// TSFlags{7}: 1 if the operand 1 is indirect
// TSFlags{6}: 1 if the instruction has immediate/index
// TSFlags{5}: 1 if the instruction is relative
// TSFlags{4}: 1 if the instruction is native
// TSFlags{3-2}: 0b00: imm8, 0b01: imm16, 0b10: imm32, 0b11: imm64
// TSFlags{1}: 1 if the fixup is pcrel
// TSFlags{0}: 1 if the instruction has fixup

class EBCCALL32<bits<6> opcode,
                bit hasImmIdx, bit isNative,
                bit isRel, bit Op1Indirect,
                dag outs, dag ins, dag immins, dag idxins,
                string op1str, string immstr, string idxstr>
      : EBCInst1Op<opcode, hasImmIdx, 0, Op1Indirect, outs,
          !cond(!eq(hasImmIdx, 0) : ins,
                !eq(!and(hasImmIdx, Op1Indirect), 0) : !con(ins, immins),
                !eq(!and(hasImmIdx, Op1Indirect), 1) : !con(ins, idxins)),
          "call32"
        # !if(isNative, "ex", "")
        # !if(isRel, "", "a"),
          !if(Op1Indirect, "@", "")
        # op1str
        # !if(hasImmIdx, " ", "")
        # !cond(!eq(hasImmIdx, 0) : "",
                !eq(!and(hasImmIdx, Op1Indirect), 0) : immstr,
                !eq(!and(hasImmIdx, Op1Indirect), 1) : idxstr)> {
  let CodeSize = !cond(!eq(hasImmIdx, 0) : 2,
                       !eq(hasImmIdx, 1) : 6);
  let mayLoad = !if(Op1Indirect, 1, 0);
  let Inst{13} = isNative;
  let Inst{12} = isRel;
  let TSFlags{7} = Op1Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = isRel;
  let TSFlags{4} = isNative;
  let TSFlags{3-2} = 0b10;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op1Indirect, 0)), 1, 0);
}

class EBCCALL64<bits<6> opcode,
                bit isNative, bit isRel,
                dag outs, dag absins, dag relins,
                string immstr>
      : EBCInst16<opcode, outs, !if(isRel, relins, absins),
          "call64"
        # !if(isNative, "ex", "")
        # !if(isRel, "", "a"),
          immstr, []> {
  let CodeSize = 10;
  let mayLoad = 0;
  let Inst{7} = 1;
  let Inst{6} = 1;
  let Inst{13} = isNative;
  let Inst{12} = isRel;
  let TSFlags{7} = 0;
  let TSFlags{6} = 0;
  let TSFlags{5} = isRel;
  let TSFlags{4} = isNative;
  let TSFlags{3-2} = 0b11;
  let TSFlags{1} = isRel;
  let TSFlags{0} = 1;
}

class EBCJMP32<bits<6> opcode,
                bit hasImmIdx, bit isCond,
                bit isCS, bit isRel, bit Op1Indirect,
                dag outs, dag ins, dag immins, dag idxins,
                string op1str, string immstr, string idxstr>
      : EBCInst1Op<opcode, hasImmIdx, 0, Op1Indirect, outs,
          !cond(!eq(hasImmIdx, 0) : ins,
                !eq(!and(hasImmIdx, Op1Indirect), 0) : !con(ins, immins),
                !eq(!and(hasImmIdx, Op1Indirect), 1) : !con(ins, idxins)),
          "jmp32"
        # !cond(!eq(isCond, 0) : "",
                !and(isCond, !eq(isCS, 0)) : "cc",
                !and(isCond, isCS) : "cs")
        # !if(isRel, "", "a"),
          !if(Op1Indirect, "@", "")
        # op1str
        # !if(hasImmIdx, " ", "")
        # !cond(!eq(hasImmIdx, 0) : "",
                !eq(!and(hasImmIdx, Op1Indirect), 0) : immstr,
                !eq(!and(hasImmIdx, Op1Indirect), 1) : idxstr)> {
  let CodeSize = !cond(!eq(hasImmIdx, 0) : 2,
                       !eq(hasImmIdx, 1) : 6);
  let mayLoad = !if(!and(Op1Indirect, !eq(hasImmIdx, 0)), 1, 0);
  let Inst{15} = isCond;
  let Inst{14} = isCS;
  let Inst{12} = isRel;
  let TSFlags{7} = Op1Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = isRel;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b10;
  let TSFlags{1} = isRel;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op1Indirect, 0)), 1, 0);
}

class EBCJMP64<bits<6> opcode,
                bit isCond, bit isCS, bit isRel,
                dag outs, dag ins, dag immins,
                string immstr, list<dag> pattern>
      : EBCInst16<opcode, outs, !con(ins, immins),
          "jmp64"
        # !cond(!eq(isCond, 0) : "",
                !and(isCond, !eq(isCS, 0)) : "cc",
                !and(isCond, isCS) : "cs")
        # !if(isRel, "", "a"),
          immstr, pattern> {
  let CodeSize = 10;
  let mayLoad = 0;
  let Inst{7} = 1;
  let Inst{6} = 1;
  let Inst{15} = isCond;
  let Inst{14} = isCS;
  let Inst{12} = isRel;
  let TSFlags{7} = 0;
  let TSFlags{6} = 0;
  let TSFlags{5} = isRel;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b11;
  let TSFlags{1} = isRel;
  let TSFlags{0} = 1;
}

class EBCJMP8<bits<6> opcode, bit isCond, bit isCS,
                dag outs, dag ins, string immstr>
        : EBCInst8<opcode, outs, ins,
            "jmp8"
          # !cond(!eq(isCond, 0) : "",
                  !and(isCond, !eq(isCS, 0)) : "cc",
                  !and(isCond, isCS) : "cs"),
            immstr, []> {
  let CodeSize = 2;
  let Inst{7} = isCond;
  let Inst{6} = isCS;
  let TSFlags{7} = 0;
  let TSFlags{6} = 0;
  let TSFlags{5} = 1;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b00;
  let TSFlags{1} = 1;
  let TSFlags{0} = 1;
}

class EBCPUSHPOP<bits<6> opcode, bit hasImmIdx, bit is64Bit, bit Op1Indirect,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str, string immstr, string idxstr>
      : EBCInst1Op<opcode, hasImmIdx, is64Bit, Op1Indirect, outs,
          !cond(!eq(hasImmIdx, 0) : ins,
                !eq(!and(hasImmIdx, Op1Indirect), 0) : !con(ins, immins),
                !eq(!and(hasImmIdx, Op1Indirect), 1) : !con(ins, idxins)),
          opcodestr
        # !if(is64Bit, "64", "32"),
          !if(Op1Indirect, "@", "")
        # op1str
        # !if(hasImmIdx, " ", "")
        # !cond(!eq(hasImmIdx, 0) : "",
                !eq(!and(hasImmIdx, Op1Indirect), 0) : immstr,
                !eq(!and(hasImmIdx, Op1Indirect), 1) : idxstr)> {
  let CodeSize = !if(hasImmIdx, 4, 2);
  let mayLoad = !if(!and(Op1Indirect, hasImmIdx), 1, 0);
  let TSFlags{7} = Op1Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b01;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op1Indirect, 0)), 1, 0);
}

class EBCPUSHnPOPn<bits<6> opcode, bit hasImmIdx, bit Op1Indirect,
                dag outs, dag ins, dag immins, dag idxins,
                string opcodestr, string op1str, string immstr, string idxstr>
      : EBCInst1Op<opcode, hasImmIdx, 0, Op1Indirect, outs,
          !cond(!eq(hasImmIdx, 0) : ins,
                !eq(!and(hasImmIdx, Op1Indirect), 0) : !con(ins, immins),
                !eq(!and(hasImmIdx, Op1Indirect), 1) : !con(ins, idxins)),
          opcodestr,
          !if(Op1Indirect, "@", "")
        # op1str
        # !if(hasImmIdx, " ", "")
        # !cond(!eq(hasImmIdx, 0) : "",
                !eq(!and(hasImmIdx, Op1Indirect), 0) : immstr,
                !eq(!and(hasImmIdx, Op1Indirect), 1) : idxstr)> {
  let CodeSize = !if(hasImmIdx, 4, 2);
  let mayLoad = !if(!and(Op1Indirect, hasImmIdx), 1, 0);
  let TSFlags{7} = Op1Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b01;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op1Indirect, 0)), 1, 0);
}

class EBCALUBase<bits<6> opcode, bit hasImmIdx, bit is64Bit,
          bit Op1Indirect, bit Op2Indirect,
          dag outs, dag ins, dag immins, dag idxins,
          string opcodestr, string op1str, string op2str,
          string immstr, string idxstr>
      : EBCInst2Op<opcode, hasImmIdx, is64Bit, Op1Indirect, Op2Indirect, outs,
        !cond(!eq(hasImmIdx, 0) : ins,
              !eq(!and(hasImmIdx, Op2Indirect), 0) : !con(ins, immins),
              !eq(!and(hasImmIdx, Op2Indirect), 1) : !con(ins, idxins)),
        opcodestr # !if(is64Bit, "64", "32"),
        !if(Op1Indirect, "@", "") # op1str # ", "
      # !if(Op2Indirect, "@", "") # op2str # !if(hasImmIdx, " ", "")
      # !cond(!eq(hasImmIdx, 0) : "",
              !eq(!and(hasImmIdx, Op2Indirect), 0) : immstr,
              !eq(!and(hasImmIdx, Op2Indirect), 1) : idxstr),
        []> {
  bits<3> dst;
  let CodeSize = !if(hasImmIdx, 4, 2);
  let mayLoad = !if(Op2Indirect, 1, 0);
  let mayStore = !if(Op1Indirect, 1, 0);
  let TSFlags{7} = Op2Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b01;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op2Indirect, 0)), 1, 0);
}

class EBCCMPBase<bits<6> opcode, bit hasImmIdx, bit is64Bit, bit Op2Indirect,
          dag outs, dag ins, dag immins, dag idxins,
          string opsuffix, string op1str, string op2str,
          string immstr, string idxstr, list<dag> pattern>
      : EBCInst2Op<opcode, hasImmIdx, is64Bit, 0, Op2Indirect, outs,
          !cond(!eq(hasImmIdx, 0) : ins,
                !eq(!and(hasImmIdx, Op2Indirect), 0) : !con(ins, immins),
                !eq(!and(hasImmIdx, Op2Indirect), 1) : !con(ins, idxins)),
          "cmp" # !if(is64Bit, "64", "32") # opsuffix,
          op1str # ", " # !if(Op2Indirect, "@", "") # op2str
        # !cond(!eq(hasImmIdx, 0) : "",
                !and(!eq(hasImmIdx, 1), !eq(Op2Indirect, 0)) : " " # immstr,
                !and(!eq(hasImmIdx, 1), !eq(Op2Indirect, 1)) : " " # idxstr),
          pattern> {
  let CodeSize = !if(hasImmIdx, 4, 2);
  let mayLoad = !if(Op2Indirect, 1, 0);
  let TSFlags{7} = Op2Indirect;
  let TSFlags{6} = hasImmIdx;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = 0b01;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasImmIdx, !eq(Op2Indirect, 0)), 1, 0);
}

class EBCCMPIBase<bits<6> opcode,
          bit hasOp1Idx, bit is64Bit, bit immlen, bit Op1Indirect,
          dag outs, dag ins, dag immins, dag idxins,
          string opsuffix, string op1str, string immstr, string idxstr>
      : EBCInst16<opcode, outs,
          !if(hasOp1Idx, !con(ins, idxins, immins), !con(ins, immins)),
          "cmpi" # !if(is64Bit, "64", "32") # !if(immlen, "d", "w")# opsuffix,
          !if(Op1Indirect, "@", "") # op1str
        # !if(hasOp1Idx, " " # idxstr, "") # ", " # immstr, []> {
  bits<3> op1;

  let Inst{7} = immlen;
  let Inst{6} = is64Bit;
  let Inst{12} = hasOp1Idx;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;
  let TSFlags{7} = 0;
  let TSFlags{6} = 1;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = !if(immlen, 0b01, 0b10);
  let TSFlags{1} = 0;
  let TSFlags{0} = 1;

  let CodeSize = !cond(!and(!eq(hasOp1Idx, 0), !eq(immlen, 0)) : 4,
                   !and(!eq(hasOp1Idx, 0), !eq(immlen, 1)) : 6,
                   !and(!eq(hasOp1Idx, 1), !eq(immlen, 0)) : 6,
                   !and(!eq(hasOp1Idx, 1), !eq(immlen, 1)) : 8);
  let mayLoad = !if(Op1Indirect, 1, 0);
}

class EBCMOVBase<bits<6> opcode, bits<2> idxlen, bits<2> movlen,
            bit hasOp1Idx, bit hasOp2Idx, bit Op1Indirect, bit Op2Indirect,
            dag op1outs, dag op2outs, dag op1ins, dag op2ins,
            dag op1idxins, dag op2idxins,
            string op1str, string op2str, string op1idxstr, string op2idxstr>
      : EBCInst<opcode, !con(op1outs, op2outs),
          !cond(!and(!eq(hasOp1Idx, 0), !eq(hasOp2Idx, 0))
                : !con(op1ins, op2ins),
                !and(hasOp1Idx, !eq(hasOp2Idx, 0))
                : !con(op1ins, op1idxins, op2ins),
                !and(!eq(hasOp1Idx, 0), hasOp2Idx)
                : !con(op1ins, op2ins, op2idxins),
                !and(hasOp1Idx, hasOp2Idx)
                : !con(op1ins, op1idxins, op2ins, op2idxins)),
          "mov"
        # !cond(!eq(movlen, 0b00) : "b", !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d", !eq(movlen, 0b11) : "q")
        # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d",
                !eq(idxlen, 0b11) : "q"),
          !if(Op1Indirect, "@", "") # op1str
        # !if(hasOp1Idx, " ", "") # !if(hasOp1Idx, op1idxstr, "")
        # ", "
        # !if(Op2Indirect, "@", "") # op2str
        # !if(hasOp2Idx, " ", "") # !if(hasOp2Idx, op2idxstr, ""), []> {
  field bits<16> Inst;
  field bits<16> SoftFail = 0;
  bits<3> op1;
  bits<3> op2;

  let Size = 2;
  let Opcode = !add(opcode, !shl(idxlen, 2), movlen);

  let Inst{7} = hasOp1Idx;
  let Inst{6} = hasOp2Idx;
  let Inst{5-0} = Opcode;
  let Inst{15} = Op2Indirect;
  let Inst{14-12} = op2;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;

  let CodeSize = !add(2, !if(hasOp1Idx, !shl(1, idxlen), 0),
                     !if(hasOp2Idx, !shl(1, idxlen), 0));
  let mayLoad = !if(Op2Indirect, 1, 0);
  let mayStore = !if(Op1Indirect, 1, 0);
}

class EBCMOVIBase<bits<6> opcode, bits<2> immlen, bits<2> movlen,
            bit hasOp1Idx, bit Op1Indirect,
            dag outs, dag ins, dag op1idxins, dag immins,
            string op1str, string immstr, string op1idxstr>
      : EBCInst16<opcode, outs,
            !cond(!eq(hasOp1Idx, 0) : !con(ins, immins),
                  !eq(hasOp1Idx, 1) : !con(ins, op1idxins, immins)),
            "movi"
          # !cond(!eq(movlen, 0b00) : "b", !eq(movlen, 0b01) : "w",
                  !eq(movlen, 0b10) : "d", !eq(movlen, 0b11) : "q")
          # !cond(!eq(immlen, 0b01) : "w",
                  !eq(immlen, 0b10) : "d", !eq(immlen, 0b11) : "q"),
            !if(Op1Indirect, "@", "") # op1str
          # !if(hasOp1Idx, " " # op1idxstr, "") # ", " # immstr, []> {
  bits<3> op1;

  let Inst{7-6} = immlen;
  let Inst{14} = hasOp1Idx;
  let Inst{13-12} = movlen;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;
  let TSFlags{7} = 0;
  let TSFlags{6} = 0;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = immlen;
  let TSFlags{1} = 0;
  let TSFlags{0} = 1;

  let CodeSize = !add(2, !if(hasOp1Idx, 2, 0), !shl(1, immlen));
  let mayLoad = 0;
  let mayStore = !if(Op1Indirect, 1, 0);
}

class EBCMOVRELBase<bits<6> opcode, bits<2> immlen,
              bit hasOp1Idx, bit Op1Indirect,
              dag outs, dag ins, dag op1idxins, dag immins,
              string op1str, string immstr, string op1idxstr>
      : EBCInst16<opcode, outs,
              !cond(!eq(hasOp1Idx, 0) : !con(ins, immins),
                    !eq(hasOp1Idx, 1) : !con(ins, op1idxins, immins)),
              "movrel"
            # !cond(!eq(immlen, 0b01) : "w", !eq(immlen, 0b10) : "d",
                    !eq(immlen, 0b11) : "q"),
              !if(Op1Indirect, "@", "") # op1str
            # !if(hasOp1Idx, " " # op1idxstr, "") # ", " # immstr, []> {
  bits<3> op1;

  let Inst{7-6} = immlen;
  let Inst{14} = hasOp1Idx;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;
  let TSFlags{7} = 0;
  let TSFlags{6} = 0;
  let TSFlags{5} = 1;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = immlen;
  let TSFlags{1} = 1;
  let TSFlags{0} = 1;

  let CodeSize = !add(2, !if(hasOp1Idx, 2, 0), !shl(1, immlen));
  let mayLoad = 0;
  let mayStore = !if(Op1Indirect, 1, 0);
  let TSFlags{8} = hasOp1Idx;
  let TSFlags{7-6} = immlen;
}

class EBCMOVnBase<bits<6> opcode, bits<2> idxlen,
            bit hasOp1Idx, bit hasOp2Idx,
            bit Op1Indirect, bit Op2Indirect,
            dag outs, dag ins, dag op1idxins, dag op2idxins,
            string op1str, string op2str,
            string op1idxstr, string op2idxstr>
      : EBCInst16<opcode, outs,
            !cond(!and(!eq(hasOp1Idx, 0), !eq(hasOp2Idx, 0)) : ins,
                  !and(hasOp1Idx, !eq(hasOp2Idx, 0)) : !con(ins, op1idxins),
                  !and(!eq(hasOp1Idx, 0), hasOp2Idx) : !con(ins, op2idxins),
                  !and(hasOp1Idx, hasOp2Idx) : !con(ins, op1idxins, op2idxins)),
            "movn" # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d"),
            !if(Op1Indirect, "@", "") # op1str
          # !if(hasOp1Idx, " " # op1idxstr, "") # ", "
          # !if(Op2Indirect, "@", "") # op2str
          # !if(hasOp2Idx, " " # op2idxstr, ""), []> {
  bits<3> op1;
  bits<3> op2;

  let Inst{7} = hasOp1Idx;
  let Inst{6} = hasOp2Idx;
  let Inst{15} = Op2Indirect;
  let Inst{14-12} = op2;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;

  let CodeSize = !add(2, !if(hasOp1Idx, !shl(1, idxlen), 0), !if(hasOp2Idx, !shl(1, idxlen), 0));
  let mayLoad = !if(Op2Indirect, 1, 0);
  let mayStore = !if(Op1Indirect, 1, 0);
}

class EBCMOVsnBase<bits<6> opcode, bits<2> idxlen,
            bit hasOp1Idx, bit hasOp2Idx,
            bit Op1Indirect, bit Op2Indirect,
            dag outs, dag ins, dag op1idxins, dag op2idxins, dag op2immins,
            string op1str, string op2str,
            string op1idxstr, string op2idxstr, string op2immstr>
      : EBCInst16<opcode, outs,
            !cond(!and(!eq(hasOp1Idx, 0), !eq(hasOp2Idx, 0)) : ins,
                  !and(hasOp1Idx, !eq(hasOp2Idx, 0))
                  : !con(ins, op1idxins),
                  !and(!eq(hasOp1Idx, 0), hasOp2Idx, !eq(Op2Indirect, 0))
                  : !con(ins, op2immins),
                  !and(!eq(hasOp1Idx, 0), hasOp2Idx, Op2Indirect)
                  : !con(ins, op2idxins),
                  !and(hasOp1Idx, hasOp2Idx, !eq(Op2Indirect, 0))
                  : !con(ins, op1idxins, op2immins),
                  !and(hasOp1Idx, hasOp2Idx, Op2Indirect)
                  : !con(ins, op1idxins, op2idxins)),
            "movsn" # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d"),
            !if(Op1Indirect, "@", "") # op1str
          # !if(hasOp1Idx, " " # op1idxstr, "") # ", "
          # !if(Op2Indirect, "@", "") # op2str
          # !cond(!eq(hasOp2Idx, 0) : "",
                  !and(hasOp2Idx, !eq(Op2Indirect, 0)) : " " # op2immstr,
                  !and(hasOp2Idx, Op2Indirect) : " " # op2idxstr), []> {
  bits<3> op1;
  bits<3> op2;

  let Inst{7} = hasOp1Idx;
  let Inst{6} = hasOp2Idx;
  let Inst{15} = Op2Indirect;
  let Inst{14-12} = op2;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;
  let TSFlags{7} = Op2Indirect;
  let TSFlags{6} = hasOp2Idx;
  let TSFlags{5} = 0;
  let TSFlags{4} = 0;
  let TSFlags{3-2} = idxlen;
  let TSFlags{1} = 0;
  let TSFlags{0} = !if(!and(hasOp2Idx, !eq(Op2Indirect, 0)), 1, 0);

  let CodeSize = !add(2, !if(hasOp1Idx, !shl(1, idxlen), 0), !if(hasOp2Idx, !shl(1, idxlen), 0));
  let mayLoad = !if(Op2Indirect, 1, 0);
  let mayStore = !if(Op1Indirect, 1, 0);
}

class EBCMOVInBase<bits<6> opcode, bits<2> idxlen,
            bit hasOp1Idx, bit Op1Indirect,
            dag outs, dag ins, dag op1idxins, dag op2idxins,
            string op1str, string op1idxstr, string op2idxstr>
      : EBCInst16<opcode, outs,
            !cond(!eq(hasOp1Idx, 0) : !con(ins, op2idxins),
                  !eq(hasOp1Idx, 1) : !con(ins, op1idxins, op2idxins)),
            "movin"
          # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d",
                  !eq(idxlen, 0b11) : "q"),
            !if(Op1Indirect, "@", "") # op1str
          # !if(hasOp1Idx, " " # op1idxstr, "") # ", " # op2idxstr, []> {
  bits<3> op1;

  let Inst{7-6} = idxlen;
  let Inst{14} = hasOp1Idx;
  let Inst{11} = Op1Indirect;
  let Inst{10-8} = op1;

  let CodeSize = !add(2, !if(hasOp1Idx, 2, 0), !shl(1, idxlen));
  let mayLoad = 0;
  let mayStore = !if(Op1Indirect, 1, 0);
}

multiclass EBCALU<bits<6> opcode, string opcodestr> {
  foreach hasImmIdx = [0b0, 0b1] in {
    foreach is64Bit = [0b0, 0b1] in {
      foreach Op1Indirect = [0b0, 0b1] in {
        foreach Op2Indirect = [0b0, 0b1] in
        def !if(is64Bit, "64", "32")
          # !if(Op1Indirect, "Op1I", "Op1D")
          # !if(Op2Indirect, "Op2I", "Op2D")
          # !cond(!eq(hasImmIdx, 0) : "",
                  !eq(!and(hasImmIdx, Op2Indirect), 0) : "Imm",
                  !eq(!and(hasImmIdx, Op2Indirect), 1) : "Idx")
          : EBCALUBase<opcode, hasImmIdx, is64Bit, Op1Indirect, Op2Indirect,
            (outs GPR:$dst), (ins GPR:$op1, GPR:$op2),
            (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
            opcodestr, "$op1", "$op2", "$imm", "(${idxn},${idxc})">;
      }
    }
  }
}

let Defs = [flags] in
multiclass EBCCMP<bits<6> opcode, string opsuffix> {
  foreach hasImmIdx = [0b0, 0b1] in {
    foreach is64Bit = [0b0, 0b1] in {
      foreach Op2Indirect = [0b0, 0b1] in
      def !if(is64Bit, "64", "32")
        # !if(Op2Indirect, "Op2I", "Op2D")
        # !if(hasImmIdx, !if(Op2Indirect, "Idx", "Imm"), "")
        : EBCCMPBase<opcode, hasImmIdx, is64Bit, Op2Indirect,
          (outs), (ins GPR:$op1, GPR:$op2),
          (ins imm16:$imm), (ins idxn16:$idxn, idxc16:$idxc),
          opsuffix, "$op1", "$op2", "$imm", "(${idxn},${idxc})",
          [(EBCcmp i64:$op1, i64:$op2), (implicit flags)]>;
    }
  }
}

multiclass EBCCMPI<bits<6> opcode, string opsuffix> {
  foreach is64Bit = [0b0, 0b1] in {
    foreach immlen = [0b0, 0b1] in {
      foreach Op1Indirect = [0b0, 0b1] in {
        foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in
        def !if(is64Bit, "64", "32")
          # !if(immlen, "d", "w")
          # !if(Op1Indirect, "Op1I", "Op1D")
          # !if(hasOp1Idx, "Idx", "")
          : EBCCMPIBase<opcode, hasOp1Idx, is64Bit, immlen, Op1Indirect,
            (outs), (ins GPR:$op1),
            !cond(!eq(immlen, 0) : (ins imm16:$imm),
                  !eq(immlen, 1) : (ins imm32:$imm)),
            (ins idxn16:$idxn, idxc16:$idxc),
            opsuffix, "$op1", "$imm", "(${idxn},${idxc})">;
      }
    }
  }
}

multiclass EBCMOV<bits<6> opcode, bits<2> idxlen, bits<2> movlen> {
  foreach Op1Indirect = [0b0, 0b1] in {
    foreach Op2Indirect = [0b0, 0b1] in {
      foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in {
        foreach hasOp2Idx = [0b0, 0b1] in
        def !cond(!eq(movlen, 0b00) : "b", !eq(movlen, 0b01) : "w",
                  !eq(movlen, 0b10) : "d", !eq(movlen, 0b11) : "q")
          # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d",
                  !eq(idxlen, 0b11) : "q")
          # !if(Op1Indirect, "Op1I", "Op1D") # !if(hasOp1Idx, "Idx", "")
          # !if(Op2Indirect, "Op2I", "Op2D") # !if(hasOp2Idx, "Idx", "")
          : EBCMOVBase<opcode, idxlen, movlen,
            hasOp1Idx, hasOp2Idx, Op1Indirect, Op2Indirect,
            !if(Op1Indirect, (outs), (outs GPR:$op1)), (outs),
            !if(Op1Indirect, (ins GPR:$op1), (ins)), (ins GPR:$op2),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op1idxn, idxc16:$op1idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op1idxn, idxc32:$op1idxc),
                  !eq(idxlen, 0b11) : (ins idxn64:$op1idxn, idxc64:$op1idxc)),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc),
                  !eq(idxlen, 0b11) : (ins idxn64:$op2idxn, idxc64:$op2idxc)),
            "$op1", "$op2",
            "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let isTrap = 1 in
def BREAK : EBCInst8<0b000000, (outs), (ins breakcode:$code),
                "break", "$code", []>;

let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def RET : EBCInst16<0b000100, (outs), (ins), "ret", "", [(EBCret_flag)]>;

def LOADSP : EBCInst2Op<0b101001, 0, 0, 0, 0, (outs FR:$op1), (ins GPR:$op2),
                "loadsp", "$op1, $op2", []>;

def STORESP : EBCInst2Op<0b101010, 0, 0, 0, 0, (outs GPR:$op1), (ins DR:$op2),
                "storesp", "$op1, $op2", []>;

let isCall = 1 in {
foreach hasImmIdx = [0b0, 0b1] in {
  foreach isNative = [0b0, 0b1] in {
    foreach isRel = [0b0, 0b1] in {
      foreach Op1Indirect = [0b0, 0b1] in
        def "CALL32"
          # !if(Op1Indirect, "Op1I", "Op1D") # !if(isNative, "Native", "EBC")
          # !if(isRel, "Rel", "Abs")
          # !cond(!eq(hasImmIdx, 0) : "",
                  !eq(!and(hasImmIdx, Op1Indirect), 0) : "Imm",
                  !eq(!and(hasImmIdx, Op1Indirect), 1) : "Idx")
            : EBCCALL32<0b000011,
                  hasImmIdx, isNative, isRel, Op1Indirect,
                  (outs), (ins GPR:$op1),
                  (ins imm32:$imm), (ins idxn32:$idxn, idxc32:$idxc),
                  "$op1", "$imm", "(${idxn},${idxc})">;
    }
  }
}
foreach isNative = [0b0, 0b1] in {
  foreach isRel = [0b0, 0b1] in
  def "CALL64"
    # !if(isNative, "Native", "EBC")
    # !if(isRel, "Rel", "Abs")
    # "Imm"
      : EBCCALL64<0b000011, isNative, isRel,
                  (outs), (ins imm64:$imm), (ins imm64:$imm), "$imm">;
}
} // isCall = 1

let hasSideEffects = 1, mayStore = 0, isBranch = 1 in {
foreach Op1Indirect = [0b0, 0b1] in {
  foreach hasImmIdx = [0b0, 0b1] in {
    foreach isCond = [0b0, 0b1] in {
      foreach isCS = !if(isCond, [0b0, 0b1], [0b0]) in {
        foreach isRel = [0b0, 0b1] in
        def "JMP32"
          # !cond(!eq(isCond, 0) : "Uncond",
                  !and(isCond, !eq(isCS, 0)) : "CC",
                  !and(isCond, !eq(isCS, 1)) : "CS")
          # !if(isRel, "Rel", "Abs")
          # !if(Op1Indirect, "Op1I", "Op1D")
          # !if(hasImmIdx, !if(Op1Indirect, "Idx", "Imm"), "")
            : EBCJMP32<0b000001, hasImmIdx, isCond, isCS, isRel, Op1Indirect,
                    (outs), (ins GPR:$op1), (ins imm32:$imm),
                    (ins idxn32:$idxn, idxc32:$idxc),
                    "$op1", "$imm", "(${idxn},${idxc})">;
      }
    }
  }
}

let Uses = [flags] in
foreach isCond = [0b0, 0b1] in {
  foreach isCS = !if(isCond, [0b0, 0b1], [0b0]) in {
    foreach isRel = [0b0, 0b1] in
    def "JMP64"
      # !cond(!eq(isCond, 0) : "Uncond",
              !and(isCond, !eq(isCS, 0)) : "CC",
              !and(isCond, !eq(isCS, 1)) : "CS")
      # !if(isRel, "Rel", "Abs")
      # "Imm"
        : EBCJMP64<0b000001, isCond, isCS, isRel,
                (outs), (ins), (ins jmp64:$imm), "$imm",
                !if(isCond,
                    [(EBCbrcond bb:$imm), (implicit flags)],
                    [(EBCbrcond bb:$imm)])>;
  }
}

foreach isCond = [0b0, 0b1] in {
  foreach isCS = !if(isCond, [0b0, 0b1], [0b0]) in
  def "JMP8"
    # !cond(!eq(isCond, 0) : "Uncond",
            !and(isCond, !eq(isCS, 0)) : "CC",
            !and(isCond, !eq(isCS, 1)) : "CS")
      : EBCJMP8<0b000010, isCond, isCS, (outs), (ins imm8:$imm), "$imm">;
}
} // hasSideEffects = 1, mayStore = 0, isBranch = 1

let hasSideEffects = 0, mayStore = 0 in {
foreach hasImmIdx = [0b0, 0b1] in {
  foreach is64Bit = [0b0, 0b1] in {
    foreach Op1Indirect = [0b0, 0b1] in
    def "POP"
      # !if(is64Bit, "64", "32") 
      # !if(Op1Indirect, "Op1I", "Op1D")
      # !cond(!eq(hasImmIdx, 0) : "",
              !and(hasImmIdx, !eq(Op1Indirect, 0)) : "Imm",
              !and(hasImmIdx, !eq(Op1Indirect, 1)) : "Idx")
        : EBCPUSHPOP<0b101100, hasImmIdx, is64Bit, Op1Indirect,
              (outs GPR:$op1), (ins), (ins imm16:$imm),
              (ins idxn16:$idxn, idxc16:$idxc),
              "pop", "$op1", "$imm", "(${idxn},${idxc})">;
  }
}
} // hasSideEffects = 0, mayStore = 0

let hasSideEffects = 0, mayStore = 1 in {
foreach hasImmIdx = [0b0, 0b1] in {
  foreach is64Bit = [0b0, 0b1] in {
    foreach Op1Indirect = [0b0, 0b1] in
    def "PUSH"
      # !if(is64Bit, "64", "32") 
      # !if(Op1Indirect, "Op1I", "Op1D")
      # !cond(!eq(hasImmIdx, 0) : "",
              !and(hasImmIdx, !eq(Op1Indirect, 0)) : "Imm",
              !and(hasImmIdx, !eq(Op1Indirect, 1)) : "Idx")
        : EBCPUSHPOP<0b101011, hasImmIdx, is64Bit, Op1Indirect,
              (outs), (ins GPR:$op1), (ins imm16:$imm),
              (ins idxn16:$idxn, idxc16:$idxc),
              "push", "$op1", "$imm", "(${idxn},${idxc})">;
  }
}
} // hasSideEffects = 0, mayStore = 1

let hasSideEffects = 0, mayStore = 0 in {
foreach hasImmIdx = [0b0, 0b1] in {
  foreach Op1Indirect = [0b0, 0b1] in
  def "POPn"
    # !if(Op1Indirect, "Op1I", "Op1D")
    # !cond(!eq(hasImmIdx, 0) : "",
            !and(hasImmIdx, !eq(Op1Indirect, 0)) : "Imm",
            !and(hasImmIdx, !eq(Op1Indirect, 1)) : "Idx")
        : EBCPUSHnPOPn<0b110110, hasImmIdx, Op1Indirect,
            (outs GPR:$op1), (ins), (ins imm16:$imm),
            (ins idxn16:$idxn, idxc16:$idxc),
            "popn", "$op1", "$imm", "(${idxn},${idxc})">;
}
} // hasSideEffects = 0, mayStore = 0

let hasSideEffects = 0, mayStore = 1 in {
foreach hasImmIdx = [0b0, 0b1] in {
  foreach Op1Indirect = [0b0, 0b1] in
  def "PUSHn"
    # !if(Op1Indirect, "Op1I", "Op1D")
    # !cond(!eq(hasImmIdx, 0) : "",
            !and(hasImmIdx, !eq(Op1Indirect, 0)) : "Imm",
            !and(hasImmIdx, !eq(Op1Indirect, 1)) : "Idx")
        : EBCPUSHnPOPn<0b110101, hasImmIdx, Op1Indirect,
            (outs), (ins GPR:$op1), (ins imm16:$imm),
            (ins idxn16:$idxn, idxc16:$idxc),
            "pushn", "$op1", "$imm", "(${idxn},${idxc})">;
}
} // hasSideEffects = 0, mayStore = 1

let hasSideEffects = 0, Constraints = "$dst = $op1" in {
defm NOT    : EBCALU<0b001010, "not">;
defm NEG    : EBCALU<0b001011, "neg">;
defm ADD    : EBCALU<0b001100, "add">;
defm SUB    : EBCALU<0b001101, "sub">;
defm MUL    : EBCALU<0b001110, "mul">;
defm MULU   : EBCALU<0b001111, "mulu">;
defm DIV    : EBCALU<0b010000, "div">;
defm DIVU   : EBCALU<0b010001, "divu">;
defm MOD    : EBCALU<0b010010, "mod">;
defm MODU   : EBCALU<0b010011, "modu">;
defm AND    : EBCALU<0b010100, "and">;
defm OR     : EBCALU<0b010101, "or">;
defm XOR    : EBCALU<0b010110, "xor">;
defm SHL    : EBCALU<0b010111, "shl">;
defm SHR    : EBCALU<0b011000, "shr">;
defm ASHR   : EBCALU<0b011001, "ashr">;

defm EXTNDB : EBCALU<0b011010, "extndb">;
defm EXTNDW : EBCALU<0b011011, "extndw">;
defm EXTNDD : EBCALU<0b011100, "extndd">;
} // hasSideEffects = 0, Constraints = "$dst = $op1"

defm CMPeq    : EBCCMP<0b000101, "eq">;
defm CMPlte   : EBCCMP<0b000110, "lte">;
defm CMPgte   : EBCCMP<0b000111, "gte">;
defm CMPulte  : EBCCMP<0b001000, "ulte">;
defm CMPugte  : EBCCMP<0b001001, "ugte">;

defm CMPIeq   : EBCCMPI<0b101101, "eq">;
defm CMPIlte  : EBCCMPI<0b101110, "lte">;
defm CMPIgte  : EBCCMPI<0b101111, "gte">;
defm CMPIulte : EBCCMPI<0b110000, "ulte">;
defm CMPIugte : EBCCMPI<0b110001, "ugte">;

foreach idxlen = [0b01, 0b10, 0b11] in {
  foreach movlen = !if(!eq(idxlen, 0b11), [0b11], [0b00, 0b01, 0b10, 0b11]) in
  defm MOV    : EBCMOV<0b011001, idxlen, movlen>;
}

foreach immlen = [0b01, 0b10, 0b11] in {
  foreach movlen = [0b00, 0b01, 0b10, 0b11] in {
    foreach Op1Indirect = [0b0, 0b1] in {
      foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in {
      def "MOVI"
        # !cond(!eq(movlen, 0b00) : "b", !eq(movlen, 0b01) : "w",
                !eq(movlen, 0b10) : "d", !eq(movlen, 0b11) : "q")
        # !cond(!eq(immlen, 0b01) : "w", !eq(immlen, 0b10) : "d",
                !eq(immlen, 0b11) : "q")
        # !if(Op1Indirect, "Op1I", "Op1D")
        # !if(hasOp1Idx, "Idx", "")
           : EBCMOVIBase<0b110111, immlen, movlen, hasOp1Idx, Op1Indirect,
                  (outs GPR:$op1), (ins),
                  (ins idxn16:$idxn, idxc16:$idxc),
                  !cond(!eq(immlen, 0b01) : (ins imm16:$imm),
                        !eq(immlen, 0b10) : (ins imm32:$imm),
                        !eq(immlen, 0b11) : (ins imm64:$imm)),
                  "$op1", "$imm", "(${idxn},${idxc})">;
      }
    }
  }
}

foreach immlen = [0b01, 0b10, 0b11] in {
  foreach Op1Indirect = [0b0, 0b1] in {
    foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in {
    def "MOVREL"
      # !cond(!eq(immlen, 0b01) : "w", !eq(immlen, 0b10) : "d",
              !eq(immlen, 0b11) : "q")
      # !if(Op1Indirect, "Op1I", "Op1D")
      # !if(hasOp1Idx, "Idx", "")
        : EBCMOVRELBase<0b111001, immlen, hasOp1Idx, Op1Indirect,
                  (outs GPR:$op1), (ins),
                  (ins idxn16:$idxn, idxc16:$idxc),
                  !cond(!eq(immlen, 0b01) : (ins imm16:$imm),
                        !eq(immlen, 0b10) : (ins imm32:$imm),
                        !eq(immlen, 0b11) : (ins imm64:$imm)),
                  "$op1", "$imm", "(${idxn},${idxc})">;
    }
  }
}

foreach idxlen = [0b01, 0b10] in {
  foreach Op1Indirect = [0b0, 0b1] in {
    foreach Op2Indirect = [0b0, 0b1] in {
      foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in {
        foreach hasOp2Idx = [0b0, 0b1] in
        def "MOVn"
          # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d")
          # !if(Op1Indirect, "Op1I", "Op1D")
          # !if(hasOp1Idx, "Idx", "")
          # !if(Op2Indirect, "Op2I", "Op2D")
          # !if(hasOp2Idx, "Idx", "")
            : EBCMOVnBase<!cond(!eq(idxlen, 0b01) : 0b110010,
                                !eq(idxlen, 0b10) : 0b110011),
            idxlen, hasOp1Idx, hasOp2Idx, Op1Indirect, Op2Indirect,
            (outs GPR:$op1), (ins GPR:$op2),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op1idxn, idxc16:$op1idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op1idxn, idxc32:$op1idxc)),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc)),
            "$op1", "$op2",  
            "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
      }
    }
  }
}

foreach idxlen = [0b01, 0b10] in {
  foreach Op1Indirect = [0b0, 0b1] in {
    foreach Op2Indirect = [0b0, 0b1] in {
      foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in {
        foreach hasOp2Idx = [0b0, 0b1] in
        def "MOVsn"
          # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d")
          # !if(Op1Indirect, "Op1I", "Op1D")
          # !if(hasOp1Idx, "Idx", "")
          # !if(Op2Indirect, "Op2I", "Op2D")
          # !if(hasOp2Idx, !if(Op2Indirect, "Idx", "Imm"), "")
            : EBCMOVsnBase<!cond(!eq(idxlen, 0b01) : 0b100101,
                                 !eq(idxlen, 0b10) : 0b100110),
            idxlen, hasOp1Idx, hasOp2Idx, Op1Indirect, Op2Indirect,
            (outs GPR:$op1), (ins GPR:$op2),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op1idxn, idxc16:$op1idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op1idxn, idxc32:$op1idxc)),
            !cond(!eq(idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
                  !eq(idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc)),
            !cond(!eq(idxlen, 0b01) : (ins imm16:$op2imm),
                  !eq(idxlen, 0b10) : (ins imm32:$op2imm)),
            "$op1", "$op2",  
            "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})", "$op2imm">;
      }
    }
  }
}

foreach idxlen = [0b01, 0b10, 0b11] in {
  foreach Op1Indirect = [0b0, 0b1] in {
    foreach hasOp1Idx = !if(Op1Indirect, [0b0, 0b1], [0b0]) in
    def "MOVIn"
      # !cond(!eq(idxlen, 0b01) : "w", !eq(idxlen, 0b10) : "d",
              !eq(idxlen, 0b11) : "q")
      # !if(Op1Indirect, "Op1I", "Op1D")
      # !if(hasOp1Idx, "Idx", "")
        : EBCMOVInBase<0b111000, idxlen, hasOp1Idx, Op1Indirect,
        (outs GPR:$op1), (ins), (ins idxn16:$op1idxn, idxc16:$op1idxc),
        !cond(!eq(idxlen, 0b01) : (ins idxn16:$op2idxn, idxc16:$op2idxc),
              !eq(idxlen, 0b10) : (ins idxn32:$op2idxn, idxc32:$op2idxc),
              !eq(idxlen, 0b11) : (ins idxn64:$op2idxn, idxc64:$op2idxc)),
        "$op1", "(${op1idxn},${op1idxc})", "(${op2idxn},${op2idxc})">;
  }
}

//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//
// Naming convention: For 'generic' pattern classes, we use the naming
// convention PatTy1Ty2. For pattern classes which offer a more complex
// expension, prefix the class name, e.g. BccPat.
//===----------------------------------------------------------------------===//

/// Generic pattern classes

class PatGprGpr<SDPatternOperator OpNode, EBCInst Inst>
    : Pat<(OpNode GPR:$op1, GPR:$op2), (Inst GPR:$op1, GPR:$op2)>;
class PatGprGprImm<SDPatternOperator OpNode, EBCInst Inst>
    : Pat<(OpNode GPR:$op1, (add GPR:$op2, imm16:$imm)),
          (Inst GPR:$op1, GPR:$op2, imm16:$imm)>;

/// Simple arithmetic operations

def : PatGprGpr<add, ADD64Op1DOp2D>;
def : PatGprGpr<sub, SUB64Op1DOp2D>;
def : PatGprGpr<mul, MUL64Op1DOp2D>;
def : PatGprGpr<sdiv, DIV64Op1DOp2D>;
def : PatGprGpr<udiv, DIVU64Op1DOp2D>;
def : PatGprGpr<srem, MOD64Op1DOp2D>;
def : PatGprGpr<urem, MODU64Op1DOp2D>;
def : PatGprGpr<shl, SHL64Op1DOp2D>;
def : PatGprGpr<srl, SHR64Op1DOp2D>;
def : PatGprGpr<sra, ASHR64Op1DOp2D>;
def : PatGprGpr<and, AND64Op1DOp2D>;
def : PatGprGpr<or, OR64Op1DOp2D>;
def : PatGprGpr<xor, XOR64Op1DOp2D>;

def : PatGprGprImm<add, ADD64Op1DOp2DImm>;
def : PatGprGprImm<sub, SUB64Op1DOp2DImm>;
def : PatGprGprImm<mul, MUL64Op1DOp2DImm>;
def : PatGprGprImm<sdiv, DIV64Op1DOp2DImm>;
def : PatGprGprImm<udiv, DIVU64Op1DOp2DImm>;
def : PatGprGprImm<srem, MOD64Op1DOp2DImm>;
def : PatGprGprImm<urem, MODU64Op1DOp2DImm>;
def : PatGprGprImm<shl, SHL64Op1DOp2DImm>;
def : PatGprGprImm<srl, SHR64Op1DOp2DImm>;
def : PatGprGprImm<sra, ASHR64Op1DOp2DImm>;
def : PatGprGprImm<and, AND64Op1DOp2DImm>;
def : PatGprGprImm<or, OR64Op1DOp2DImm>;
def : PatGprGprImm<xor, XOR64Op1DOp2DImm>;

/// Immediates

def : Pat<(imm16:$imm), (MOVIwwOp1D imm16:$imm)>;
def : Pat<(imm32:$imm), (MOVIddOp1D imm32:$imm)>;
def : Pat<(imm64:$imm), (MOVIqqOp1D imm64:$imm)>;

/// Loads

class ExtLdPat<PatFrag LoadOp, EBCInst MOVOp, EBCInst EXTNDOp>
    : Pat<(LoadOp GPR:$op2), (EXTNDOp GPR:$op2, (MOVOp GPR:$op2))>;

class LdPat<PatFrag LoadOp, EBCInst MOVOp>
    : Pat<(LoadOp GPR:$op2), (MOVOp GPR:$op2)>;

def : ExtLdPat<sextloadi8, MOVbwOp1DOp2I, EXTNDB64Op1DOp2D>;
def : ExtLdPat<extloadi8, MOVbwOp1DOp2I, EXTNDB64Op1DOp2D>;
def : ExtLdPat<sextloadi16, MOVwwOp1DOp2I, EXTNDW64Op1DOp2D>;
def : ExtLdPat<extloadi16, MOVwwOp1DOp2I, EXTNDW64Op1DOp2D>;
def : ExtLdPat<sextloadi32, MOVdwOp1DOp2I, EXTNDD64Op1DOp2D>;
def : ExtLdPat<extloadi32, MOVdwOp1DOp2I, EXTNDD64Op1DOp2D>;
def : LdPat<load, MOVqqOp1DOp2I>;
def : LdPat<zextloadi8, MOVbwOp1DOp2I>;
def : LdPat<zextloadi16, MOVwwOp1DOp2I>;
def : LdPat<zextloadi32, MOVdwOp1DOp2I>;

/// Stores

class StPat<PatFrag StoreOp, EBCInst MOVOp>
    : Pat<(StoreOp GPR:$op2, GPR:$op1), (MOVOp GPR:$op1, GPR:$op2)>;

def : StPat<truncstorei8, MOVbwOp1IOp2D>;
def : StPat<truncstorei16, MOVwwOp1IOp2D>;
def : StPat<truncstorei32, MOVdwOp1IOp2D>;
def : StPat<store, MOVqqOp1IOp2D>;

/// Branches and jumps

def PseudoBR : Pseudo<(outs), (ins jmp64:$imm), [(br bb:$imm)]>,
               PseudoInstExpansion<(JMP64UncondAbsImm jmp64:$imm)>;

let isBarrier = 1, isBranch = 1, isIndirectBranch = 1, isTerminator = 1 in
def PseudoBRIND : Pseudo<(outs), (ins GPR:$op1), []>,
                  PseudoInstExpansion<(JMP32UncondAbsOp1I GPR:$op1)>;

let usesCustomInserter = 1 in
def PseudoSELECT
    : Pseudo<(outs GPR:$dst),
             (ins GPR:$lhs, GPR:$rhs, imm64:$imm, imm64:$cs,
              GPR:$src, GPR:$src2),
             [(set GPR:$dst, (EBCselectCC GPR:$lhs, GPR:$rhs,
               imm64:$imm, imm64:$cs, GPR:$src, GPR:$src2))]>;

def : Pat<(brind GPR:$op1), (JMP32UncondAbsOp1I GPR:$op1)>;

/// Calls

def : Pat<(EBCcall tglobaladdr:$imm), (CALL64EBCRelImm tglobaladdr:$imm)>;
def : Pat<(EBCcall texternalsym:$imm), (CALL64EBCRelImm texternalsym:$imm)>;
def : Pat<(EBCcall imm:$imm), (CALL64EBCAbsImm imm64:$imm)>;
def : Pat<(EBCcall GPR:$op1), (CALL32Op1DEBCAbs GPR:$op1)>;
def : Pat<(EBCcall (load GPR:$op1)), (CALL32Op1IEBCAbs GPR:$op1)>;

/// Other pseudo-instructions

// Pessimistically assume the stack pointer will be clobbered
let Defs = [r0], Uses = [r0] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
                              [(EBCcallseq_start timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
                              [(EBCcallseq_end timm:$amt1, timm:$amt2)]>;
} // Defs = [r0], Uses = [r0]
