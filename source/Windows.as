/*
{
	type: "menu"/"",
	title: "Main Menu",
	mainTextField: ,
	inputTextField: 
	update: undefined/updateFunction
}
*/
class Windows
{
	static var clip;
	
	static var curDragging = null;
	
	static var curDragOfsX = 0;
	
	static var curDragOfsY = 0;
	
	static function init() {
		Windows.clip = _root.window_clip;
		
		// Input window
		
		var w = Windows.clip.attachMovie("window", "inputWindow", Windows.clip.getNextHighestDepth());
		w.init(10, 335, {
			title: "Input string",
			customMinimize: function(w) {
				w.minimized = !w.minimized;
				if (w.inputField._visible = !w.minimized) {
					TAS.textRefresh = true;
				}
				
				w.updateMainField(false);
			}
		});
		w._static = true;
		
		w.createTextField("inputField", w.getNextHighestDepth(), 0, 20, 530, 20);
		w.inputField.background = true;
		w.inputField.type = "input";
		w._visible = false;
		
		w.createTextField("testField", w.getNextHighestDepth(), 0, 0, 0, 0);
		w.testField._visible = false;
		
		TAS.inputField = w.inputField;
		
		w.inputField.onKillFocus = function(newFocus) {
			TAS.loadInputs(TAS.lastCaretPos);
			TAS.lastCaretPos = -1;
		}
		
		w.inputField.onSetFocus = function(oldFocus) {
			TAS.frozen = true;
		}
		
		w.createTextField("offsetField", w.getNextHighestDepth(), 0, 40, 530, 20);
		w.offsetField.background = true;
		w.offsetField.type = "input";
		w.offsetField._visible = false;
		
		TAS.offsetField = w.offsetField;
		
		w.offsetField.onKillFocus = function(newFocus) {
			TAS.loadOffsets();
		}
		
		// Offset window
		
		var w = Windows.clip.attachMovie("window", "offsetBarsWindow", Windows.clip.getNextHighestDepth());
		w.init(10, 200, {
			title: "Offset bars",
			customMinimize: function(w) {
				w.minimized = !w.minimized;
				w.barsWindow._visible = !w.minimized;
				w.updateMainField(false);
			}
		});
		w._static = true;
		
		w.createTextField("barsWindow", w.getNextHighestDepth(), 0, 20, 40, 20);
		w.barsWindow.background = true;
		w.barsWindow.setNewTextFormat(new TextFormat("Consolas", 14, null, null, null, null, null, null, "center"));
		w.barsWindow.autoSize = true;
		w._visible = false;
		
		// Watch window
		
		w = Windows.createWindow("watchWindow", 485, 150, {
			title: "Watch",
			customMinimize: function(w) {
				Windows.minimizeWindow(w);
				w.expField._visible = !w.minimized;
			},
			expressions: [],
			update: function(w) {
				w.obj.options = [];
				for (var i = 0; i < w.obj.expressions.length; i++) {
					var str = String(Code.interpret(w.obj.expressions[i]));
					
					w.obj.options.push(null, [Utils.setClipboard, str]);
					
					if (Code.isS("\n", str) || Code.isS("\r", str)) {
						str = str.split("\n").join("\\n").split("\r").join("\\r");
					}
					
					w.obj.options[w.obj.options.length - 2] = str;
				}
				w.updateMainField(false);
			}
		});
		w._visible = false;
		w._static = true;
		
		w.createTextField("expField", w.getNextHighestDepth(), -15, 0, 10, 20);
		w.expField.background = true;
		w.expField.autoSize = "right";
		w.expField.type = "input";
		w.expField.text = "\r";
		w.expField.multiline = true;
		w.expField.setNewTextFormat(new TextFormat(null, null, null, null, null, null, null, null, "right"));
		
		w.expField.onKillFocus = function(newFocus) {
			var arr = this.text.split("\r");
			
			this._parent.obj.expressions = [];
			for (var i = 1; i < arr.length; i++) {
				try {
					this._parent.obj.expressions.push(Code.compileValue(arr[i]));
				} catch (err) {
					this._parent.obj.expressions.push("");
				}
			}
		}
		
		// Var window
		
		w = Windows.clip.attachMovie("window", "varWindow", Windows.clip.getNextHighestDepth());
		w.init(10, 40, {title: "Vars", update: TAS.updateVarWindow});
		w._static = true;
		w._visible = false;
		
		// Visualization windows
		
		var i = 0;
		while (i < Utils.visWindowArray.length) {
			var n = Utils.visWindowArray[i];
			
			w = Windows.clip.attachMovie("window", n + "VisWindow", Windows.clip.getNextHighestDepth());
			
			w.init(160 + 23*i, 7, {
				title: n,
				customMinimize: Utils.imgMinimize
			});
			
			w.createEmptyMovieClip("img", w.getNextHighestDepth());
			w.img._y = 20;
			Utils.bmps[n] = new flash.display.BitmapData(Utils.visWindowArray[i+1], Utils.visWindowArray[i+2], false);
			w.img.attachBitmap(Utils.bmps[n], w.img.getNextHighestDepth());
			w._static = true;
			w._visible = false;
			i += 3;
		}
		
		// Input display
		
		w = Windows.clip.attachMovie("window", "inputDisplay", Windows.clip.getNextHighestDepth());
		
		w.init(444, 40, {
			title: "Input display",
			customMinimize: Utils.imgMinimize,
			update: function(w) {
				var bmp = Utils.bmps.inputDisplay;
				var p = Utils.inputDisplayParams;
				var g = com.nitrome.toxic.Global;
				Utils.clearBitmap(bmp);
				
				for (var i = 0; i < 4; i++) {
					var curX = p.spacing + (p.size + p.spacing) * [0, 2, 1, 1][i];
					var curY = (i === 2)? p.spacing : p.spacing * 2 + p.size;
					bmp.fillRect(new flash.geom.Rectangle(curX, curY, p.size, p.size), 0);
					if (i === 0 && g.DIR_PRESSED !== 0 || i === 1 && g.DIR_PRESSED !== 1 || i === 2 && !g.UP_PRESSED || i === 3 && !g.DOWN_PRESSED) {
						bmp.fillRect(new flash.geom.Rectangle(curX + p.border, curY + p.border, p.size - p.border * 2, p.size - p.border * 2), 0xFFFFFF);
					}
				}
				
				var curX = p.spacing;
				var curY = p.size * 2 + p.spacing * 3;
				var curW = p.size * 3 + p.spacing * 2;
				
				bmp.fillRect(new flash.geom.Rectangle(curX, curY, curW, p.size), 0);
				if (TAS.bombsThrownThisFrame === 0) {
					bmp.fillRect(new flash.geom.Rectangle(curX + p.border, curY + p.border, curW - p.border * 2, p.size - p.border * 2), 0xFFFFFF);
				} else {
					for (var i = 1; i < TAS.bombsThrownThisFrame; i++) {
						bmp.fillRect(new flash.geom.Rectangle(curX + p.border / 2 + (curW - p.border * 2) * i / TAS.bombsThrownThisFrame, curY + p.border, p.border, p.size - p.border * 2), 0xFFFFFF);
					}
				}
			}
		});
		
		w.createEmptyMovieClip("img", w.getNextHighestDepth());
		w.img._y = 20;
		Utils.bmps.inputDisplay = new flash.display.BitmapData(Utils.inputDisplayParams.size * 3 + Utils.inputDisplayParams.spacing * 4, Utils.inputDisplayParams.size * 3 + Utils.inputDisplayParams.spacing * 4, false);
		w.img.attachBitmap(Utils.bmps.inputDisplay, w.img.getNextHighestDepth());
		w._static = true;
		w._visible = false;
		
		// Timer window
		
		w = Windows.clip.attachMovie("window", "timerWindow", Windows.clip.getNextHighestDepth());
		w.init(29, 7, {title: "00:00.000", update: Timer.updateTimerWindow, noMinimize: true});
		w.mainTextField.setNewTextFormat(new TextFormat("Consolas", 18));
		w.mainTextField._height = 25;
		w._static = true;
		w._visible = true;
		
		// Null field
		
		_root.createTextField("nullField", _root.getNextHighestDepth(), 0, 0, 0, 0);
		_root.nullField._visible = false;
		
		Windows.clip.onMouseUp = function() {
			Windows.curDragging = null;
		};
		
		Windows.clip.onEnterFrame = Windows.update;
	}
	
	static function update() {
		if (Windows.curDragging) {
			Windows.curDragging._x = Math.max(0, Math.min(550, _xmouse)) + Windows.curDragOfsX;
			Windows.curDragging._y = Math.max(0, Math.min(400, _ymouse)) + Windows.curDragOfsY;
			//Windows.nullFocus();
		} else {
			var focus = Selection.getFocus();
			if (focus.slice(0, 19) == "_level0.window_clip" && focus.slice(focus.length - "mainTextField".length) == "mainTextField") {
				var w = Windows.clip[focus.slice(20, focus.length - "mainTextField".length - 1)];
				var ind = Selection.getBeginIndex();
				Windows.nullFocus();
				
				var i = w.mainIndices.length - 1;
				while (i >= 0) {
					if (ind >= w.mainIndices[i]) {
						if (w.mainBehaviors[i]) {
							Windows.windowFunction(w.mainBehaviors[i], w);
						}
						break;
					}
					i--;
				}
			}
		}
		
		for (i in Windows.clip) {
			if (Windows.clip[i].obj.update && Windows.clip[i]._visible && !Windows.clip[i].minimized) {
				Windows.windowFunction(Windows.clip[i].obj.update, Windows.clip[i]);
			}
		}
		
		Main.endFrame();
	}
	
	static function windowFunction(fun, w) {
		if (fun instanceof Function) {
			fun(w);
		} else if (fun instanceof Array) {
			var fun1 = fun[0];
			fun[0] = w;
			fun1.apply(null, fun);
			fun[0] = fun1;
		}
	}
	
	static function nullFocus() {
		Selection.setFocus(_root.nullField);
		//Selection.setSelection(0,0);
	}
	
	static function minimizeWindow(w) {
		w.minimized = !w.minimized;
		w.updateMainField(false);
	}
	
	static function closeWindow(w) {
		if (w._static) {
			w._visible = false;
		} else {
			w.removeMovieClip();
		}
	}
	
	static function startDragging(w) {
		Windows.curDragging = w;
		Windows.curDragOfsX = w._x - _xmouse;
		Windows.curDragOfsY = w._y - _ymouse;
		Windows.nullFocus();
	}
	
	static function scrollUp(w) {
		w.scroll = Math.max(0, w.scroll - 10);
		w.updateMainField(false);
	}
	
	static function scrollDown(w) {
		w.scroll = Math.min(w.obj.options.length / 2 - 19, w.scroll + 10);
		w.updateMainField(false);
	}
	
	static function createWindow(name, x, y, obj) {
		var w = Windows.clip.attachMovie("window", name, Windows.clip.getNextHighestDepth());
		w.init(x, y, obj);
		return w;
	}
	
	static function createEmptyWindow(x, y) {
		return Windows.createWindow("window" + Windows.clip.getNextHighestDepth(), x, y, {title: ""});
	}
}