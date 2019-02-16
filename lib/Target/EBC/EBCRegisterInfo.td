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
def R0 : EBCGPReg<0, "R0">;
def R1 : EBCGPReg<1, "R1">;
def R2 : EBCGPReg<2, "R2">;
def R3 : EBCGPReg<3, "R3">;
def R4 : EBCGPReg<4, "R4">;
def R5 : EBCGPReg<5, "R5">;
def R6 : EBCGPReg<6, "R6">;
def R7 : EBCGPReg<7, "R7">;

// Dedicated VM Register
def FLAGS : EBCDReg<0, "FLAGS">;
def IP    : EBCDReg<1, "IP">;

// Register classes
def GPR : RegisterClass<"EBC", [i64], 64, (add (sequence "R%u", 0, 7))>;
def DR : RegisterClass<"EBC", [i64], 64, (add FLAGS, IP)>;
