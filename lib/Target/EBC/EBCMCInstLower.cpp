//===-- EBCMCInstLower.cpp - Convert EBC MachineInstr to an MCInst ------=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower EBC MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "EBC.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static MCOperand lowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym,
                                    const AsmPrinter &AP) {
  MCContext &Ctx = AP.OutContext;

  const MCExpr *ME = MCSymbolRefExpr::create(Sym, Ctx);

  if (!MO.isJTI() && MO.getOffset())
    ME = MCBinaryExpr::createAdd(
        ME, MCConstantExpr::create(MO.getOffset(), Ctx), Ctx);

  return MCOperand::createExpr(ME);
}

bool llvm::LowerEBCMachineOperandToMCOperand(const MachineOperand &MO,
                                             MCOperand &MCOp,
                                             const AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    report_fatal_error("LowerEBCMachineOperandToMCOperand: unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_GlobalAddress:
    MCOp = lowerSymbolOperand(MO, AP.getSymbol(MO.getGlobal()), AP);
    break;
  }
  return true;
}

void llvm::LowerEBCMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                        const AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerEBCMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
