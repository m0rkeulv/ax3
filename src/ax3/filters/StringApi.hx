package ax3.filters;

class StringApi extends AbstractFilter {
	static final tCompatReplace = TTFun([TTString, TTRegExp, TTString], TTString);
	static final tStringToolsReplace = TTFun([TTString, TTString, TTString], TTString);

	override function processExpr(e:TExpr):TExpr {
		return switch e.kind {
			case TECall({kind: TEField({kind: TOExplicit(_, eString = {type: TTString})}, "replace", _)}, args):
				eString = processExpr(eString);
				args = mapCallArgs(processExpr, args);
				switch args.args {
					case [ePattern = {expr: {type: TTRegExp}}, eBy = {expr: {type: TTString | TTFunction | TTFun(_) | TTAny /*hmm*/}}]:
						var eCompatReplace = mkBuiltin("ASCompat.regExpReplace", tCompatReplace, removeLeadingTrivia(eString));
						e.with(kind = TECall(eCompatReplace, args.with(args = [
							{expr: eString, comma: commaWithSpace}, ePattern, eBy
						])));

					case [ePattern = {expr: {type: TTString}}, eBy = {expr: {type: TTString}}]:
						var eStringToolsReplace = mkBuiltin("StringTools.replace", tStringToolsReplace, removeLeadingTrivia(eString));
						e.with(kind = TECall(eStringToolsReplace, args.with(args = [
							{expr: eString, comma: commaWithSpace}, ePattern, eBy
						])));

					case _:
						throwError(exprPos(e), "Unsupported String.replace arguments");
				}

			case TECall({kind: TEField({kind: TOExplicit(_, eString = {type: TTString})}, "match", _)}, args):
				eString = processExpr(eString);
				args = mapCallArgs(processExpr, args);
				switch args.args {
					case [ePattern = {expr: {type: TTRegExp}}]:
						var eCompatReplace = mkBuiltin("ASCompat.regExpMatch", tCompatReplace, removeLeadingTrivia(eString));
						e.with(kind = TECall(eCompatReplace, args.with(args = [
							{expr: eString, comma: commaWithSpace}, ePattern
						])));

					case _:
						throwError(exprPos(e), "Unsupported String.match arguments");
				}

			case TEField(fobj = {type: TTString}, "slice", fieldToken):
				mapExpr(processExpr, e).with(kind = TEField(fobj, "substring", new Token(fieldToken.pos, TkIdent, "substring", fieldToken.leadTrivia, fieldToken.trailTrivia)));

			case TEField(fobj = {type: TTString}, "toLocaleLowerCase", fieldToken):
				mapExpr(processExpr, e).with(kind = TEField(fobj, "toLowerCase", new Token(fieldToken.pos, TkIdent, "toLowerCase", fieldToken.leadTrivia, fieldToken.trailTrivia)));

			case TEField(fobj = {type: TTString}, "toLocaleUpperCase", fieldToken):
				mapExpr(processExpr, e).with(kind = TEField(fobj, "toUpperCase", new Token(fieldToken.pos, TkIdent, "toUpperCase", fieldToken.leadTrivia, fieldToken.trailTrivia)));

			case TEField({type: TTString}, name = "replace" | "match", _):
				throwError(exprPos(e), "closure on String." + name);

			case _:
				mapExpr(processExpr, e);
		}
	}
}