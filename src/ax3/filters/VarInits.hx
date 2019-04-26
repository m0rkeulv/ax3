package ax3.filters;

class VarInits extends AbstractFilter {
	override function processExpr(e:TExpr):TExpr {
		return switch e.kind {
			case TEVars(_, vars):
				for (v in vars) {
					v.init = processVarInit(v.v.type, v.init);
				}
				e;

			case _:
				mapExpr(processExpr, e);
		}
	}

	override function processVarFields(vars:Array<TVarFieldDecl>) {
		for (v in vars) {
			v.init = processVarInit(v.type, v.init);
		}
	}

	static function processVarInit(type:TType, init:Null<TVarInit>):TVarInit {
		if (init == null) {
			return init = {
				equalsToken: equalsToken,
				expr: getDefaultInitExpr(type)
			};
		} else {
			return init;
		}
	}

	static final equalsToken = new Token(0, TkEquals, "=", [whitespace], [whitespace]);
	static final eFalse = mk(TELiteral(TLBool(mkIdent("false"))), TTBoolean, TTBoolean);
	static final eZeroInt = mk(TELiteral(TLInt(new Token(0, TkDecimalInteger, "0", [], []))), TTInt, TTInt);
	static final eZeroUint = mk(TELiteral(TLInt(new Token(0, TkDecimalInteger, "0", [], []))), TTUint, TTUint);
	static final eNaN = mkBuiltin("NaN", TTNumber);

	static function getDefaultInitExpr(t:TType):TExpr {
		return switch t {
			case TTBoolean: eFalse;
			case TTInt: eZeroInt;
			case TTUint: eZeroUint;
			case TTNumber: eNaN;
			case _: mkNullExpr(t);
		};
	}
}