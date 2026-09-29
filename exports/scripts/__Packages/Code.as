class Code
{
	var endInd;
	var ind;
	var str;
	static var playerVars = {x:"_x",y:"_y",vx:"vx",vy:"vy",wc:"wall_count",fc:"fall_count",hc:"hit_count",st:"state"};
	function Code()
	{
	}
	static function isS(sym, str)
	{
		return str.indexOf(sym) !== -1;
	}
	static function isWhitespaceAt(str, ind)
	{
		return Code.isWhitespace(str.charAt(ind));
	}
	static function isWhitespace(c)
	{
		return Code.isS(c," \t\r\n");
	}
	static function isDigit(c)
	{
		var _loc2_ = c.charCodeAt(0);
		return _loc2_ >= 48 && _loc2_ <= 57;
	}
	static function isVarStart(c)
	{
		var _loc2_ = c.charCodeAt(0);
		return _loc2_ >= 65 && _loc2_ <= 90 || _loc2_ >= 97 && _loc2_ <= 122 || _loc2_ === 95;
	}
	static function isVarMiddle(c)
	{
		return Code.isVarStart(c) || Code.isDigit(c);
	}
	static function indOf(str1, str2, ind)
	{
		if(!ind)
		{
			ind = 0;
		}
		ind = str1.indexOf(str2,ind);
		if(ind === -1)
		{
			return str1.length;
		}
		return ind;
	}
	static function execute(fun)
	{
		if(fun instanceof Function)
		{
			fun();
		}
		else if(fun instanceof Array)
		{
			fun[0].apply(null,fun.slice(1));
		}
	}
	static function parseAngled(str, ind)
	{
		var _loc4_ = {_x:[0,0],_y:[0,0],vx:[0,0],vy:[0,0],state:[0,0]};
		var _loc5_ = -1;
		var _loc6_ = -1;
		var _loc7_;
		var _loc8_;
		var _loc9_;
		var _loc10_;
		var _loc11_;
		while(ind < str.length)
		{
			_loc7_ = str.charAt(ind);
			if(!Code.isWhitespace(_loc7_))
			{
				if(_loc7_ === ">")
				{
					break;
				}
				if(_loc5_ === -1 || !Code.isS(_loc7_,":;"))
				{
					if(_loc5_ === -1)
					{
						_loc5_ = ind;
					}
					_loc6_ = ind + 1;
				}
				else
				{
					_loc8_ = str.slice(_loc5_,_loc6_);
					if(Code.playerVars.hasOwnProperty(_loc8_))
					{
						_loc8_ = Code.playerVars[_loc8_];
					}
					if(_root.game.player[_loc8_] === undefined)
					{
						throw new CompilerError("\'" + _loc8_ + "\' is not a player variable name",_loc5_);
					}
					if(_loc7_ === ";")
					{
						delete _loc4_[_loc8_];
						_loc5_ = -1;
					}
					else
					{
						_loc4_[_loc8_] = [0,0];
						_loc9_ = 0;
						while(_loc9_ < 2)
						{
							_loc5_ = -1;
							_loc6_ = -1;
							_loc10_ = ind;
							ind = ind + 1;
							while(ind < str.length)
							{
								_loc7_ = str.charAt(ind);
								if(Code.isS(_loc7_,",;"))
								{
									break;
								}
								if(!Code.isWhitespace(_loc7_))
								{
									if(_loc5_ === -1)
									{
										_loc5_ = ind;
									}
									_loc6_ = ind + 1;
								}
								ind = ind + 1;
							}
							if(ind >= str.length)
							{
								throw new CompilerError("Closing symbol not found",_loc10_);
							}
							if(_loc5_ === -1)
							{
								throw new CompilerError("Number not found",ind);
							}
							_loc11_ = Number(str.slice(_loc5_,_loc6_));
							if(isNaN(_loc11_))
							{
								throw new CompilerError("\'" + str.slice(_loc5_,_loc6_) + "\' is not a number",_loc5_);
							}
							if(_loc7_ === ";" && _loc9_ === 0)
							{
								if(_loc11_ >= 0)
								{
									_loc4_[_loc8_][1] = _loc11_;
								}
								else
								{
									_loc4_[_loc8_][0] = _loc11_;
								}
								break;
							}
							if(_loc7_ === "," && _loc9_ === 1)
							{
								throw new CompilerError("Expected \';\', found \',\'",ind);
							}
							_loc4_[_loc8_][_loc9_] = _loc11_;
							_loc9_ = _loc9_ + 1;
						}
						_loc5_ = -1;
					}
				}
			}
			ind = ind + 1;
		}
		return [_loc4_,ind + 1];
	}
	static function compile(str, startInd, endInd)
	{
		var _loc4_ = new Parser(new Code().lex(str,startInd,endInd)).program();
		trace(_loc4_);
		return _loc4_;
	}
	static function compileValue(str, startInd, endInd)
	{
		return new Parser(new Code().lex(str,startInd,endInd)).expression();
	}
	function peek()
	{
		if(this.ind >= this.endInd)
		{
			return "$end";
		}
		return this.str.charAt(this.ind);
	}
	function consume()
	{
		if(this.ind >= this.endInd)
		{
			throw new CompilerError("Code string ended unexpectedly",this.endInd - 1);
		}
		return this.str.charAt(this.ind++);
	}
	function lex(str, startInd, endInd)
	{
		this.str = str;
		this.ind = startInd || 0;
		this.endInd = endInd || str.length;
		var _loc5_ = [];
		var _loc6_;
		var _loc7_;
		var _loc8_;
		while(true)
		{
			while(Code.isWhitespace(this.peek()))
			{
				this.consume();
			}
			_loc6_ = "";
			_loc7_ = this.peek();
			_loc8_ = this.ind;
			if(_loc7_ === "$end")
			{
				break;
			}
			if(Code.isVarStart(_loc7_))
			{
				_loc6_ = "$v";
				do
				{
					_loc6_ += this.consume();
				}
				while(Code.isVarMiddle(this.peek()));
			}
			else if(Code.isDigit(_loc7_))
			{
				_loc6_ = "$n";
				do
				{
					_loc6_ += this.consume();
				}
				while(Code.isDigit(this.peek()));
				if(this.peek() === ".")
				{
					do
					{
						_loc6_ += this.consume();
					}
					while(Code.isDigit(this.peek()));
				}
			}
			else if(_loc7_ === "\"")
			{
				_loc6_ = "$s";
				this.consume();
				while(this.peek() !== "\"")
				{
					if(this.peek() == "\\")
					{
						this.consume();
						switch(this.peek())
						{
							case "n":
								_loc6_ += "\n";
								break;
							case "t":
								_loc6_ += "\t";
								break;
							default:
								_loc6_ += this.peek();
						}
					}
					else
					{
						_loc6_ += this.peek();
					}
					this.consume();
				}
				this.consume();
			}
			else if(Code.isS(_loc7_,"!+-*/%=&|<>^"))
			{
				_loc6_ = this.consume();
				if(Code.isS(_loc7_,"&|<>") && this.peek() === _loc7_)
				{
					_loc6_ += this.consume();
					if(_loc7_ === ">" && this.peek() === ">")
					{
						_loc6_ += this.consume();
					}
				}
				if(this.peek() === "=")
				{
					_loc6_ += this.consume();
					if((_loc7_ === "!" || _loc7_ === "=") && this.peek() === "=")
					{
						_loc6_ += this.consume();
					}
				}
				else if(this.peek() === _loc7_)
				{
					if(_loc7_ === "+" || _loc7_ === "-")
					{
						_loc6_ += this.consume();
					}
					else if(_loc7_ === "/")
					{
						_loc6_ = "";
						while(this.peek() !== "$end" && this.consume() !== "\n")
						{
						}
					}
				}
				else if(_loc7_ === "/" && this.peek() === "*")
				{
					_loc6_ = "";
					this.consume();
					while(true)
					{
						if(this.consume() === "*")
						{
							if(this.peek() === "/")
							{
								break;
							}
						}
						continue;
					}
					this.consume();
				}
			}
			else if(Code.isS(_loc7_,"()[];?:,~"))
			{
				_loc6_ = this.consume();
			}
			else
			{
				if(_loc7_ !== ".")
				{
					throw new CompilerError("Unexpected symbol " + _loc7_,this.ind);
				}
				_loc6_ = this.consume();
				if(Code.isWhitespace(this.peek()))
				{
					_loc6_ += " ";
					this.consume();
				}
			}
			if(_loc6_)
			{
				_loc5_.push(_loc6_,_loc8_);
			}
		}
		_loc5_.push("$end",this.ind);
		return _loc5_;
	}
	static function interpret(tree)
	{
		if(!(tree instanceof Array))
		{
			return tree;
		}
		var op = tree[0];
		switch(op)
		{
			case "&&":
				return Code.interpret(tree[1]) && Code.interpret(tree[2]);
			case "||":
				return Code.interpret(tree[1]) || Code.interpret(tree[2]);
			case "?":
				return Code.interpret(tree[1]) ? Code.interpret(tree[2]) : Code.interpret(tree[3]);
			case ",":
				var arr = [];
				var i = 1;
				while(i < tree.length)
				{
					arr.push(Code.interpret(tree[i]));
					i++;
				}
				return arr;
			case ";":
				var i = 1;
				while(i < tree.length)
				{
					Code.interpret(tree[i]);
					i++;
				}
				return undefined;
			default:
				var val1 = Code.interpret(tree[1]);
				switch(op)
				{
					case "!":
						return !val1;
					case "~":
						return ~val1;
					case "$":
						var r = eval(val1);
						if(r === undefined)
						{
							var arr = val1.split(".");
							r = eval(arr[0]);
							var i = 1;
							while(i < arr.length && r)
							{
								r = r[arr[i]];
								i++;
							}
						}
						return r;
					case "trace":
						trace(val1);
						return undefined;
					default:
						var val2 = Code.interpret(tree[2]);
						switch(op)
						{
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
								return val1.apply(null,val2);
							case "$=":
								if(tree.length === 4)
								{
									if(tree[3] === "++" || tree[3] === "--")
									{
										val2 = eval(val1);
										set(val1,val2 + (tree[3] === "++" ? 1 : -1));
										return val2;
									}
									val2 = Code.interpret([tree[3],eval(val1),val2]);
								}
								set(val1,val2);
								return val2;
							default:
								var val3 = Code.interpret(tree[3]);
								switch(op)
								{
									case "=":
										if(tree.length === 5)
										{
											if(tree[4] === "++" || tree[4] === "--")
											{
												val3 = val1[val2];
												val1[val2] = val3 + (tree[4] === "++" ? 1 : -1);
												return val3;
											}
											val3 = Code.interpret([tree[4],val1[val2],val3]);
										}
										return val1[val2] = val3;
									case ".(":
										return val1[val2].apply(val1,val3);
									default:
										throw new Error("Unknown operation: " + op);
								}
						}
				}
		}
	}
	static function getCodeBlockEnd(str, startInd)
	{
		var _loc3_ = startInd;
		var _loc4_ = -1;
		var _loc5_ = -1;
		var _loc6_ = 0;
		var _loc7_;
		var _loc8_;
		var _loc9_;
		var _loc10_;
		while(true)
		{
			if(_loc3_ > _loc4_)
			{
				_loc4_ = Code.indOf(str,"}",_loc3_);
			}
			if(_loc3_ > _loc5_)
			{
				_loc5_ = Code.indOf(str,"{",_loc3_);
			}
			_loc7_ = Math.min(Code.indOf(str,"\'",_loc3_),Code.indOf(str,"\"",_loc3_));
			if(_loc5_ < _loc4_ && _loc5_ < _loc7_)
			{
				_loc6_ = _loc6_ + 1;
				_loc3_ = _loc5_ + 1;
			}
			else
			{
				if(_loc4_ === _loc7_)
				{
					throw new CompilerError("Closing parenthesis not found",_loc3_);
				}
				if(_loc4_ < _loc7_)
				{
					if(_loc6_ === 0)
					{
						return _loc4_;
					}
					_loc6_ = _loc6_ - 1;
					_loc3_ = _loc4_ + 1;
				}
				else
				{
					_loc8_ = str.charAt(_loc7_);
					_loc9_ = _loc7_ + 1;
					while(true)
					{
						_loc9_ = str.indexOf(_loc8_,_loc9_);
						if(_loc9_ === -1)
						{
							throw new CompilerError("Closing quote not found",_loc3_);
						}
						_loc10_ = _loc9_ - 1;
						while(str.charAt(_loc10_) === "\\")
						{
							_loc10_ = _loc10_ - 1;
						}
						if(_loc9_ - _loc10_ & 1)
						{
							_loc3_ = _loc9_ + 1;
							break;
						}
						_loc9_ = _loc9_ + 1;
					}
				}
			}
		}
	}
}
