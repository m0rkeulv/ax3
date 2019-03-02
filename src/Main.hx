import sys.FileSystem;

class Main {
	static var eagerFail = false;

	// static var typer:Typer;

	static function main() {
		var args = Sys.args();
		var dir = switch args {
			case ["eagerFail", path]:
				eagerFail = true;
				path;
			case [path]:
				path;
			case _:
				throw "invalid args";
		}
		var libs = [
			"playerglobal32_0.swc",
			"libs/starling-1.7.1-20151208.155452-1.swc",
			"libs/starling-extensions-scrollimg_foe.swc",
			"libs/starling-ffparticlesystem-1.0.0.swc",
			"libs/robotlegs-framework-v1.5.2.swc",
			"libs/robotlegs-utilities-Modular.swc",
			"libs/robotlegs-starling-utilities-Modular-v0.5.3.swc",
			"libs/robotlegs-utilities-StateMachine.swc",
			"libs/robotlegs-plugin-starling-0.3.swc",
			"libs/common.swc",
			"libs/Collections.swc",
			"libs/snake-0.7.0.swc",
			"libs/openfl-tilemap.swc",
			"libs/greensock.swc",
			"libs/Flint2d_4.0.1.swc",
			"libs/as3-gettext-0.9.6.innogames-custom.swc",
			"libs/spine-as3-1.0.0.swc",
			"libs/tutorial-1.1.2.swc",
			"libs/AS3Communicator-lib.swc",
		];

		var files = [];
		walk(dir, files);

		var structure = Structure.build(files, libs);
		sys.io.File.saveContent("structure.txt", structure.dump());

		var typer = new Typer2(structure);
		typer.process(files);
		// typer.process();
		// typer.write("./OUT/");
	}

	static function walk(dir:String, files:Array<ParseTree.File>) {
		function loop(dir) {
			for (name in FileSystem.readDirectory(dir)) {
				var absPath = dir + "/" + name;
				if (FileSystem.isDirectory(absPath)) {
					walk(absPath, files);
				} else if (StringTools.endsWith(name, ".as")) {
					var file = parseFile(absPath);
					if (file != null) {
						files.push(file);
					}
				}
			}
		}
		loop(dir);
	}

	static function parseFile(path:String):ParseTree.File {
		// print('Parsing $path');
		var content = stripBOM(sys.io.File.getContent(path));
		var scanner = new Scanner(content);
		var parser = new Parser(scanner, new haxe.io.Path(path).file);
		var parseTree = null;
		if (eagerFail) {
			parseTree = parser.parse();
			// var dump = ParseTreeDump.printFile(parseTree, "");
			// Sys.println(dump);
		} else {
			try {
				parseTree = parser.parse();
			} catch (e:Any) {
				var pos = @:privateAccess scanner.pos;
				var line = getLine(content, pos);
				printerr('$path:$line: $e');
			}
		}
		if (parseTree != null) {
			checkParseTree(content, parseTree);
		}
		return parseTree;
	}

	static function checkParseTree(expected:String, parseTree:ParseTree.File) {
		var actual = Printer.print(parseTree);
		if (actual != expected)
			throw "not the same: " + haxe.Json.stringify(actual);
	}

	static function stripBOM(text:String):String {
		return if (StringTools.fastCodeAt(text, 0) == 0xFEFF) text.substring(1) else text;
	}

	static function print(s:String) #if hxnodejs js.Node.console.log(s) #else Sys.println(s) #end;
	static function printerr(s:String) #if hxnodejs js.Node.console.error(s) #else Sys.println(s) #end;

	static function getLine(content:String, pos:Int):Int {
		var line = 1;
		var p = 0;
		while (p < pos) {
			switch StringTools.fastCodeAt(content, p++) {
				case '\n'.code:
					line++;
				case '\r'.code:
					p++;
					line++;
			}
		}
		return line;
	}
}
