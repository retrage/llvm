//===-- EBCAsmParser.cpp - Parse EBC assembly to MCInst instructions --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EBCMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/TargetRegistry.h"

#include <cstdint>

using namespace llvm;

namespace {
struct EBCOperand;

class EBCAsmParser : public MCTargetAsmParser {
  SMLoc getLoc() const { return getParser().getTok().getLoc(); }

  template<uint8_t N>
  bool checkIndex(const MCOperand &NMO, const MCOperand &CMO, StringRef &Msg);
  bool validateIndex(const MCInst &MI, uint64_t &ErrorInfo, StringRef &Msg);
  bool generateImmOutOfRangeError(OperandVector &Operands, uint64_t ErrorInfo,
                                  int64_t Lower, int64_t Upper, Twine Msg);

  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                              OperandVector &Operands, MCStreamer &Out,
                              uint64_t &ErrorInfo,
                              bool MatchingInlineAsm) override;

  bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc) override;

  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

  bool ParseDirective(AsmToken DirectiveID) override;

// Auto-generated instruction matching functions
#define GET_ASSEMBLER_HEADER
#include "EBCGenAsmMatcher.inc"

  OperandMatchResultTy parseRegister(OperandVector &Operands);
  OperandMatchResultTy parseImmediate(OperandVector &Operands);
  OperandMatchResultTy parseIndirectReg(OperandVector &Operands);
  OperandMatchResultTy parseIndex(OperandVector &Operands);

  bool parseOperand(OperandVector &Operands);

public:
  enum EBCMatchResultTy {
    Match_Dummy = FIRST_TARGET_MATCH_RESULT_TY,
#define GET_OPERAND_DIAGNOSTIC_TYPES
#include "EBCGenAsmMatcher.inc"
#undef GET_OPERAND_DIAGNOSTIC_TYPES
  };

  EBCAsmParser(const MCSubtargetInfo &STI, MCAsmParser &Parser,
              const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, STI, MII) {
  }
};

/// EBCOperand
struct EBCOperand : public MCParsedAsmOperand {

  enum KindTy {
    Token,
    Register,
    Immediate,
  } Kind;

  struct RegOp {
    unsigned RegNum;
  };

  struct ImmOp {
    const MCExpr *Val;
  };

  SMLoc StartLoc, EndLoc;
  union {
    StringRef Tok;
    RegOp Reg;
    ImmOp Imm;
  };

  EBCOperand(KindTy K) : MCParsedAsmOperand(), Kind(K) {}

public:
  EBCOperand(const EBCOperand &o) : MCParsedAsmOperand() {
    Kind = o.Kind;
    StartLoc = o.StartLoc;
    EndLoc = o.EndLoc;
    switch (Kind) {
    case Token:
      Tok = o.Tok;
      break;
    case Register:
      Reg = o.Reg;
      break;
    case Immediate:
      Imm = o.Imm;
      break;
    }
  }

  bool isToken() const override { return Kind == Token; }
  bool isReg() const override { return Kind == Register; }
  bool isImm() const override { return Kind == Immediate; }
  bool isMem() const override { return false; }

  bool evaluateConstantImm(int64_t &Imm,
                           MCSymbolRefExpr::VariantKind &VK) const {
    const MCExpr *Val = getImm();
    bool Ret = false;
    if (auto *SE = dyn_cast<MCSymbolRefExpr>(Val)) {
      Ret = false;
      VK = SE->getKind();
    } else if (auto CE = dyn_cast<MCConstantExpr>(Val)) {
      Ret = true;
      VK = MCSymbolRefExpr::VK_None;
      Imm = CE->getValue();
    }
    return Ret;
  }

  template <uint8_t N> bool isImmN() const {
    int64_t Imm;
    MCSymbolRefExpr::VariantKind VK;
    if (!isImm())
      return false;
    bool IsConstantImm = evaluateConstantImm(Imm, VK);
    if (!IsConstantImm) {
      const MCExpr *Expr = getImm();
      if (isa<MCSymbolRefExpr>(Expr))
        return true;
      else
        return false;
    } else
      return isInt<N>(Imm);
  }

  template <uint8_t N> bool isIdxN() const {
    int64_t Imm;
    int64_t Lim = ((int64_t)1 << (N - 4)) - 1;
    MCSymbolRefExpr::VariantKind VK;
    if (!isImm())
      return false;
    bool IsConstantImm = evaluateConstantImm(Imm, VK);
    if (!IsConstantImm) {
      const MCExpr *Expr = getImm();
      if (isa<MCSymbolRefExpr>(Expr))
        return true;
      else
        return false;
    } else
      return isInt<N - 3>(Imm) && (Imm <= Lim) && (Imm >= -Lim);
  }

  bool isBreakCode8() const {
    int64_t Imm;
    MCSymbolRefExpr::VariantKind VK;
    if (!isImm())
      return false;
    bool IsConstantImm = evaluateConstantImm(Imm, VK);
    if (!IsConstantImm)
      return false;
    else
      return isUInt<8>(Imm) && (Imm >= 0 && Imm <= 6);
  }

  bool isImm8() const { return isImmN<8>(); }
  bool isImm16() const { return isImmN<16>(); }
  bool isImm32() const { return isImmN<32>(); }
  bool isImm64() const { return isImmN<64>(); }
  bool isIdxN16() const { return isIdxN<16>(); }
  bool isIdxC16() const { return isIdxN<16>(); }
  bool isIdxN32() const { return isIdxN<32>(); }
  bool isIdxC32() const { return isIdxN<32>(); }
  bool isIdxN64() const { return isIdxN<60>(); }
  bool isIdxC64() const { return isIdxN<60>(); }

  SMLoc getStartLoc() const override { return StartLoc; };
  SMLoc getEndLoc() const override { return EndLoc; };

  StringRef getToken() const {
    assert(Kind == Token && "Invalid type access!");
    return Tok;
  }

  unsigned getReg() const override {
    assert(Kind == Register && "Invalid type access!");
    return Reg.RegNum;
  }

  const MCExpr *getImm() const {
    assert(Kind == Immediate && "Invalid type access!");
    return Imm.Val;
  }

  void print(raw_ostream &OS) const override {
    switch (Kind) {
    case Token:
      OS << "'" << getToken() << "'";
      break;
    case Register:
      OS << "<register: r" << getReg() << ">";
      break;
    case Immediate:
      OS << *getImm();
      break;
    }
  }

  static std::unique_ptr<EBCOperand> createToken(StringRef Str, SMLoc S) {
    auto Op = make_unique<EBCOperand>(Token);
    Op->Tok = Str;
    Op->StartLoc = S;
    Op->EndLoc = S;
    return Op;
  }

  static std::unique_ptr<EBCOperand> createReg(unsigned RegNo, SMLoc S,
                                              SMLoc E) {
    auto Op = make_unique<EBCOperand>(Register);
    Op->Reg.RegNum = RegNo;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  static std::unique_ptr<EBCOperand> createImm(const MCExpr *Val, SMLoc S,
                                              SMLoc E) {
    auto Op = make_unique<EBCOperand>(Immediate);
    Op->Imm.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    assert(Expr && "Expr shouldn't be null!");
    if (auto *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  // Used by the TableGen code
  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    Inst.addOperand(MCOperand::createReg(getReg()));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getImm());
  }
};
} // end anonymous namespace.

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "EBCGenAsmMatcher.inc"
bool EBCAsmParser::generateImmOutOfRangeError(
    OperandVector &Operands, uint64_t ErrorInfo, int64_t Lower, int64_t Upper,
    Twine Msg = "immediate must be an integer in the range") {
  SMLoc ErrorLoc = ((EBCOperand &)*Operands[ErrorInfo]).getStartLoc();
  return Error(ErrorLoc, Msg + " [" + Twine(Lower) + ", " + Twine(Upper) + "]");
}

template<uint8_t N>
bool EBCAsmParser::checkIndex(const MCOperand &NMO, const MCOperand &CMO,
                                                              StringRef &Msg) {
  int64_t Natural = NMO.getImm();
  int64_t Constant = CMO.getImm();

  if (!((Natural >= 0 && Constant >= 0) || (Natural <= 0 && Constant <= 0))) {
    Msg = StringRef("natural unit and constant unit must have same signs");
    return false;
  }

  uint64_t AbsNatural = abs(Natural);
  uint64_t AbsConstant = abs(Constant);

  unsigned NaturalLen = 0;
  while (AbsNatural) {
    ++NaturalLen;
    AbsNatural >>= 1;
  }
  NaturalLen = alignTo(NaturalLen, N / 8);

  unsigned ConstantLen = 0;
  while (AbsConstant) {
    ++ConstantLen;
    AbsConstant >>= 1;
  }
  ConstantLen = alignTo(ConstantLen, N / 8);

  unsigned UsedBits = 4;

  if (!(UsedBits + NaturalLen + ConstantLen <= N)) {
    Msg = StringRef("unit length is too long");
    return false;
  }

  return true;
}

bool EBCAsmParser::validateIndex(const MCInst &MI,
                              uint64_t &ErrorInfo, StringRef &Msg) {
  const MCInstrDesc &Desc = MII.get(MI.getOpcode());

  for (unsigned I = 0, E = MI.getNumOperands(); I < E; ++I) {
    const MCOperand &NMO = MI.getOperand(I);
    if (NMO.isImm()) {
      const MCOperandInfo &NOI = Desc.OpInfo[I];
      if (NOI.OperandType == EBC::OPERAND_IDXN16) {
        assert(I + 1 < E && "Invalid number of operands!");
        const MCOperand &CMO = MI.getOperand(I + 1);
        const MCOperandInfo &COI = Desc.OpInfo[I + 1];
        assert(CMO.isImm() && "Invalid operand!");
        assert(COI.OperandType == EBC::OPERAND_IDXC16 && "Invalid operand!");
        if (!checkIndex<16>(NMO, CMO, Msg)) {
          ErrorInfo = I;
          return false;
        }
        ++I;
      } else if (NOI.OperandType == EBC::OPERAND_IDXN32) {
        assert(I + 1 < E && "Invalid number of operands!");
        const MCOperand &CMO = MI.getOperand(I + 1);
        const MCOperandInfo &COI = Desc.OpInfo[I + 1];
        assert(CMO.isImm() && "Invalid operand!");
        assert(COI.OperandType == EBC::OPERAND_IDXC32 && "Invalid operand!");
        if (!checkIndex<32>(NMO, CMO, Msg)) {
          ErrorInfo = I;
          return false;
        }
        ++I;
      } else if (NOI.OperandType == EBC::OPERAND_IDXN64) {
        assert(I + 1 < E && "Invalid number of operands!");
        const MCOperand &CMO = MI.getOperand(I + 1);
        const MCOperandInfo &COI = Desc.OpInfo[I + 1];
        assert(CMO.isImm() && "Invalid operand!");
        assert(COI.OperandType == EBC::OPERAND_IDXC64 && "Invalid operand!");
        if (!checkIndex<64>(NMO, CMO, Msg)) {
          ErrorInfo = I;
          return false;
        }
        ++I;
      }
    }
  }

  return true;
}

bool EBCAsmParser::MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                          OperandVector &Operands,
                                          MCStreamer &Out,
                                          uint64_t &ErrorInfo,
                                          bool MatchingInlineAsm) {
  MCInst Inst;
  SMLoc ErrorLoc;
  StringRef Msg;

  auto Result =
    MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm);
  switch (Result) {
  default:
    break;
  case Match_Success:
    if (!validateIndex(Inst, ErrorInfo, Msg)) {
      ErrorLoc = ((EBCOperand &)*Operands[ErrorInfo]).getStartLoc();
      return Error(ErrorLoc, Msg);
    }
    Out.EmitInstruction(Inst, getSTI());
    return false;
  case Match_MissingFeature:
    return Error(IDLoc, "instruction use requires an option to be enabled");
  case Match_MnemonicFail:
    return Error(IDLoc, "unrecognized instruction mnemonic");
  case Match_InvalidOperand:
    ErrorLoc = IDLoc;
    if (ErrorInfo != ~0U) {
      if (ErrorInfo >= Operands.size())
        return Error(ErrorLoc, "too few operands for instruction");
      
      ErrorLoc = ((EBCOperand &)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorLoc == SMLoc())
        ErrorLoc = IDLoc;
    }
    return Error(ErrorLoc, "invalid operand for instruction");
  case Match_InvalidBreakCode8:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, 0, 6,
        "break code must be an integer in the range");
  case Match_InvalidImm8:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, INT8_MIN, INT8_MAX);
  case Match_InvalidImm16:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, INT16_MIN, INT16_MAX);
  case Match_InvalidImm32:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, INT32_MIN, INT32_MAX);
  case Match_InvalidImm64:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, INT64_MIN, INT64_MAX);
  case Match_InvalidIdxN16:
  case Match_InvalidIdxC16:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, -((1 << 12) - 1), (1 << 12) - 1);
  case Match_InvalidIdxN32:
  case Match_InvalidIdxC32:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, -((1 << 28) - 1), (1 << 28) - 1);
  case Match_InvalidIdxN64:
  case Match_InvalidIdxC64:
    return generateImmOutOfRangeError(
        Operands, ErrorInfo, -(((int64_t)1 << 56) - 1), ((int64_t)1 << 56) - 1);
  }

  llvm_unreachable("Unknown match type detected!");
}

bool EBCAsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                SMLoc &EndLoc) {
  const AsmToken &Tok = getParser().getTok();
  StartLoc = Tok.getLoc();
  EndLoc = Tok.getEndLoc();
  RegNo = 0;
  StringRef Name = getLexer().getTok().getIdentifier();

  if (!MatchRegisterName(Name)) {
    getParser().Lex(); // Eat identifier token.
    return false;
  }

  return Error(StartLoc, "invalid register name");
}

OperandMatchResultTy EBCAsmParser::parseRegister(OperandVector &Operands) {
  SMLoc S = getLoc();
  SMLoc E = SMLoc::getFromPointer(S.getPointer() - 1);

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_NoMatch;
  case AsmToken::Identifier:
    StringRef Name = getLexer().getTok().getIdentifier();
    unsigned RegNo = MatchRegisterName(Name);
    if (RegNo == 0)
      return MatchOperand_NoMatch;
    getLexer().Lex();
    Operands.push_back(EBCOperand::createReg(RegNo, S, E));
  }

  return MatchOperand_Success;
}

OperandMatchResultTy EBCAsmParser::parseImmediate(OperandVector &Operands) {
  SMLoc S = getLoc();
  SMLoc E = SMLoc::getFromPointer(S.getPointer() - 1);
  const MCExpr *Res;

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_NoMatch;
  case AsmToken::LParen:
  case AsmToken::Minus:
  case AsmToken::Plus:
  case AsmToken::Integer:
  case AsmToken::String:
  case AsmToken::Identifier:
    if (getParser().parseExpression(Res))
      return MatchOperand_ParseFail;
    break;
  }

  Operands.push_back(EBCOperand::createImm(Res, S, E));
  return MatchOperand_Success;
}
OperandMatchResultTy EBCAsmParser::parseIndirectReg(OperandVector &Operands) {
  if (getLexer().isNot(AsmToken::At)) {
    return MatchOperand_ParseFail;
  }

  getParser().Lex(); // Eat '@'
  Operands.push_back(EBCOperand::createToken("@", getLoc()));

  if (parseRegister(Operands) != MatchOperand_Success) {
    Error(getLoc(), "expected register");
    return MatchOperand_ParseFail;
  }

  return MatchOperand_Success;
}

OperandMatchResultTy EBCAsmParser::parseIndex(OperandVector &Operands) {
  if (getLexer().isNot(AsmToken::LParen)) {
    Error(getLoc(), "expected '('");
    return MatchOperand_ParseFail;
  }

  getParser().Lex(); // Eat '('
  Operands.push_back(EBCOperand::createToken("(", getLoc()));

  if (parseImmediate(Operands) != MatchOperand_Success) {
    Error(getLoc(), "expected natural unit");
    return MatchOperand_ParseFail;
  }

  if (getLexer().isNot(AsmToken::Comma)) {
    Error(getLoc(), "expected ','");
    return MatchOperand_ParseFail;
  }

  getParser().Lex(); // Eat ','

  if (parseImmediate(Operands) != MatchOperand_Success) {
    Error(getLoc(), "expected constant unit");
    return MatchOperand_ParseFail;
  }

  if (getLexer().isNot(AsmToken::RParen)) {
    Error(getLoc(), "expected ')'");
    return MatchOperand_ParseFail;
  }

  getParser().Lex(); // Eat ')'
  Operands.push_back(EBCOperand::createToken(")", getLoc()));

  return MatchOperand_Success;
}

/// Looks at a token type and creates the relevant operand from this
/// information, adding to Operands. If operand was parsed, return false,
/// else true.
bool EBCAsmParser::parseOperand(OperandVector &Operands){
  // Attempt to parse token as a register
  if (parseRegister(Operands) == MatchOperand_Success) {
    // Parse immediate if present
    switch (getLexer().getKind()) {
    default:
      return false;
    case AsmToken::LParen:
      if (parseIndex(Operands) == MatchOperand_Success)
        return false;
    case AsmToken::Minus:
    case AsmToken::Plus:
    case AsmToken::Integer:
    case AsmToken::String:
    case AsmToken::Identifier:
      return parseImmediate(Operands) != MatchOperand_Success;
    }
  }

  // Attempt to parse token as a indirect register
  if (parseIndirectReg(Operands) == MatchOperand_Success) {
    // Parse index if present
    if (getLexer().is(AsmToken::LParen))
      return parseIndex(Operands) != MatchOperand_Success;
    return false;
  }

  // Attempt to parse token as an index
  if (getLexer().is(AsmToken::LParen)) {
    if (parseIndex(Operands) == MatchOperand_Success)
      return false;
  }

  // Attempt to parse token as an immediate
  if (parseImmediate(Operands) == MatchOperand_Success)
    return false;

  // Finally we have exhausted all options and must declare defeat
  Error(getLoc(), "unknown operand");
  return true;
}

bool EBCAsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                    StringRef Name, SMLoc NameLoc,
                                    OperandVector &Operands) {
  // First operand is token for instruction
  Operands.push_back(EBCOperand::createToken(Name, NameLoc));

  // If there are no more operands, then finish
  if (getLexer().is(AsmToken::EndOfStatement))
    return false;

  // Parse first operand
  if (parseOperand(Operands))
    return true;

  // parse until end of statement, consuming commas between operands
  while (getLexer().is(AsmToken::Comma)) {
    // Consume comma token
    getLexer().Lex();

    // Parse next operand
    if (parseOperand(Operands))
      return true;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getParser().Lex(); // Consume the EndOfStatement
  return false;
}

bool EBCAsmParser::ParseDirective(AsmToken DirectiveID) { return true; }

extern "C" void LLVMInitializeEBCAsmParser() {
  RegisterMCAsmParser<EBCAsmParser> X(getTheEBCTarget());
}
