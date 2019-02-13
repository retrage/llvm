
using namespace llvm;

namespace {
struct EBCOperand;

class EBCAsmParser : public MCTargetAsmParser {
  SMLoc getLoc() const { return getParser().getTok().getLoc(); }

  EBCTargetStreamer &getTargetStreamer() {
    MCTargetStreamer &TS = *getParser().getStreamer().getTargetStreamer();
    return static_cast<EBCTargetStreamer &>(TS);
  }

  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                              OperandVector &Operands, MCStreamer &Out,
                              uint64_t &ErrorInfo,
                              bool MatchingInlineAsm) override;

  bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc) override;

  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

// Auto-generated instruction matching functions
#define GET_ASSEMBLER_HEADER
#include "EBCGenAsmMatcher.inc"

  OperandMatchResultTy parseRegister(OperandVector &Operands);
  OperandMatchResultTy parseImmediate(OperandVector &Operands);
  OperandMatchResultTy parseIndex(OperandVector &Operands);

  bool parseOperand(OperandVector &Operands, StringRef Mnemonic);

public:
  enum EBCMatchResultTy {
    Match_Dummy = FIRST_TARGET_MATCH_RESULT_TY,
#define GET_OPERAND_DIAGNOSTIC_TYPES
#include "EBCGenAsmMatcher.inc"
#undef GET_OPERAND_DIAGNOSTIC_TYPES
  };

  EBCAsmParser(const MCSubtargetInfo &STI, MCAsmParser &Parser,
              const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, STI, MII);
};

/// EBCOperand
struct EBCOperand : public MCParsedAsmOperand {

  enum KindTy {
    Token,
    Register,
    DedicatedRegister,
    Immediate,
    Index
  } Kind;

  struct RegOp {
    unsigned RegNum;
  };

  struct DediRegOp {
    unsigned RegNum;
  };

  struct ImmOp {
    const MCExpr *Val;
  };

  struct IdxOp {
    const MCExpr *Val;
  };

  SMLoc StartLoc, EndLoc;
  union {
    StringRef Tok;
    RegOp Reg;
    DediRegOp DediReg;
    ImmOp Imm;
    IdxOp Idx;
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
    case DedicatedRegister:
      DediReg = o.DediReg;
      break;
    case Immediate:
      Imm = o.Imm;
      break;
    case Index:
      Idx = o.Idx;
      break;
    }
  }

  bool isToken() const override { return Kind == Token; }
  bool isReg() const override { return Kind == Register; }
  bool isDediReg() const override { return Kind == DedicatedRegister; }
  bool isImm() const override { return Kind == Immediate; }
  bool isMem() const override { return false; }
  bool isIdx() const override { return Kind == Index; }

  static bool evaluateConstantImm(const MCExpr *Expr, int64_t &Imm,
                                  EBCMCExpr::VariantKind &VK) {
    if (auto *EE = dyn_cast<EBCMCExpr>(Expr)) {
      VK = EE->getKind();
      return EE->evaluateAsConstant(Imm);
    }

    if (auto CE = dyn_cast<MCConstantExpr>(Expr)) {
      VK = EBCMCExpr::VK_EBC_None;
      Imm = CE->getValue();
      return true;
    }

    return false;
  }

  template <int N> bool isImmN() const {
    if (!isImm())
      return false;
    EBCMCExpr::VariantKind VK;
    int64_t Imm;
    bool IsConstantImm = evaluateConstantImm(getImm(), Imm, VK);
    return IsConstantImm && isInt<N>(Imm) &&
            VK == EBCMCExpr::VK_EBC_None;
  }

  // TODO: Natural Index validation
  template <int N> bool isIdxN() const {
    if (!isIdx())
      return false;
    EBCMCExpr::VariantKind VK;
    int64_t Idx;
    bool IsConstantIdx = evaluateConstantImm(getIdx(), Idx, VK);
    return IsConstantIdx && isInt<N>(Idx) &&
            VK == EBCMCExpr::VK_EBC_None;
  }
  
  bool isImm8() const { return isImmN<8>(); }
  bool isImm16() const { return isImmN<16>(); }
  bool isImm32() const { return isImmN<32>(); }
  bool isImm64() const { return isImmN<64>(); }

  bool isIdx16() const { return isIdxN<16>(); }
  bool isIdx32() const { return isIdxN<32>(); }
  bool isIdx64() const { return isIdxN<64>(); }

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

  StringRef getDediReg() const override {
    assert(Kind == DedicatedRegister && "Invalid type access!");
    switch (DediReg.RegNum) {
    case 0:
      return StringRef("FLAGS");
    case 1:
      return StringRef("IP");
    }
  }

  const MCExpr *getImm() const {
    assert(Kind == Immediate && "Invalid type access!");
    return Imm.Val;
  }

  const MCExpr *getIdx() const {
    assert(Kind == Index && "Invalid type access!");
    return Idx.Val;
  }

  void print(raw_ostream &OS) const override {
    switch (Kind) {
    case Token:
      OS << "'" << getToken() << "'";
      break;
    case Register:
      OS << "<register: R" << getReg() << ">";
      break;
    case DedicatedRegister:
      OS << "<dedicated: " << getDediReg() << ">";
      break;
    case Immediate:
      OS << *getImm();
      break;
    case Index:
      OS << *getIdx();
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

  static std::unique_ptr<EBCOperand> createDediReg(unsigned RegNo, SMLoc S,
                                              SMLoc E) {
    auto Op = make_unique<EBCOperand>(DedicatedRegister);
    Op->DediReg.RegNum = RegNo;
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

  static std::unique_ptr<EBCOperand> createIdx(const MCExpr *Val, SMLoc S,
                                              SMLoc E) {
    auto Op = make_unique<EBCOperand>(Index);
    Op->Index.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  // TODO: Index
  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    assert(Expr && "Expr shouldn't be null!");
    int64_t Imm = 0;
    EBCMCExpr::VariantKind VK;
    bool IsConstant = evaluateConstantImm(Expr, Imm, VK);

    if (IsConstant)
      Inst.addOperand(MCOperand::createImm(Imm));
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

  void addIdxOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getIdx());
  }
};
} // end anonymous namespace.

bool EBCAsmParser::MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                          OperandVector &Operands,
                                          MCStreamer &Out,
                                          uint64_t &ErrorInfo,
                                          bool MatchingInlineAsm) {
  MCInst Inst;

  auto Result =
    MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm);
  switch (Result) {
  default:
    break;
  case Match_Success:
    Out.EmitInstruction(Inst, getSTI());
    return false;
  case Match_MissingFeature:
    return Error(IDLoc, "instruction use requires an option to be enabled");
  case Match_MnemonicFail:
    return Error(IDLoc, "unrecongnized instruction mnemonic");
  case Match_InvalidOperand: {
    SMLoc ErrorLoc = IDLoc;
    if (ErrorInfo != ~0U) {
      if (ErrorInfo >= Operands.size())
        return Error(ErrorLoc, "too few operands for instruction");
      
      ErrorLoc = ((EBCOperand &)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorInfo == SMLoc())
        ErrorLoc = IDLoc;
    }
    return Error(ErrorLoc, "invalid operand for instruction");
  }
  }
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
  switch (getLexer().getKind()) {
  default:
    return MatchOperand_NoMatch;
  case AsmToken::Identifier:
    StringRef Name = getLexer().getTok().getIdentifier();
    unsigned RegNo = MatchRegisterName(Name);
    if (RegNo == 0)
      return MatchOperand_NoMatch;
    SMLoc S = getLoc();
    SMLoc E = SMLoc::getFromPointer(S.getPointer() - 1);
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

OperandMatchResultTy EBCAsmParser::parseIndex(OperandVector &Operands) {
  if (getLexer().isNot(AsmToken::LParen))
    return MatchOperand_NoMatch;

  getParser().Lex(); // Eat '('
  Operands.push_back(EBCOperand::createToken("(", getLoc()));

  SMLoc NS = getLoc();
  SMLoc NE = StartLoc::getFromPointer(NS.getPointer() - 1);
  const MCExpr *NRes;

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_ParseFail;
  case AsmToken::LParen:
  case AsmToken::Minus:
  case AsmToken::Plus:
  case AsmToken::Integer:
  case AsmToken::Identifier:
    if (getParser().parseExpression(NRes))
      return MatchOperand_ParseFail;
    break;
  }

  Operands.push_back(EBCOperand::createImm(NRes, NS, NE));

  if (getLexer().isNot(AsmToken::Comma)) {
    Error(getLoc(), "expected ','");
    return MatchOperand_ParseFail;
  }

  SMLoc CS = getLoc();
  SMLoc CE = StartLoc::getFromPointer(CS.getPointer() - 1);
  const MCExpr *CRes;

  switch (getLexer().getKind()) {
  default:
    return MatchOperand_ParseFail;
  case AsmToken::LParen:
  case AsmToken::Minus:
  case AsmToken::Plus:
  case AsmToken::Integer:
  case AsmToken::Identifier:
    if (getParser().parseExpression(CRes))
      return MatchOperand_ParseFail;
    break;
  }

  Operands.push_back(EBCOperand::createImm(CRes, CS, CE));

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
bool EBCAsmParser::parseOperand(OperandVector &Operands, StringRef Mnemonic){
  // Check if the current operand has a custom associated parser,
  // if so, try to custom parse the operand,
  // or fallback to the general approach.
  OperandMatchResultTy Result =
    MatchOperandParserImpl(Operands, Mnemonic, true);
  if (Result == MatchOperand_Success)
    return false;
  if (Result == MatchOperand_ParseFail)
    return true;

  // Attempt to parse token as a register
  if (parseRegister(Operands) == MatchOperand_Success)
    return false;

  // Attempt to parse token as an immediate
  if (parseImmediate(Operands) == MatchOperand_Success)
    return false;

  // Attempt to parse token as an index
  if (parseIndex(Operands) == MatchOperand_Success)
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
  if (parseOperand(Operands, Name))
    return true;

  // TODO: Allow natural index
  // parse until end of statement, consuming commas between operands
  unsigned OperandIdx = 1;
  while (getLexer().is(AsmToken::Comma)) {
    // Consume comma token
    getLexer().Lex();

    // Parse next operand
    if (parseOperand(Operands, Name))
      return true;

    ++OperandIdx;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getParser().Lex(); // Consume the EndOfStatement
  return false;
}
