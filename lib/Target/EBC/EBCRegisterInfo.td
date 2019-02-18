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
def r0 : EBCGPReg<0, "r0">;
def r1 : EBCGPReg<1, "r1">;
def r2 : EBCGPReg<2, "r2">;
def r3 : EBCGPReg<3, "r3">;
def r4 : EBCGPReg<4, "r4">;
def r5 : EBCGPReg<5, "r5">;
def r6 : EBCGPReg<6, "r6">;
def r7 : EBCGPReg<7, "r7">;

// Dedicated VM Register
def flags : EBCDReg<0, "flags">;
def ip    : EBCDReg<1, "ip">;

// Register classes
def GPR : RegisterClass<"EBC", [i64], 64, (add (sequence "r%u", 0, 7))>;
def DR  : RegisterClass<"EBC", [i64], 64, (add flags, ip)>;
def FR  : RegisterClass<"EBC", [i64], 64, (add flags)>;
