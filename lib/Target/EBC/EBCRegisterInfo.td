//===-- EBCRegisterInfo.td - EBC Register defs --------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the EBC register files
//===----------------------------------------------------------------------===//

// General Purpose VM Register class
class EBCGPReg<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let Namespace = "EBC";
}

// Dedicated VM Register class
class EBCDReg<bits<3> Enc, string n> : Register<n> {
  let HWEncoding{2-0} = Enc;
  let Namespace = "EBC";
}

// General Purpose VM Register
foreach Index = 0-7 in {
  def r # Index : EBCGPReg<Index, "r" # Index>;
}

// Dedicated VM Register
def flags : EBCDReg<0, "flags">;
def ip    : EBCDReg<1, "ip">;

// Register classes
def GPR : RegisterClass<"EBC", [i16, i32, i64], 64, (add (sequence "r%u", 1, 7), r0)>;
def DR  : RegisterClass<"EBC", [i64], 64, (add flags, ip)>;
def FR  : RegisterClass<"EBC", [i64], 64, (add flags)>;
