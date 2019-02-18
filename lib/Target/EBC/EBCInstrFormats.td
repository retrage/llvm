//===-- EBCInstrFormats.td - EBC Instruction Formats ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

class EBCInst<dag outs, dag ins, string opcodestr, string argstr,
              list<dag> pattern>
    : Instruction {
  bits<6> Opcode = 0;

  let Namespace = "EBC";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;
}

class Pseudo<dag outs, dag ins, list<dag> pattern>
    : EBCInst<outs, ins, "", "", pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

class EBCInst16<bits<6> opcode, dag outs, dag ins,
                string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<16> Inst;
  field bits<16> SoftFail = 0;
  let Size = 2;

  let Opcode = opcode;

  let Inst{5-0} = Opcode;
}

class EBCInst1Op<bits<6> opcode,
                bit is64Bit, bit Op1Indirect,
                dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> Op1;

  let Inst{7} = is64Bit;
  let Inst{10-8} = Op1;
  let Inst{11} = Op1Indirect;
}

class EBCInst2Op<bits<6> opcode,
                bit is64Bit, bit Op1Indirect, bit Op2Indirect,
                dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> Op1;
  bits<3> Op2;

  let Inst{7} = is64Bit;
  let Inst{10-8} = Op1;
  let Inst{14-12} = Op2;
  let Inst{11} = Op1Indirect;
  let Inst{15} = Op2Indirect;
}
