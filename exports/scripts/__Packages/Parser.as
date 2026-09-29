class Parser
{
	var arr;
	var ind;
	static var constObj = {§true§:true,§false§:false,§undefined§:undefined,§null§:null};
	static var globalShortcuts = {p:"_root.game.player",g:"_root.game",G:"com.nitrome.toxic.Global"};
	function Parser(arr)
	{
		this.arr = arr;
		this.ind = 0;
	}
	static function isAssignmentToken(str)
	{
		return str === "=" || str !== ">=" && str !== "<=" && !Code.isS(str.charAt(0),"$!=") && str.charAt(str.length - 1) === "=";
	}
	function getToSetToken(tok)
	{
		if(tok === "$")
		{
			return "$=";
		}
		if(tok === ".")
		{
			return "=";
		}
		if(tok === undefined)
		{
			throw new CompilerError("Unexpected literal before assignment",this.pos());
		}
		throw new CompilerError("Unexpected operation \'" + tok + "\' before assignment",this.pos());
	}
	static function isOp(op, ops)
	{
		if(typeof ops === "string")
		{
			return Code.isS(op,ops);
		}
		for(var _loc3_ in ops)
		{
			if(ops[_loc3_] === op)
			{
				return true;
			}
		}
		return false;
	}
	function wrongTokenError()
	{
		throw new CompilerError("Unexpected token: " + this.peek(),this.pos());
	}
	function pos()
	{
		return this.arr[this.ind + 1];
	}
	function peek()
	{
		return this.arr[this.ind];
	}
	function match(token)
	{
		if(this.peek() !== token)
		{
			this.wrongTokenError();
		}
		this.consume();
	}
	function consume()
	{
		var _loc2_ = this.peek();
		this.ind += 2;
		return _loc2_;
	}
	function program()
	{
		var _loc2_ = this.statementStack();
		this.match("$end");
		return _loc2_;
	}
	function statementStack()
	{
		var _loc2_ = [";"];
		while(this.peek() !== "$end")
		{
			_loc2_.push(this.statement());
			this.match(";");
		}
		return _loc2_;
	}
	function statement()
	{
		return this.expression();
	}
	function commaList()
	{
		if(this.peek() === ")" || this.peek() === "]")
		{
			return [","];
		}
		var _loc2_ = [",",this.expression()];
		while(this.peek() === ",")
		{
			this.consume();
			_loc2_.push(this.expression());
		}
		return _loc2_;
	}
	function expression()
	{
		return this.assignment();
	}
	function assignment()
	{
		var _loc2_ = this.conditional();
		var _loc3_;
		if(Parser.isAssignmentToken(this.peek()))
		{
			_loc2_[0] = this.getToSetToken(_loc2_[0]);
			_loc3_ = this.consume().slice(0,-1);
			_loc2_.push(this.assignment());
			if(_loc3_)
			{
				_loc2_.push(_loc3_);
			}
		}
		return _loc2_;
	}
	function leftAssocOp(ops, next)
	{
		var _loc4_ = this[next]();
		while(Parser.isOp(this.peek(),ops))
		{
			_loc4_ = [this.consume(),_loc4_];
			_loc4_.push(this[next]());
		}
		return _loc4_;
	}
	function rightAssocOp(ops, next)
	{
		var _loc4_ = this[next]();
		if(Parser.isOp(this.peek(),ops))
		{
			_loc4_ = [this.consume(),_loc4_];
			_loc4_.push(rightAssocOp(ops,next));
		}
		return _loc4_;
	}
	function conditional()
	{
		var _loc2_ = this.logOr();
		if(this.peek() === "?")
		{
			_loc2_ = [this.consume(),_loc2_];
			_loc2_.push(this.conditional());
			this.match(":");
			_loc2_.push(this.conditional());
		}
		return _loc2_;
	}
	function logOr()
	{
		return this.rightAssocOp(["||"],"logAnd");
	}
	function logAnd()
	{
		return this.rightAssocOp(["&&"],"bitOr");
	}
	function bitOr()
	{
		return this.leftAssocOp("|","bitXor");
	}
	function bitXor()
	{
		return this.leftAssocOp("^","bitAnd");
	}
	function bitAnd()
	{
		return this.leftAssocOp("&","equality");
	}
	function equality()
	{
		return this.leftAssocOp(["==","!=","===","!=="],"relational");
	}
	function relational()
	{
		return this.leftAssocOp(["<",">","<=",">="],"bitShift");
	}
	function bitShift()
	{
		return this.leftAssocOp(["<<",">>",">>>"],"sum");
	}
	function sum()
	{
		return this.leftAssocOp("+-","product");
	}
	function product()
	{
		return this.leftAssocOp("*/%","unary");
	}
	function unary()
	{
		var _loc2_;
		var _loc3_;
		switch(this.peek())
		{
			case "+":
				this.consume();
				return this.unary();
			case "-":
				this.consume();
				return ["-",0,this.unary()];
			case "!":
			case "~":
				_loc2_ = [this.consume()];
				_loc2_.push(this.unary());
				return _loc2_;
			case "++":
			case "--":
				_loc3_ = this.consume().charAt(0);
				_loc2_ = this.unary();
				_loc2_[0] = this.getToSetToken(_loc2_[0]);
				_loc2_.push(1,_loc3_);
				return _loc2_;
			default:
				_loc2_ = this.property();
				if(this.peek() === "++" || this.peek() === "--")
				{
					_loc3_ = this.consume();
					_loc2_[0] = this.getToSetToken(_loc2_[0]);
					_loc2_.push(1,_loc3_);
				}
				return _loc2_;
		}
	}
	function property()
	{
		var _loc2_ = this.singleton();
		var _loc3_;
		var _loc4_;
		var _loc5_;
		var _loc6_;
		var _loc7_;
		loop0:
		while(true)
		{
			switch(this.peek())
			{
				case ".":
				case ". ":
					_loc3_ = this.consume() === ". ";
					_loc4_ = this.peek().slice(0,2);
					if(_loc4_ !== "$v" && _loc4_ !== "$n")
					{
						this.wrongTokenError();
					}
					if(!_loc3_ && _loc2_ instanceof Array && _loc2_[0] === "$" && typeof _loc2_[1] === "string")
					{
						_loc2_[1] += "." + this.consume().slice(2);
					}
					else
					{
						_loc2_ = [".",_loc2_,this.consume().slice(2)];
					}
					break;
				case "[":
					this.consume();
					_loc2_ = [".",_loc2_,this.expression()];
					this.match("]");
					break;
				case "(":
					this.consume();
					_loc5_ = this.commaList();
					_loc6_ = ["(",_loc2_,_loc5_];
					if(_loc2_ instanceof Array)
					{
						if(_loc2_[0] === "$" && typeof _loc2_[1] === "string")
						{
							_loc7_ = _loc2_[1].lastIndexOf(".");
							if(_loc7_ !== -1)
							{
								_loc6_ = [".(",_loc2_,_loc2_[1].slice(_loc7_ + 1),_loc5_];
								_loc2_[1] = _loc2_[1].slice(0,_loc7_);
							}
							else
							{
								switch(_loc2_[1])
								{
									case "eval":
										_loc6_ = ["$",_loc5_[1]];
										break;
									case "set":
										_loc6_ = ["$=",_loc5_[1],_loc5_[2]];
										break;
									case "trace":
										_loc6_ = ["trace",_loc5_[1]];
								}
							}
						}
						else if(_loc2_[0] === ".")
						{
							_loc2_[0] = ".(";
							_loc2_.push(_loc5_);
							_loc6_ = _loc2_;
						}
					}
					_loc2_ = _loc6_;
					this.match(")");
					break;
				default:
					break loop0;
			}
		}
		return _loc2_;
	}
	function singleton()
	{
		var _loc2_;
		var _loc3_;
		if(this.peek() === "(")
		{
			this.consume();
			_loc2_ = this.expression();
			this.match(")");
		}
		else if(this.peek() === "[")
		{
			this.consume();
			_loc2_ = this.commaList();
			this.match("]");
		}
		else
		{
			switch(this.peek().slice(0,2))
			{
				case "$n":
					return Number(this.consume().slice(2));
				case "$s":
					return this.consume().slice(2);
				case "$v":
					_loc3_ = this.consume().slice(2);
					if(Parser.constObj.hasOwnProperty(_loc3_))
					{
						return Parser.constObj[_loc3_];
					}
					if(Code.playerVars.hasOwnProperty(_loc3_))
					{
						_loc3_ = "_root.game.player." + Code.playerVars[_loc3_];
					}
					else if(Parser.globalShortcuts.hasOwnProperty(_loc3_))
					{
						_loc3_ = Parser.globalShortcuts[_loc3_];
					}
					return ["$",_loc3_];
					break;
				default:
					this.wrongTokenError();
			}
		}
		return _loc2_;
	}
}
