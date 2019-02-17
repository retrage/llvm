//===-- EBCInstrFormats.td - EBC Instruction Formats ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class EBCInst<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr, list<dag> pattern>
    : Instruction {
  let Namespace = "EBC";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;
}

class EBCInst16<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<opcode, outs, ins, opcodestr, argstr, []> {
  field bits<16> Inst;
  field bits<16> SoftFail = 0;
  let Size = 2;

  let Inst{13-8} = opcode;
}

class EBCInst32<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<opcode, outs, ins, opcodestr, argstr, []> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;
  let Size = 4;

  let Inst{29-24} = opcode;
}

class EBCInst16Op1Op2<bits<6> opcode,
        bit is64, bit isOp1Indirect, bit isOp2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;

  let Inst{15} = 0; // Immediate/Index absent
  let Inst{14} = is64;
  let Inst{7} = isOp2Indirect;
  let Inst{6-4} = op2;
  let Inst{3} = isOp1Indirect;
  let Inst{2-0} = op1;
}

class EBCInst16Op1Op2Imm<bits<6> opcode,
        bit is64, bit isOp1Indirect, bit isOp2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<16> imm;

  let Inst{31} = 1; // Immediate/Index present
  let Inst{30} = is64;
  let Inst{23} = isOp2Indirect;
  let Inst{22-20} = op2;
  let Inst{19} = isOp1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = imm;
}

class EBCInst16Op1Op2Idx<bits<6> opcode,
        bit is64, bit isOp1Indirect, bit isOp2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<16> nidx;
  bits<16> cidx;
  bits<16> idx;

  let Inst{31} = 1; // Immediate/Index present
  let Inst{30} = is64;
  let Inst{23} = isOp2Indirect;
  let Inst{22-20} = op2;
  let Inst{19} = isOp1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = idx;
}
