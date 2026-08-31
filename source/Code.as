class Code
{
	var str;
	var ind;
	var endInd;
	//https://help.adobe.com/en_US/as3/learn/WS5b3ccc516d4fbf351e63e3d118a9b90204-7fd1.html#WS5b3ccc516d4fbf351e63e3d118a9b90204-7f6c
	
	static var playerVars = {
		x: "_x",
		y: "_y",
		vx: "vx",
		vy: "vy",
		wc: "wall_count",
		fc: "fall_count",
		hc: "hit_count",
		st: "state"
	};
	
	static function isS(sym, str) {
		return str.indexOf(sym) !== -1;
	}
	
	static function isWhitespaceAt(str, ind) {
		return Code.isWhitespace(str.charAt(ind));
	}
	
	static function isWhitespace(c) {
		return Code.isS(c, " \t\r\n");
	}
	
	static function isDigit(c) {
		var num = c.charCodeAt(0);
		return num >= 48 && num <= 57;
	}
	
	static function isVarStart(c) {
		var num = c.charCodeAt(0);
		return num >= 65 && num <= 90 || num >= 97 && num <= 122 || num === 95;
	}
	
	static function isVarMiddle(c) {
		return Code.isVarStart(c) || Code.isDigit(c);
	}
	
	static function indOf(str1, str2, ind) {
		if (!ind) {
			ind = 0;
		}
		ind = str1.indexOf(str2, ind);
		if (ind === -1) {
			return str1.length;
		}
		return ind;
	}
	
	static function execute(fun) {
		if (fun instanceof Function) {
			fun();
		} else if (fun instanceof Array) {
			fun[0].apply(null, fun.slice(1));
		}
	}
	
	static function parseAngled(str, ind) {
		
		var obj = {_x: [0, 0], _y: [0, 0], vx: [0, 0], vy: [0, 0], state: [0, 0]};
		
		var firstLetter = -1;
		var lastLetter = -1;
		
		for (; ind < str.length; ind++) {
			var c = str.charAt(ind);
			
			if (Code.isWhitespace(c)) {
				continue;
			}
			
			if (c === ">") {
				break;
			}
			
			if (firstLetter === -1 || !Code.isS(c, ":;")) {
				if (firstLetter === -1) {
					firstLetter = ind;
				}
				lastLetter = ind + 1;
				continue;
			}
			
			var varName = str.slice(firstLetter, lastLetter);
			
			if (Code.playerVars.hasOwnProperty(varName)) {
				varName = Code.playerVars[varName];
			}
			
			if (_root.game.player[varName] === undefined) {
				throw new CompilerError("'" + varName + "' is not a player variable name", firstLetter);
			}
			
			if (c === ";") {
				delete obj[varName];
				firstLetter = -1;
				continue;
			}
			
			obj[varName] = [0, 0];
			
			for (var i = 0; i < 2; i++) {
				firstLetter = -1;
				lastLetter = -1;
				var curStart = ind;
				
				for (ind++; ind < str.length; ind++) {
					c = str.charAt(ind)
					if (Code.isS(c, ",;")) {
						break;
					}
					
					if (!Code.isWhitespace(c)) {
						if (firstLetter === -1) {
							firstLetter = ind;
						}
						lastLetter = ind + 1;
					}
				}
				
				if (ind >= str.length) {
					throw new CompilerError("Closing symbol not found", curStart);
				} else if (firstLetter === -1) {
					throw new CompilerError("Number not found", ind);
				}
				
				var num = Number(str.slice(firstLetter, lastLetter));
				if (isNaN(num)) {
					throw new CompilerError("'" + str.slice(firstLetter, lastLetter) + "' is not a number", firstLetter);
				}
				
				if (c === ";" && i === 0) {
					if (num >= 0) {
						obj[varName][1] = num;
					} else {
						obj[varName][0] = num;
					}
					break;
				} else if (c === "," && i === 1) {
					throw new CompilerError("Expected ';', found ','", ind);
				} else {
					obj[varName][i] = num;
				}
			}
			
			firstLetter = -1;
		}
		
		return [obj, ind + 1];
	}
	
	static function compile(str, startInd, endInd) {
		var r = new Parser(new Code().lex(str, startInd, endInd)).program();
		trace(r);
		return r;
	}
	
	static function compileValue(str, startInd, endInd) {
		return new Parser(new Code().lex(str, startInd, endInd)).expression();
	}
	
	function peek() {
		if (this.ind >= this.endInd) {
			return "$end";
		}
		return this.str.charAt(this.ind);
	}
	
	function consume() {
		if (this.ind >= this.endInd) {
			throw new CompilerError("Code string ended unexpectedly", this.endInd - 1);
		}
		return this.str.charAt(this.ind++);
	}
	
	function lex(str, startInd, endInd) {
		this.str = str;
		this.ind = startInd || 0;
		this.endInd = endInd || str.length;
		var arr = [];
		
		while (true) {
			while (Code.isWhitespace(this.peek())) {
				this.consume();
			}
			
			var tok = "";
			var c = this.peek();
			var pos = this.ind;
			
			if (c === "$end") {
				
				break;
				
			} else if (Code.isVarStart(c)) {
				
				tok = "$v";
				do {
					tok += this.consume();
				} while (Code.isVarMiddle(this.peek()));
				
			} else if (Code.isDigit(c)) {
			
				tok = "$n";
				do {
					tok += this.consume();
				} while (Code.isDigit(this.peek()));
				
				if (this.peek() === ".") {
					do {
						tok += this.consume();
					} while (Code.isDigit(this.peek()));
				}
				
			} else if (c === '"') {
				
				tok = "$s";
				for (this.consume(); this.peek() !== '"'; this.consume()) {
					if (this.peek() == "\\") {
						this.consume();
						switch (this.peek()) {
							case "n":
								tok += "\n";
								break;
							case "t":
								tok += "\t";
								break;
							default:
								tok += this.peek();
								break;
						}
					} else {
						tok += this.peek();
					}
				}
				this.consume();
				
			} else if (Code.isS(c, "!+-*/%=&|<>^")) {
				
				tok = this.consume();
				
				if (Code.isS(c, "&|<>") && this.peek() === c) {
					tok += this.consume();
					if (c === ">" && this.peek() === ">") {
						tok += this.consume();
					}
				}
				
				if (this.peek() === "=") {
					tok += this.consume();
					if ((c === "!" || c === "=") && this.peek() === "=") {
						tok += this.consume();
					}
				} else if (this.peek() === c) {
					if (c === "+" || c === "-") {
						tok += this.consume();
					} else if (c === "/") {
						tok = "";
						while (this.peek() !== "$end" && this.consume() !== "\n") {}
					}
				} else if (c === "/" && this.peek() === "*") {
					tok = "";
					this.consume();
					while (true) {
                        if (this.consume() === "*") {
                            if (this.peek() === "/") {
                                this.consume();
                                break;
                            }
                        }
                    }
				}
				
			} else if (Code.isS(c, "()[];?:,~")) {
				
				tok = this.consume();
				
			} else if (c === ".") {
				
				tok = this.consume();
				if (Code.isWhitespace(this.peek())) {
					tok += " ";
					this.consume();
				}
				
			} else {
				throw new CompilerError("Unexpected symbol " + c, this.ind);
			}
			
			if (tok) {
				arr.push(tok, pos);
			}
		}
		
		arr.push("$end", this.ind);
		return arr;
	}
	
	static function interpret(tree) {
		if (!(tree instanceof Array)) {
			return tree;
		}
		
		var op = tree[0];
		
		switch (op) {
			case "&&":
				return Code.interpret(tree[1]) && Code.interpret(tree[2]);
			case "||":
				return Code.interpret(tree[1]) || Code.interpret(tree[2]);
			case "?":
				return Code.interpret(tree[1]) ? Code.interpret(tree[2]) : Code.interpret(tree[3]);
			case ",":
				var arr = [];
				for (var i = 1; i < tree.length; i++) {
					arr.push(Code.interpret(tree[i]));
				}
				return arr;
			case ";":
				for (var i = 1; i < tree.length; i++) {
					Code.interpret(tree[i]);
				}
				return;
		}
		
		var val1 = Code.interpret(tree[1]);
		
		switch (op) {
			case "!":
				return !val1;
			case "~":
				return ~val1;
			case "$":
				var r = eval(val1);
				
				if (r === undefined) {
					var arr = val1.split(".");
					r = eval(arr[0]);
					
					for (var i = 1; i < arr.length && r; i++) {
						r = r[arr[i]];
					}
				}
				return r;
			case "trace":
				trace(val1);
				return;
		}
		
		var val2 = Code.interpret(tree[2]);
		
		switch (op) {
			case "|":
				return val1 | val2;
			case "^":
				return val1 ^ val2;
			case "&":
				return val1 & val2;
			case "==":
				return val1 == val2;
			case "!=":
				return val1 != val2;
			case "===":
				return val1 === val2;
			case "!==":
				return val1 !== val2;
			case "<":
				return val1 < val2;
			case ">":
				return val1 > val2;
			case "<=":
				return val1 <= val2;
			case ">=":
				return val1 >= val2;
			case "<<":
				return val1 << val2;
			case ">>":
				return val1 >> val2;
			case ">>>":
				return val1 >>> val2;
			case "+":
				return val1 + val2;
			case "-":
				return val1 - val2;
			case "*":
				return val1 * val2;
			case "/":
				return val1 / val2;
			case "%":
				return val1 % val2;
			case ".":
				return val1[val2];
			case "(":
				return val1.apply(null, val2);
			case "$=":
				if (tree.length === 4) {
					if (tree[3] === "++" || tree[3] === "--") {
						val2 = eval(val1);
						set(val1, val2 + (tree[3] === "++"? 1 : -1));
						return val2;
					} else {
						val2 = Code.interpret([tree[3], eval(val1), val2]);
					}
				}
				set(val1, val2);
				return val2;
		}
		
		var val3 = Code.interpret(tree[3]);
		
		switch (op) {
			case "=":
				if (tree.length === 5) {
					if (tree[4] === "++" || tree[4] === "--") {
						val3 = val1[val2];
						val1[val2] = val3 + (tree[4] === "++"? 1 : -1);
						return val3;
					} else {
						val3 = Code.interpret([tree[4], val1[val2], val3]);
					}
				}
				return val1[val2] = val3;
			case ".(":
				return val1[val2].apply(val1, val3);
		}
		
		throw new Error("Unknown operation: " + op);
	}
	
	static function getCodeBlockEnd(str, startInd) {
		var ind = startInd;
		var nextCloseInd = -1;
		var nextOpenInd = -1;
		var depth = 0;
		
		while (true) {
			if (ind > nextCloseInd) {
				nextCloseInd = Code.indOf(str, "}", ind);
			}
			if (ind > nextOpenInd) {
				nextOpenInd = Code.indOf(str, "{", ind);
			}
			var nextQuoteInd = Math.min(Code.indOf(str, "'", ind), Code.indOf(str, '"', ind));
			
			if (nextOpenInd < nextCloseInd && nextOpenInd < nextQuoteInd) {
				depth++;
				ind = nextOpenInd + 1;
				continue;
			}
			
			if (nextCloseInd === nextQuoteInd) {
				throw new CompilerError("Closing parenthesis not found", ind);
			}
			
			if (nextCloseInd < nextQuoteInd) {
				if (depth === 0) {
					return nextCloseInd;
				}
				depth--;
				ind = nextCloseInd + 1;
				continue;
			}
			
			var q = str.charAt(nextQuoteInd);
			var ind2 = nextQuoteInd + 1;
			while (true) {
				ind2 = str.indexOf(q, ind2);
				if (ind2 === -1) {
					throw new CompilerError("Closing quote not found", ind);
				}
				var slashStart = ind2 - 1;
				while (str.charAt(slashStart) === "\\") {
					slashStart--;
				}
				if ((ind2 - slashStart) & 1) {
					ind = ind2 + 1;
					break;
				}
				ind2++;
			}
		}
	}
}