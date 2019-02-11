class EBCInst<dag outs, dag ins,
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
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<16> Inst;
  field bits<16> SoftFail = 0;
  let Size = 2;

  let Inst{13-8} = opcode;
}

class EBCInst32<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;
  let Size = 4;

  let Inst{29-24} = opcode;
}

class EBCInst48<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;
  let Size = 6;

  let Inst{45-40} = opcode;
}

class EBCInst64<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<64> Inst;
  field bits<64> SoftFail = 0;
  let Size = 8;

  let Inst{61-56} = opcode;
}

class EBCInst80<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<80> Inst;
  field bits<80> SoftFail = 0;
  let Size = 10;

  let Inst{77-72} = opcode;
}

class EBCInst96<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<96> Inst;
  field bits<96> SoftFail = 0;
  let Size = 12;

  let Inst{93-88} = opcode;
}

class EBCInst144<bits<6> opcode, dag outs, dag ins,
        string opcodestr, string argstr>
    : EBCInst<outs, ins, opcodestr, argstr, []> {
  field bits<144> Inst;
  field bits<144> SoftFail = 0;
  let Size = 18;

  let Inst{141-136} = opcode;
}

class EBCInst16Op1<bits<6> opcode, bit 64bitOp, bit op1Indirect, 
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;

  let Inst{14} = 64bitOp;
  let Inst{3} = op1Indirect;
  let Inst{2-0} = op1;
}

class EBCInst32Op1<bits<6> opcode, bit 64bitOp, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> immidx;

  let Inst{30} = 64bitOp;
  let Inst{19} = op1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = immidx;
}

class EBCInst16Op1Op2<bits<6> opcode,
        bit 64bitOp, bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op2;
  bits<3> op1;

  let Inst{14} = 64bitOp;
  let Inst{7} = op2Indirect;
  let Inst{6-4} = op2;
  let Inst{3} = op1Indirect;
  let Inst{2-0} = op1;
}

class EBCInst32Op1Op2<bits<6> opcode,
        bit 64bitOp, bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op2;
  bits<3> op1;
  bits<16> immidx;

  let Inst{31} = 1;
  let Inst{30} = 64bitOp;
  let Inst{23} = op2Indirect;
  let Inst{22-20} = op2;
  let Inst{19} = op1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = immidx;
}

class EBCInstCMPI16<bits<6> opcode,
        bit 64bitOp, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> imm;

  let Inst{31} = 0;
  let Inst{30} = 64bitOp;
  let Inst{20} = 0;
  let Inst{19} = op1Indirect;
  let Inst{15-0} = imm;
}

class EBCInstCMPI32<bits<6> opcode,
        bit 64bitOp, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<32> imm;

  let Inst{47} = 1;
  let Inst{46} = 64bitOp;
  let Inst{36} = 0;
  let Inst{35} = op1Indirect;
  let Inst{31-0} = imm;
}

class EBCInstCMPI16Idx<bits<6> opcode,
        bit 64bitOp, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> idx;
  bits<16> imm;

  let Inst{47} = 0;
  let Inst{46} = 64bitOp;
  let Inst{36} = 1;
  let Inst{35} = op1Indirect;
  let Inst{31-16} = idx;
  let Inst{15-0} = imm;
}

class EBCInstCMPI32Idx<bits<6> opcode,
        bit 64bitOp, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst64<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> idx;
  bits<32> imm;

  let Inst{63} = 1;
  let Inst{62} = 64bitOp;
  let Inst{52} = 1;
  let Inst{51} = op1Indirect;
  let Inst{47-32} = idx;
  let Inst{31-0} = imm;
}

class EBCInstJMP8<bits<6> opcode,
        bit CondJmp, bit JmpIfCS,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<8> imm;

  let Inst{15} = CondJmp;
  let Inst{14} = JmpIfCS;
  let Inst{7-0} = imm;
}

class EBCInstJMP32<bits<6> opcode,
        bit CondJmp, bit JmpIfCS, bit RelAddr, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;

  let Inst{15} = 0;
  let Inst{14} = 0;
  let Inst{7} = CondJmp;
  let Inst{6} = JmpIfCS;
  let Inst{5} = 0;
  let Inst{4} = RelAddr;
  let Inst{3} = op1Indirect;
  let Inst{2-0} = op1;
}

class EBCInstJMP32ImmIdx<bits<6> opcode,
        bit CondJmp, bit JmpIfCS, bit RelAddr, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<32> immidx;

  let Inst{47} = 1;
  let Inst{46} = 0;
  let Inst{39} = CondJmp;
  let Inst{38} = JmpIfCS;
  let Inst{37} = 0;
  let Inst{36} = RelAddr;
  let Inst{35} = op1Indirect;
  let Inst{34-32} = op1;
  let Inst{31-0} = immidx;
}

class EBCInstJMP64<bits<6> opcode,
        bit CondJmp, bit JmpIfCS, bit RelAddr,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<64> imm;

  let Inst{79} = 1;
  let Inst{78} = 1;
  let Inst{71} = CondJmp;
  let Inst{70} = JmpIfCS;
  let Inst{69} = 0;
  let Inst{68} = RelAddr;
  let Inst{63-0} = imm;
}

class EBCInstCALL32<bits<6> opcode,
        bit ToNative, bit RelAddr, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;

  let Inst{15} = 0;
  let Inst{14} = 0;
  let Inst{5} = ToNative;
  let Inst{4} = RelAddr;
  let Inst{3} = op1Indirect;
  let Inst{2-0} = op1;
}

class EBCInstCALL32ImmIdx<bits<6> opcode,
        bit ToNative, bit RelAddr, bit op1Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<32> immidx;

  let Inst{47} = 1;
  let Inst{46} = 0;
  let Inst{37} = ToNative;
  let Inst{36} = RelAddr;
  let Inst{35} = op1Indirect;
  let Inst{34-32} = op1;
  let Inst{31-0} = immidx;
}

class EBCInstCALL64<bits<6> opcode,
        bit ToNative,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<64> imm;

  let Inst{69} = ToNative;
  let Inst{63-0} = imm;
}

class EBCInstMOVx<bits<6> opcode,
        bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst16<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;

  let Inst{15} = 0;
  let Inst{14} = 0;
  let Inst{7} = op2Indirect;
  let Inst{6-4} = op2;
  let Inst{3} = op1Indirect;
  let Inst{2-0} = op1;
}

class EBCInstMOVxwOp1<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<16> op1idx;

  let Inst{31} = 1;
  let Inst{30} = 0;
  let Inst{23} = op2Indirect;
  let Inst{22-20} = op2;
  let Inst{19} = 1;
  let Inst{18-16} = op1;
  let Inst{15-0} = op1idx;
}

class EBCInstMOVxwOp2<bits<6> opcode,
        bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<16> op2idx;

  let Inst{31} = 0;
  let Inst{30} = 1;
  let Inst{23} = op2Indirect;
  let Inst{22-20} = op2;
  let Inst{19} = op1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = op2idx;
}

class EBCInstMOVxwOp1Op2<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<16> op1idx;
  bits<16> op2idx;

  let Inst{47} = 1;
  let Inst{46} = 1;
  let Inst{39} = op2Indirect;
  let Inst{38-36} = op2;
  let Inst{35} = 1;
  let Inst{34-32} = op1;
  let Inst{31-16} = op1idx;
  let Inst{15-0} = op2idx;
}

class EBCInstMOVxdOp1<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<32> op1idx;

  let Inst{47} = 1;
  let Inst{46} = 0;
  let Inst{39} = op2Indirect;
  let Inst{38-36} = op2;
  let Inst{35} = 1;
  let Inst{34-32} = op1;
  let Inst{31-0} = op1idx;
}

class EBCInstMOVxdOp2<bits<6> opcode,
        bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<32> op2idx;

  let Inst{47} = 0;
  let Inst{46} = 1;
  let Inst{39} = op2Indirect;
  let Inst{38-36} = op2;
  let Inst{35} = op1Indirect;
  let Inst{34-32} = op1;
  let Inst{31-0} = op2idx;
}

class EBCInstMOVxdOp1Op2<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<32> op1idx;
  bits<32> op2idx;

  let Inst{79} = 1;
  let Inst{78} = 1;
  let Inst{71} = op2Indirect;
  let Inst{70-68} = op2;
  let Inst{67} = 1;
  let Inst{66-64} = op1;
  let Inst{63-32} = op1idx;
  let Inst{31-0} = op2idx;
}

class EBCInstMOVxqOp1<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<64> op1idx;

  let Inst{79} = 1;
  let Inst{78} = 0;
  let Inst{71} = op2Indirect;
  let Inst{70-68} = op2;
  let Inst{67} = 1;
  let Inst{66-64} = op1;
  let Inst{63-0} = op1idx;
}

class EBCInstMOVxqOp2<bits<6> opcode,
        bit op1Indirect, bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<64> op2idx;

  let Inst{79} = 1;
  let Inst{78} = 0;
  let Inst{71} = op2Indirect;
  let Inst{70-68} = op2;
  let Inst{67} = op1Indirect;
  let Inst{66-64} = op1;
  let Inst{63-0} = op2idx;
}

class EBCInstMOVxqOp1Op2<bits<6> opcode,
        bit op2Indirect,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst144<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<3> op2;
  bits<64> op1idx;
  bits<64> op2idx;

  let Inst{143} = 1;
  let Inst{142} = 1;
  let Inst{135} = op2Indirect;
  let Inst{134-132} = op2;
  let Inst{131} = 1;
  let Inst{130-128} = op1;
  let Inst{127-64} = op1idx;
  let Inst{63-0} = op2idx;
}

class EBCInstMOVIxw<bits<6> opcode,
        bit op1Indirect, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst32<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> imm;

  let Inst{31-30} = 0b01;
  let Inst{22} = 0;
  let Inst{21-20} = move;
  let Inst{19} = op1Indirect;
  let Inst{18-16} = op1;
  let Inst{15-0} = imm;
}

class EBCInstMOVIxwOp1<bits<6> opcode, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<16> imm;
  bits<16> op1idx;
  
  let Inst{47-46} = 0b01;
  let Inst{38} = 1;
  let Inst{37-36} = move;
  let Inst{35} = 1;
  let Inst{34-32} = op1;
  let Inst{31-16} = op1idx;
  let Inst{15-0} = imm;
}

class EBCInstMOVIxd<bits<6> opcode,
        bit op1Indirect, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst48<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<32> imm;

  let Inst{47-46} = 0b10;
  let Inst{38} = 0;
  let Inst{37-36} = move;
  let Inst{35} = op1Indirect;
  let Inst{34-32} = op1;
  let Inst{31-0} = imm;
}

class EBCInstMOVIxdOp1<bits<6> opcode, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst64<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<32> imm;
  bits<16> op1idx;
  
  let Inst{63-62} = 0b01;
  let Inst{54} = 1;
  let Inst{53-52} = move;
  let Inst{51} = 1;
  let Inst{50-48} = op1;
  let Inst{47-32} = op1idx;
  let Inst{31-0} = imm;
}

class EBCInstMOVIxq<bits<6> opcode,
        bit op1Indirect, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst80<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<64> imm;

  let Inst{79-78} = 0b11;
  let Inst{70} = 0;
  let Inst{69-68} = move;
  let Inst{67} = op1Indirect;
  let Inst{66-64} = op1;
  let Inst{63-0} = imm;
}

class EBCInstMOVIxqOp1<bits<6> opcode, bits<2> move,
        dag outs, dag ins, string opcodestr, string argstr>
    : EBCInst96<opcode, outs, ins, opcodestr, argstr> {
  bits<3> op1;
  bits<64> imm;
  bits<16> op1idx;
  
  let Inst{95-94} = 0b11;
  let Inst{86} = 1;
  let Inst{85-84} = move;
  let Inst{83} = 1;
  let Inst{82-80} = op1;
  let Inst{79-64} = op1idx;
  let Inst{63-0} = imm;
}
