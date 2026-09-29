class Windows
{
	var _parent;
	var text;
	static var clip;
	static var curDragging = null;
	static var curDragOfsX = 0;
	static var curDragOfsY = 0;
	function Windows()
	{
	}
	static function init()
	{
		Windows.clip = _root.window_clip;
		var w = Windows.clip.attachMovie("window","inputWindow",Windows.clip.getNextHighestDepth());
		w.init(10,335,{title:"Input string",customMinimize:function(w)
		{
			w.minimized = !w.minimized;
			if(w.inputField._visible = !w.minimized)
			{
				TAS.textRefresh = true;
			}
			w.updateMainField(false);
		}});
		w._static = true;
		w.createTextField("inputField",w.getNextHighestDepth(),0,20,530,20);
		w.inputField.background = true;
		w.inputField.type = "input";
		w._visible = false;
		w.createTextField("testField",w.getNextHighestDepth(),0,0,0,0);
		w.testField._visible = false;
		TAS.inputField = w.inputField;
		w.inputField.onKillFocus = function(newFocus)
		{
			TAS.loadInputs(TAS.lastCaretPos);
			TAS.lastCaretPos = -1;
		};
		w.inputField.onSetFocus = function(oldFocus)
		{
			TAS.frozen = true;
		};
		w.createTextField("offsetField",w.getNextHighestDepth(),0,40,530,20);
		w.offsetField.background = true;
		w.offsetField.type = "input";
		w.offsetField._visible = false;
		TAS.offsetField = w.offsetField;
		w.offsetField.onKillFocus = function(newFocus)
		{
			TAS.loadOffsets();
		};
		var w = Windows.clip.attachMovie("window","offsetBarsWindow",Windows.clip.getNextHighestDepth());
		w.init(10,200,{title:"Offset bars",customMinimize:function(w)
		{
			w.minimized = !w.minimized;
			w.barsWindow._visible = !w.minimized;
			w.updateMainField(false);
		}});
		w._static = true;
		w.createTextField("barsWindow",w.getNextHighestDepth(),0,20,40,20);
		w.barsWindow.background = true;
		w.barsWindow.setNewTextFormat(new TextFormat("Consolas",14,null,null,null,null,null,null,"center"));
		w.barsWindow.autoSize = true;
		w._visible = false;
		w = Windows.createWindow("watchWindow",485,150,{title:"Watch",customMinimize:function(w)
		{
			Windows.minimizeWindow(w);
			w.expField._visible = !w.minimized;
		},expressions:[],update:function(w)
		{
			w.obj.options = [];
			var _loc1_ = 0;
			var _loc2_;
			while(_loc1_ < w.obj.expressions.length)
			{
				_loc2_ = Code.interpret(w.obj.expressions[_loc1_]);
				if(_loc2_ instanceof CompilerError)
				{
					w.obj.options.push(null,[function(w, pos)
					{
						Selection.setFocus(w.expField);
						Selection.setSelection(pos,pos);
					},_loc2_.pos]);
					_loc2_ = "Error: " + _loc2_.message;
				}
				else
				{
					_loc2_ = String(_loc2_);
					w.obj.options.push(null,[Utils.setClipboard,_loc2_]);
				}
				if(Code.isS("\n",_loc2_) || Code.isS("\r",_loc2_))
				{
					_loc2_ = _loc2_.split("\n").join("\\n").split("\r").join("\\r");
				}
				w.obj.options[w.obj.options.length - 2] = _loc2_;
				_loc1_ = _loc1_ + 1;
			}
			w.updateMainField(false);
		}});
		w._visible = false;
		w._static = true;
		w.createTextField("expField",w.getNextHighestDepth(),-15,0,10,20);
		w.expField.background = true;
		w.expField.autoSize = "right";
		w.expField.type = "input";
		w.expField.text = "\r";
		w.expField.multiline = true;
		w.expField.setNewTextFormat(new TextFormat(null,null,null,null,null,null,null,null,"right"));
		w.expField.onKillFocus = function(newFocus)
		{
			var _loc3_ = this.text.split("\r");
			var _loc4_ = 0;
			this._parent.obj.expressions = [];
			var _loc5_ = 1;
			while(_loc5_ < _loc3_.length)
			{
				_loc4_ += _loc3_[_loc5_ - 1].length + 1;
				try
				{
					this._parent.obj.expressions.push(Code.compileValue(_loc3_[_loc5_]));
				}
				catch(err)
				{
					err.pos += _loc4_;
					this._parent.obj.expressions.push(err);
				}
				_loc5_ = _loc5_ + 1;
			}
		};
		w = Windows.clip.attachMovie("window","varWindow",Windows.clip.getNextHighestDepth());
		w.init(10,40,{title:"Vars",update:TAS.updateVarWindow});
		w._static = true;
		w._visible = false;
		var _loc2_ = 0;
		var _loc3_;
		while(_loc2_ < Utils.visWindowArray.length)
		{
			_loc3_ = Utils.visWindowArray[_loc2_];
			w = Windows.clip.attachMovie("window",_loc3_ + "VisWindow",Windows.clip.getNextHighestDepth());
			w.init(160 + 23 * _loc2_,7,{title:_loc3_,customMinimize:Utils.imgMinimize});
			w.createEmptyMovieClip("img",w.getNextHighestDepth());
			w.img._y = 20;
			Utils.bmps[_loc3_] = new flash.display.BitmapData(Utils.visWindowArray[_loc2_ + 1],Utils.visWindowArray[_loc2_ + 2],false);
			w.img.attachBitmap(Utils.bmps[_loc3_],w.img.getNextHighestDepth());
			w._static = true;
			w._visible = false;
			_loc2_ += 3;
		}
		w = Windows.clip.attachMovie("window","inputDisplay",Windows.clip.getNextHighestDepth());
		w.init(444,40,{title:"Input display",customMinimize:Utils.imgMinimize,update:function(w)
		{
			var _loc2_ = Utils.bmps.inputDisplay;
			var _loc3_ = Utils.inputDisplayParams;
			var _loc4_ = com.nitrome.toxic.Global;
			Utils.clearBitmap(_loc2_);
			var _loc5_ = 0;
			var _loc6_;
			var _loc7_;
			while(_loc5_ < 4)
			{
				_loc6_ = _loc3_.spacing + (_loc3_.size + _loc3_.spacing) * [0,2,1,1][_loc5_];
				_loc7_ = _loc5_ === 2 ? _loc3_.spacing : _loc3_.spacing * 2 + _loc3_.size;
				_loc2_.fillRect(new flash.geom.Rectangle(_loc6_,_loc7_,_loc3_.size,_loc3_.size),0);
				if(_loc5_ === 0 && _loc4_.DIR_PRESSED !== 0 || _loc5_ === 1 && _loc4_.DIR_PRESSED !== 1 || _loc5_ === 2 && !_loc4_.UP_PRESSED || _loc5_ === 3 && !_loc4_.DOWN_PRESSED)
				{
					_loc2_.fillRect(new flash.geom.Rectangle(_loc6_ + _loc3_.border,_loc7_ + _loc3_.border,_loc3_.size - _loc3_.border * 2,_loc3_.size - _loc3_.border * 2),16777215);
				}
				_loc5_ = _loc5_ + 1;
			}
			_loc6_ = _loc3_.spacing;
			_loc7_ = _loc3_.size * 2 + _loc3_.spacing * 3;
			var _loc8_ = _loc3_.size * 3 + _loc3_.spacing * 2;
			_loc2_.fillRect(new flash.geom.Rectangle(_loc6_,_loc7_,_loc8_,_loc3_.size),0);
			if(TAS.bombsThrownThisFrame === 0)
			{
				_loc2_.fillRect(new flash.geom.Rectangle(_loc6_ + _loc3_.border,_loc7_ + _loc3_.border,_loc8_ - _loc3_.border * 2,_loc3_.size - _loc3_.border * 2),16777215);
			}
			else
			{
				_loc5_ = 1;
				while(_loc5_ < TAS.bombsThrownThisFrame)
				{
					_loc2_.fillRect(new flash.geom.Rectangle(_loc6_ + _loc3_.border / 2 + (_loc8_ - _loc3_.border * 2) * _loc5_ / TAS.bombsThrownThisFrame,_loc7_ + _loc3_.border,_loc3_.border,_loc3_.size - _loc3_.border * 2),16777215);
					_loc5_ = _loc5_ + 1;
				}
			}
		}});
		w.createEmptyMovieClip("img",w.getNextHighestDepth());
		w.img._y = 20;
		Utils.bmps.inputDisplay = new flash.display.BitmapData(Utils.inputDisplayParams.size * 3 + Utils.inputDisplayParams.spacing * 4,Utils.inputDisplayParams.size * 3 + Utils.inputDisplayParams.spacing * 4,false);
		w.img.attachBitmap(Utils.bmps.inputDisplay,w.img.getNextHighestDepth());
		w._static = true;
		w._visible = false;
		w = Windows.clip.attachMovie("window","timerWindow",Windows.clip.getNextHighestDepth());
		w.init(29,7,{title:"00:00.000",update:Timer.updateTimerWindow,noMinimize:true});
		w.mainTextField.setNewTextFormat(new TextFormat("Consolas",18));
		w.mainTextField._height = 25;
		w._static = true;
		w._visible = true;
		_root.createTextField("nullField",_root.getNextHighestDepth(),0,0,0,0);
		_root.nullField._visible = false;
		Windows.clip.onMouseUp = function()
		{
			Windows.curDragging = null;
		};
		Windows.clip.onEnterFrame = Windows.update;
	}
	static function update()
	{
		if(Windows.curDragging)
		{
			Windows.curDragging._x = Math.max(0,Math.min(550,_xmouse)) + Windows.curDragOfsX;
			Windows.curDragging._y = Math.max(0,Math.min(400,_ymouse)) + Windows.curDragOfsY;
		}
		else
		{
			var focus = Selection.getFocus();
			if(focus.slice(0,19) == "_level0.window_clip" && focus.slice(focus.length - "mainTextField".length) == "mainTextField")
			{
				var w = Windows.clip[focus.slice(20,focus.length - "mainTextField".length - 1)];
				var ind = Selection.getBeginIndex();
				Windows.nullFocus();
				var i = w.mainIndices.length - 1;
				while(i >= 0)
				{
					if(ind >= w.mainIndices[i])
					{
						if(w.mainBehaviors[i])
						{
							Windows.windowFunction(w.mainBehaviors[i],w);
						}
						break;
					}
					i--;
				}
			}
		}
		for(i in Windows.clip)
		{
			if(Windows.clip[i].obj.update && Windows.clip[i]._visible && !Windows.clip[i].minimized)
			{
				Windows.windowFunction(Windows.clip[i].obj.update,Windows.clip[i]);
			}
		}
		Main.endFrame();
	}
	static function windowFunction(fun, w)
	{
		var _loc3_;
		if(fun instanceof Function)
		{
			fun(w);
		}
		else if(fun instanceof Array)
		{
			_loc3_ = fun[0];
			fun[0] = w;
			_loc3_.apply(null,fun);
			fun[0] = _loc3_;
		}
	}
	static function nullFocus()
	{
		Selection.setFocus(_root.nullField);
	}
	static function minimizeWindow(w)
	{
		w.minimized = !w.minimized;
		w.updateMainField(false);
	}
	static function closeWindow(w)
	{
		if(w._static)
		{
			w._visible = false;
		}
		else
		{
			w.removeMovieClip();
		}
	}
	static function startDragging(w)
	{
		Windows.curDragging = w;
		Windows.curDragOfsX = w._x - _xmouse;
		Windows.curDragOfsY = w._y - _ymouse;
		Windows.nullFocus();
	}
	static function scrollUp(w)
	{
		w.scroll = Math.max(0,w.scroll - 10);
		w.updateMainField(false);
	}
	static function scrollDown(w)
	{
		w.scroll = Math.min(w.obj.options.length / 2 - 19,w.scroll + 10);
		w.updateMainField(false);
	}
	static function createWindow(name, x, y, obj)
	{
		var _loc5_ = Windows.clip.attachMovie("window",name,Windows.clip.getNextHighestDepth());
		_loc5_.init(x,y,obj);
		return _loc5_;
	}
	static function createEmptyWindow(x, y)
	{
		return Windows.createWindow("window" + Windows.clip.getNextHighestDepth(),x,y,{title:""});
	}
}
