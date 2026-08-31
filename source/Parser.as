class Parser {
	var arr;
	var ind;
	
	static var constObj = {
		true: true,
		false: false,
		undefined: undefined,
		null: null
	};
	
	static var globalShortcuts = {
		p: "_root.game.player",
		g: "_root.game",
		G: "com.nitrome.toxic.Global"
	};
	
	static function isAssignmentToken(str) {
		return str === "=" || str !== ">=" && str !== "<=" && !Code.isS(str.charAt(0), "$!=") && str.charAt(str.length - 1) === "=";
	}
	
	function getToSetToken(tok) {
		if (tok === "$") {
			return "$=";
		}
		if (tok === ".") {
			return "=";
		}
		if (tok === undefined) {
			throw new CompilerError("Unexpected literal before assignment", this.pos());
		}
		throw new CompilerError("Unexpected operation '" + tok + "' before assignment", this.pos());
	}
	
	static function isOp(op, ops) {
		if (typeof ops === "string") {
			return Code.isS(op, ops);
		}
		
		for (var i in ops) {
			if (ops[i] === op) {
				return true;
			}
		}
		
		return false;
	}
	
	function Parser(arr) {
		this.arr = arr;
		this.ind = 0;
	}
	
	function wrongTokenError() {
		throw new CompilerError("Unexpected token: " + this.peek(), this.pos());
	}
	
	function pos() {
		return this.arr[this.ind + 1];
	}
	
	function peek() {
		return this.arr[this.ind];
	}
	
	function match(token) {
		if (this.peek() !== token) {
			this.wrongTokenError();
		}
		this.consume();
	}
	
	function consume() {
		var v = this.peek();
		this.ind += 2;
		return v;
	}
	
	function program() {
		var a = this.statementStack();
		this.match("$end");
		return a;
	}
	
	function statementStack() {
		var a = [";"];
		while (this.peek() !== "$end") {
			a.push(this.statement());
			this.match(";");
		}
		return a;
	}
	
	function statement() {
		return this.expression();
	}
	
	function commaList() {
		if (this.peek() === ")" || this.peek() === "]") {
			return [","];
		}
		var a = [",", this.expression()];
		while (this.peek() === ",") {
			this.consume();
			a.push(this.expression());
		}
		return a;
	}
	
	function expression() {
		return this.assignment();
	}
	
	function assignment() {
		var a = this.conditional();
		if (Parser.isAssignmentToken(this.peek())) {
			a[0] = this.getToSetToken(a[0]);
			var op = this.consume().slice(0, -1);
			a.push(this.assignment());
			if (op) {
				a.push(op);
			}
		}
		return a;
	}
	
	function leftAssocOp(ops, next) {
		var a = this[next]();
		while (Parser.isOp(this.peek(), ops)) {
			a = [this.consume(), a];
			a.push(this[next]());
		}
		return a;
	}
	
	function rightAssocOp(ops, next) {
		var a = this[next]();
		if (Parser.isOp(this.peek(), ops)) {
			a = [this.consume(), a];
			a.push(rightAssocOp(ops, next));
		}
		return a;
	}
	
	function conditional() {
		var a = this.logOr();
		if (this.peek() === "?") {
			a = [this.consume(), a];
			a.push(this.conditional());
			this.match(":");
			a.push(this.conditional());
		}
		return a;
	}
	
	function logOr() {
		return this.rightAssocOp(["||"], "logAnd");
	}
	
	function logAnd() {
		return this.rightAssocOp(["&&"], "bitOr");
	}
	
	function bitOr() {
		return this.leftAssocOp("|", "bitXor");
	}
	
	function bitXor() {
		return this.leftAssocOp("^", "bitAnd");
	}
	
	function bitAnd() {
		return this.leftAssocOp("&", "equality");
	}
	
	function equality() {
		return this.leftAssocOp(["==", "!=", "===", "!=="], "relational");
	}
	
	function relational() {
		return this.leftAssocOp(["<", ">", "<=", ">="], "bitShift");
	}
	
	function bitShift() {
		return this.leftAssocOp(["<<", ">>", ">>>"], "sum");
	}
	
	function sum() {
		return this.leftAssocOp("+-", "product");
	}
	
	function product() {
		return this.leftAssocOp("*/%", "unary");
	}
	
	function unary() {
		var a;
		
		switch (this.peek()) {
			case "+":
				this.consume();
				return this.unary();
			case "-":
				this.consume();
				return ["-", 0, this.unary()];
			case "!":
			case "~":
				a = [this.consume()];
				a.push(this.unary());
				return a;
			case "++":
			case "--":
				var op = this.consume().charAt(0);
				a = this.unary();
				a[0] = this.getToSetToken(a[0]);
				a.push(1, op);
				return a;
		}
		
		a = this.property();
		
		if (this.peek() === "++" || this.peek() === "--") {
			var op = this.consume();
			a[0] = this.getToSetToken(a[0]);
			a.push(1, op);
		}
		
		return a;
	}
	
	function property() {
		var a = this.singleton();
		while (true) {
			switch (this.peek()) {
				case ".":
				case ". ":
					var spaced = this.consume() === ". ";
					var prefix = this.peek().slice(0, 2);
					if (prefix !== "$v" && prefix !== "$n") {
						this.wrongTokenError();
					}
					if (!spaced && a instanceof Array && a[0] === "$" && typeof a[1] === "string") {
						a[1] += "." + this.consume().slice(2);
					} else {
						a = [".", a, this.consume().slice(2)];
					}
					continue;
				case "[":
					this.consume();
					a = [".", a, this.expression()];
					this.match("]");
					continue;
				case "(":
					this.consume();
					var params = this.commaList();
					var b = ["(", a, params];
					
					if (a instanceof Array) {
						if (a[0] === "$" && typeof a[1] === "string") {
							var lastDot = a[1].lastIndexOf(".");
							
							if (lastDot !== -1) {
								b = [".(", a, a[1].slice(lastDot + 1), params];
								a[1] = a[1].slice(0, lastDot);
							} else {
								switch (a[1]) {
									case "eval":
										b = ["$", params[1]];
										break;
									case "set":
										b = ["$=", params[1], params[2]];
										break;
									case "trace":
										b = ["trace", params[1]];
										break;
								}
							}
						} else if (a[0] === ".") {
							a[0] = ".(";
							a.push(params);
							b = a;
						}
					}
					
					a = b;
					
					this.match(")");
					continue;
			}
			break;
		}
		return a;
	}
	
	function singleton() {
		var a;
		if (this.peek() === "(") {
			this.consume();
			a = this.expression();
			this.match(")");
		} else if (this.peek() === "[") {
			this.consume();
			a = this.commaList();
			this.match("]");
		} else switch (this.peek().slice(0, 2)) {
			case "$n":
				return Number(this.consume().slice(2));
			case "$s":
				return this.consume().slice(2);
			case "$v":
				var v = this.consume().slice(2);
				if (Parser.constObj.hasOwnProperty(v)) {
					return Parser.constObj[v];
				}
				if (Code.playerVars.hasOwnProperty(v)) {
					v = "_root.game.player." + Code.playerVars[v];
				} else if (Parser.globalShortcuts.hasOwnProperty(v)) {
					v = Parser.globalShortcuts[v];
				}
				return ["$", v];
			default:
				this.wrongTokenError();
		}
		
		return a;
	}
}