class TAS
{
	static var write = true;
	static var override = true;
	static var frozen = false;
	static var curString = "60";
	
	static var curIndex = 0;
	static var curFrame = 0;
	
	static var totalFrame = 0;
	static var totalLength = 0;
	
	static var inputArray = ["i"];
	static var valueArray = [0];
	static var indArray = [-1];
	static var endIndArray = [2];
	static var codeObj = {};
	static var ghostData = [];
	static var beginningFrames = 60;
	
	static var fastPlayback = false;
	static var saveStates = [];
	static var ghostVisible = [];
	static var justPlacedBombs;
	static var justPause;
	static var pressedPause;
	static var releasedUp;
	static var pressedHit;
	static var queuedHit = false;
	static var bombsThrownThisFrame = 0;
	
	static var inputField;
	static var targetFrame = -Infinity;
	static var delayedCaretPos = -1;
	static var lastCaretPos = -1;
	static var delayedFun = null;
	
	static var offsetField;
	static var offsetString = "";
	static var curPattern = 0;
	static var curPatternInd = 0;
	static var curPatternFrame = 0;
	static var offsetSetup = [0, 0, false, []];
	static var offsetArr = [];
	static var offsetObj = {};
	static var initOffsetInd = -1;
	static var offsetCodeObj = {};
	
	static var inputFieldError = null;
	static var offsetFieldError = null;
	
	static var UP_PRESSED = false;
	static var DOWN_PRESSED = false;
	
	static var subLetters = "rbjJPh";
	static var fullLetters = "qweasdQWEADnp";
	static var letters = TAS.subLetters + TAS.fullLetters;
	static var symbols = TAS.letters + "|<>,.{";
	
	static var keysDown = {};
	static var importantKeycodes = TAS.getImportantKeycodes();
	
	static var textRefresh = false;
	
	static function getImportantKeycodes() {
		var obj = {};
		var arr = [37, 38, 39, 40, 87, 65, 83, 68, 32];
		for (var i in arr) {
			obj[arr[i]] = true;
		}
		return obj;
	}

	static function updateVarWindow(w) {
		var p = _root.game.player;
		w.obj.options = [
			"x: " + p._x, false,
			"y: " + p._y, false,
			"vx: " + p.vx, false,
			"vy: " + p.vy, false,
			"wc: " + p.wall_count, false,
			"hc: " + p.hit_count, false,
			"st: " + ["start", "stand", "duck", "walk", "jump", "fall", "wall", "hit", "die", "end"][p.state], false,
			"dir: " + ["l", "r"][p.dir], false
		];
		
		w.updateMainField(false);
	}
	
	static function isAtStringEnd() {
		return TAS.totalFrame >= TAS.totalLength;
	}
	
	static function isS(sym, str) {
		return str.indexOf(sym) !== -1;
	}
	
	static function isSubLetter(let) {
		return TAS.isS(let, TAS.subLetters) || let.charAt(0) === "{";
	}
	
	static function isFullLetter(let) {
		return TAS.isS(let, TAS.fullLetters);
	}
	
	static function isLetter(let) {
		return TAS.isS(let, TAS.letters);
	}
	
	static function isSymbol(let) {
		return TAS.isS(let, TAS.symbols);
	}
	
	static function isKeyLetter(let) {
		return TAS.isS(let, "wasdWASDlruvLRUVbB");
	}
	
	static function compact(num) {
		return (num == 1)? "" : num;
	}
	
	static function clearOffsets(arr) {
		for (var i = 3; i < arr.length; i += 4) {
			arr[i] = 0;
		}
	}
	
	static function scrollToCaret() {
		var caretInd;
		
		if (TAS.isAtStringEnd()) {
			caretInd = TAS.curString.length;
		} else if (TAS.curFrame == TAS.valueArray[TAS.curIndex]) {
			caretInd = TAS.indArray[TAS.curIndex + 1];
		} else {
			caretInd = TAS.indArray[TAS.curIndex];
		}
		
		Selection.setFocus(TAS.inputField);
		Selection.setSelection(caretInd, caretInd);
		Windows.nullFocus();
	}

	static function doKeyDown(code) {
		if (TAS.doTasKeyDown(code)) {
			return;
		}
		
		if (Utils.doKeyDown(code)) {
			return;
		}
		
		if (TAS.write || true) {
			if (code == 38 || code == 87) {
				TAS.UP_PRESSED = true;
			} else if (code == 40 || code == 83) {
				TAS.DOWN_PRESSED = true;
			} else if (code == 37 || code == 65) {
				com.nitrome.toxic.Global.LAST_DIR_PRESSED = com.nitrome.toxic.Global.LEFT;
			} else if (code == 39 || code == 68) {
				com.nitrome.toxic.Global.LAST_DIR_PRESSED = com.nitrome.toxic.Global.RIGHT;
			} else if (code == 32 || code == 66) {
				if (!TAS.justPause) {
					TAS.justPlacedBombs++;
				}
			} else if (code == 78) {
				if (TAS.justPlacedBombs > 0) {
					TAS.justPlacedBombs--;
				}
			} else if (code == 80) {
				TAS.justPause = !TAS.justPause;
				TAS.pressedPause = true;
			} else if (code == 72) {
				TAS.pressedHit = !TAS.pressedHit;
			}
			
			if (TAS.importantKeycodes[code]) {
				if (!TAS.keysDown[code] && TAS.write) {
					TAS.hitOffset(code);
				}
				TAS.keysDown[code] = true;
			}
		}
	}
	
	static function doKeyUp(code) {
		if (Utils.foif()) {
			return;
		}
		
		if (code == 38 || code == 87) {
			TAS.releasedUp = true;
			TAS.UP_PRESSED = false;
		} else if (code == 40 || code == 83) {
			TAS.DOWN_PRESSED = false;
		}
		
		if (TAS.importantKeycodes[code]) {
			if (TAS.write) {
				TAS.hitOffset(-code);
			}
			TAS.keysDown[code] = false;
		}
	}

	static function doTasKeyDown(code) {
		
		if (Utils.foif()) {
			if (TAS.foif()) {
				if (code == 27 || code == 112) { //Esc F1
					Windows.nullFocus();
				} else if (code == 34) { //PgDn
					TAS.delayedCaretPos = Selection.getCaretIndex();
					TAS.loadInputs(Selection.getCaretIndex());
				} else if (code == 33 || code == 123) { //PgUp F12
					TAS.lastCaretPos = Selection.getCaretIndex();
					Windows.nullFocus();
				} else if (code == 13) { //Enter
					TAS.loadInputs(-1);
				}
			} else if (code == 27 || code == 112) { //Esc F1
				Windows.nullFocus();
			}
			return true;
		}
		
		var i;
		if (code == 113) { //F2
			_root.popup_holder.clip.key_button.clearKeyListener();
			_root.mc.startMenuMusic(false);
			//TAS.curIndex = 0;
			//TAS.curFrame = TAS.valueArray[0];
			
			if(!_root.game.level_number) {
				_root.tt.doTween("title_screen");
			} else {
				_root.tt.doTween("map");
			}
		} else if (code == 86) { //v
			Windows.clip.varWindow._visible = !Windows.clip.varWindow._visible;
		} else if (code == 73) { //i
			if (Windows.clip.inputWindow._visible = !Windows.clip.inputWindow._visible) {
				TAS.textRefresh = true;
			}
			//Windows.nullFocus();
		} else if (code === 79) { //o
			Windows.clip.inputWindow._visible = true;
			TAS.textRefresh = true;
			
			TAS.offsetField._visible = !TAS.offsetField._visible;
			if (TAS.offsetField._visible) {
				Windows.clip.offsetBarsWindow._visible = true;
			}
		} else if (code == 84) { //t
			Windows.clip.timerWindow._visible = !Windows.clip.timerWindow._visible;
		} else if (code == 191 || code == 222) { /// '
			TAS.write = code == 191;
			TAS.frozen = !TAS.frozen;
			TAS.override = !Key.isDown(16);
		} else if (code == 190 || code == 186 || code == 75) { //. ; k
			if (code != 75)
				TAS.frozen = true;
			TAS.write = code == 190;
			
			i = (code == 75)? 30 : 1;
			if (TAS.write) {
				TAS.override = !Key.isDown(16);
			} else if (Key.isDown(16)) {
				i *= 5;
			}
			
			if (TAS.write) {
				Main.gameUpdate();
				Main.stopAll();
			} else {
				TAS.skipToFrame(Math.min(TAS.totalFrame + i, TAS.totalLength));
			}
		} else if (code == 188 || code == 76 || code == 74) { //, l j
			if (code != 74)
				TAS.frozen = true;
			TAS.write = code == 188;
			
			i = (code == 74)? 30 : 1;
			if (Key.isDown(16)) {
				i *= 5;
			}
			
			if (TAS.totalFrame > -TAS.beginningFrames) {
				if (TAS.write)
					TAS.delayedFun = function() {
						TAS.truncateCurArray();
						TAS.textRefresh = true;
					};
				
				TAS.targetFrame = Math.max(-TAS.beginningFrames, TAS.totalFrame - i);
				_root.tt.doTween("reload");
			}
			
		} else if (code == 220) { //|
			TAS.scrollToCaret();
		} else if (code == 46) { //Delete
			if (Key.isDown(16)) {
				TAS.splitCurLetter();
			} else {
				TAS.truncateCurArray();
			}
			TAS.textRefresh = true;
		} else if (code == 82) { //r
			//TAS.curIndex = 0;
			//TAS.curFrame = TAS.valueArray[0];
			//write = false;
			//frozen = false;
			_root.tt.doTween("reload");
		} else if (code >= 48 && code <= 57) { //0..9
			var state = TAS.saveStates[code-48];
			if (Key.isDown(16)) { //Shift
				if (Key.isDown(17) && state) {
					var ghostName = "g" + (code-48);
					if (_root.game.ghost_holder[ghostName]) {
						_root.game.ghost_holder[ghostName].removeMovieClip();
						TAS.ghostVisible[code-48] = false;
					} else {
						TAS.addGhost(code-48);
						TAS.ghostVisible[code-48] = true;
					}
				} else {
					TAS.updateText(true);
					TAS.saveStates[code-48] = {
						inputText: TAS.inputField.text,
						codeObj: TAS.codeObj,
						ghostData: TAS.ghostData.concat()
					};
				}
			} else if (state) {
				TAS.inputField.text = state.inputText;
				TAS.codeObj = state.codeObj;
				//TAS.ghostData = state.ghostData.concat();
				TAS.loadInputs(Key.isDown(17)? -2 : -1);
			}
		} else {
			return false;
		}
		return true;
	}

	static function truncateCurArray() {
		if (TAS.isAtStringEnd())
			return;
		
		TAS.inputArray.length = TAS.curIndex + 1;
		TAS.valueArray.length = TAS.curIndex + 1;
		TAS.indArray.length = TAS.curIndex + 1;
		TAS.endIndArray.length = TAS.curIndex + 1;
		
		TAS.totalLength = TAS.totalFrame;
		
		TAS.valueArray[TAS.curIndex] = TAS.curFrame;
		if (TAS.curIndex == 0) {
			TAS.curString = TAS.curString.slice(0, TAS.endIndArray[0]);
		} else {
			TAS.curString = TAS.curString.slice(0, TAS.indArray[TAS.curIndex]) + TAS.inputArray[TAS.curIndex] + TAS.compact(TAS.curFrame);
		}
	}
	
	static function splitCurLetter() {
		if (TAS.curFrame == TAS.valueArray[TAS.curIndex])
			return;
		
		TAS.inputArray.splice(TAS.curIndex + 1, 0, TAS.inputArray[TAS.curIndex]);
		TAS.valueArray.splice(TAS.curIndex + 1, 0, TAS.valueArray[TAS.curIndex]-TAS.curFrame);
		
		TAS.valueArray[TAS.curIndex] = TAS.curFrame;
		
		var newString = TAS.curString.slice(0, TAS.indArray[TAS.curIndex]) + (TAS.inputArray[TAS.curIndex] + TAS.compact(TAS.curFrame));
		
		TAS.indArray.splice(TAS.curIndex + 1, 0, newString.length);
		
		newString += TAS.inputArray[TAS.curIndex+1] + TAS.compact(TAS.valueArray[TAS.curIndex+1]);
		
		TAS.endIndArray.splice(TAS.curIndex + 1, 0, newString.length);
		
		newString += TAS.curString.slice(TAS.endIndArray[TAS.curIndex]);
		
		var i = TAS.curIndex + 2;
		while (i < TAS.inputArray.length) {
			TAS.indArray[i] += TAS.endIndArray[TAS.curIndex+1] - TAS.endIndArray[TAS.curIndex];
			TAS.endIndArray[i] += TAS.endIndArray[TAS.curIndex+1] - TAS.endIndArray[TAS.curIndex];
			i++;
		}
		
		TAS.endIndArray[TAS.curIndex] = TAS.indArray[TAS.curIndex+1];
		
		TAS.curString = newString;
	}

	static function parseInputString(str, caretPos, codeObj) {
		var newInputArray = ["i"];
		var newValueArray = [0];
		var newIndArray = [-1];
		var newEndIndArray = [0];
		var newString = str;
		var beginningFrames = 0;
		
		var barFrame = -Infinity;
		var caretFrame = -Infinity;
		var useCaretPos = caretPos >= 0;
		
		if (!codeObj) codeObj = {};
		var newCodeObj = {};
		
		var offsetSetup = [0, 0, false, []]; //start frame, length, diff obj, offset array
		
		var totalFrame = 0;
		
		var commaNum = -1;
		
		var prevFullLetter = "n";
		
		var firstError = null;
		
		var i = -1;
		
		while (i < newString.length) {
			
			var symbol = i === -1? "" : newString.charAt(i);
			var pos = i;
			var num = 0;
			
			var linNum = 0;
			var dotLetter = "";
			var patternDiff = false;
			
			var codeStr = "";
			
			i++;
			if (symbol === "<") {
				try {
					var ret = Code.parseAngled(newString, i);
					i = ret[1];
					patternDiff = ret[0];
				} catch (err) {
					if (!firstError) {
						firstError = err;
					}
					i = newString.indexOf(">", i) + 1;
					if (i === 0) {
						break;
					}
				}
			} else if (symbol === "{") {
				var codeEnd = -1;
				try {
					codeEnd = Code.getCodeBlockEnd(newString, i);
				} catch (err) {
					if (!firstError) {
						firstError = err;
					}
					
					break;
				}
				
				codeStr = newString.slice(i - 1, codeEnd + 1);
				
				if (codeObj.hasOwnProperty(codeStr)) {
					newCodeObj[codeStr] = codeObj[codeStr];
				} else {
					
					try {
						newCodeObj[codeStr] = Code.compile(newString, i, codeEnd);
					} catch (err) {
						if (!firstError) {
							firstError = err;
						}
					}
				}
				
				i = codeEnd + 1;
			}
			
			var endPos = i;
			
			while (i < newString.length) {
				var curSymbol = newString.charAt(i);
				
				if (newString.charCodeAt(i) >= 48 && newString.charCodeAt(i) <= 57) {
					num = num * 10 + newString.charCodeAt(i) - 48;
					endPos = i + 1;
				} else if (symbol === "." && !dotLetter) {
					if (TAS.isKeyLetter(curSymbol)) {
						dotLetter = curSymbol;
					} else if (curSymbol === ".") {
						linNum += num? num : 1;
						num = 0;
					}
				} else if (symbol === "," && curSymbol === ",") {
					linNum += num? num : 1;
					num = 0;
				} else if (TAS.isSymbol(curSymbol)) {
					break;
				}
				
				i++;
			}
			
			if (!TAS.isS(symbol, "|<>r") && !num) {
				num = 1;
			}
			num += linNum;
			
			if (symbol === "") {
				beginningFrames = Math.min(num, 109);
				totalFrame = -beginningFrames;
				newEndIndArray[0] = endPos;
			} else if (symbol == "|") {
				barFrame = totalFrame + num;
				i -= endPos - pos;
				caretPos -= endPos - pos;
				newString = newString.slice(0, pos) + newString.slice(endPos);
			} else if (TAS.isS(symbol, "<>")) {
				offsetSetup.push(totalFrame, num, patternDiff, []);
			} else if (symbol === ".") {
				if (dotLetter) {
					var letterNum = {w: 87, a: 65, s: 83, d: 68, u: 38, l: 37, v: 40, r: 39, b: 32}[dotLetter.toLowerCase()];
					if (dotLetter !== dotLetter.toLowerCase()) {
						letterNum *= -1;
					}
					Utils.pushO(offsetSetup, totalFrame, letterNum, num);
				}
			} else if (symbol === ",") {
				commaNum = num;
			} else {
				if (newInputArray.length == 1 && newIndArray[0] == -1 && symbol == "r") {
					newValueArray[0] = num;
					newIndArray[0] = pos;
					newEndIndArray[0] = endPos;
				} else {
					if (symbol === "{") {
						newInputArray.push(codeStr);
					} else {
						newInputArray.push(symbol);
					}
					newValueArray.push(num);
					newIndArray.push(pos);
					newEndIndArray.push(endPos);
				}
				
				if (caretFrame == -Infinity && caretPos < endPos) {
					caretFrame = totalFrame;
				}
				
				if (TAS.isFullLetter(symbol)) {
					if (commaNum !== -1) {
						if (prevFullLetter === "p") {
							if (symbol !== "p") {
								Utils.pushO(offsetSetup, totalFrame, 6, commaNum);
							}
						} else if (symbol === "p") {
							Utils.pushO(offsetSetup, totalFrame, 7, commaNum);
						} else {
							var inpStates = [];
							for (var j = 0; j < 2; j++) {
								var letterNum = "nadwqesADWQE".indexOf([prevFullLetter, symbol][j]);
								inpStates.push(letterNum % 3 - 1, letterNum % 6 >= 3, letterNum >= 6);
							}
							
							for (var j = 0; j < 3; j++) {
								if (inpStates[j] !== inpStates[3 + j]) {
									Utils.pushO(offsetSetup, totalFrame, j? 2*j + (inpStates[3 + j]? 1 : 0) : inpStates[3 + j], commaNum);
								}
							}
						}
						
						commaNum = -1;
					}
					
					prevFullLetter = symbol;
					totalFrame += num;
				}
			}
		}
		
		if (TAS.isSubLetter(newInputArray[newInputArray.length-1])) {
			var insertionPoint = newEndIndArray[newEndIndArray.length-1];
			
			newInputArray.push("n");
			newValueArray.push(1);
			newIndArray.push(insertionPoint);
			newEndIndArray.push(insertionPoint + 1);
			newString = newString.slice(0, insertionPoint) + "n" + newString.slice(insertionPoint);
			totalFrame++;
		}
		
		var newFrame = useCaretPos? caretFrame : Math.min(barFrame, totalFrame);
		
		if (newFrame === -Infinity) {
			newFrame = totalFrame;
		}
		
		return {
			inputArray: newInputArray,
			valueArray: newValueArray,
			indArray: newIndArray,
			endIndArray: newEndIndArray,
			curString: newString,
			totalFrame: newFrame,
			totalLength: totalFrame,
			beginningFrames: beginningFrames,
			offsetSetup: offsetSetup,
			err: firstError,
			codeObj: newCodeObj
		};
	}
	
	static function loadInputs(caretPos) {
		var obj = TAS.parseInputString(TAS.inputField.text, caretPos, TAS.codeObj);
		
		if (caretPos === -2) {
			obj.totalFrame = Math.max(-obj.beginningFrames, Math.min(TAS.totalFrame, obj.totalLength));
		}
		
		var areEqual = true;
		
		if (TAS.totalFrame <= obj.totalFrame && TAS.beginningFrames === obj.beginningFrames && TAS.valueArray[0] === obj.valueArray[0]) {
			
			var totalFrame = -TAS.beginningFrames;
			for (var ind = 1; totalFrame < TAS.totalFrame; ind++) {
				if (TAS.isFullLetter(TAS.inputArray[ind])) {
					totalFrame += TAS.valueArray[ind];
				}
				
				if (TAS.inputArray[ind] != obj.inputArray[ind] || TAS.valueArray[ind] != obj.valueArray[ind] && !(totalFrame >= TAS.totalFrame && totalFrame - TAS.valueArray[ind] + obj.valueArray[ind] >= TAS.totalFrame)) {
					areEqual = false;
					break;
				}
			}

		} else {
			areEqual = false;
		}
		
		TAS.updateBase(obj, areEqual);
	}
	
	static function updateBase(obj, areEqual) {
		TAS.inputArray = obj.inputArray;
		TAS.valueArray = obj.valueArray;
		TAS.indArray = obj.indArray;
		TAS.endIndArray = obj.endIndArray;
		TAS.codeObj = obj.codeObj;
		
		TAS.curString = obj.curString;
		TAS.totalLength = obj.totalLength;
		TAS.beginningFrames = obj.beginningFrames;
		
		if (!areEqual) {
			TAS.delayedFun = [TAS.updateError, obj.err, TAS.inputField];
			
			TAS.targetFrame = obj.totalFrame;
			_root.tt.doTween("reload");
		} else {
			TAS.skipToFrame(obj.totalFrame);
			TAS.textRefresh = true;
			
			TAS.updateError(obj.err, TAS.inputField);
		}
	}
	
	static function loadOffsets() {
		if (TAS.offsetString === TAS.offsetField.text) {
			return;
		}
		
		var obj = TAS.parseInputString(TAS.offsetField.text, -1, TAS.offsetCodeObj);
		
		TAS.offsetField.text = obj.curString;
		TAS.offsetString = obj.curString;
		
		TAS.offsetSetup = obj.offsetSetup;
		TAS.offsetObj = {};
		TAS.offsetArr = [];
		TAS.offsetCodeObj = obj.codeObj;
		
		if (TAS.offsetSetup.length > 4) {
			obj.totalFrame = obj.totalLength;
			
			TAS.initOffsetInd = 4;
			
			TAS.updateBase(obj, false);
		} else {
			TAS.updateOffsetBars();
		}
		
		TAS.updateError(obj.err, TAS.offsetField);
	}
	
	static function updateOffsetBars() {
		var w = Windows.clip.offsetBarsWindow.barsWindow;
		w.text = "";
		
		for (var i = 3; i < TAS.offsetSetup.length; i += 4) {
			var curP = TAS.offsetSetup[i];
			var curText = "";
			for (var j = 0; j < curP.length; j += 4) {
				var curPos = 1;
				var curNum = curP[j + 3];
				for (var k = 0; k < 5; k++) {
					if (curNum & curPos) {
						curText += /*"🞅"*/"O";
					} else {
						curText += "-";
					}
					curPos <<= 1;
				}
				
				for (var k = 0; k < curP[j + 2]; k++) {
					if (curNum & curPos) {
						curText += /*"🞑"*/"■"/*█▮◾⬛▬⏹*/;
					} else {
						curText += "□";
					}
					curPos <<= 1;
				}
				
				for (var k = 0; k < 5; k++) {
					if (curNum & curPos) {
						curText += /*"🞅"*/"O";
					} else {
						curText += "-";
					}
					curPos <<= 1;
				}
				
				curText += "\n";
			}
			
			w.text = w.text + curText;
		}
		
		w.text = w.text.slice(0, -1);
	}

	static function updateText(forced) {
		TAS.textRefresh = false;
		
		if (!forced && (!Windows.clip.inputWindow._visible || !TAS.inputField._visible)) {
			return;
		}
		
		var firstHalf = "";
		
		if (TAS.isAtStringEnd()) {
			TAS.inputField.text = firstHalf = TAS.curString;
		} else if (TAS.curFrame == TAS.valueArray[TAS.curIndex]) {
			firstHalf = TAS.curString.slice(0, TAS.indArray[TAS.curIndex+1]);
			TAS.inputField.text = firstHalf + "|" + TAS.curString.slice(TAS.indArray[TAS.curIndex+1]);
		} else {
			firstHalf = TAS.curString.slice(0, TAS.indArray[TAS.curIndex]);
			TAS.inputField.text = firstHalf + "|" + TAS.curFrame + TAS.curString.slice(TAS.indArray[TAS.curIndex]);
		}
		
		if (Utils.autoScroll) {
			Windows.clip.inputWindow.testField.text = firstHalf;
			
			TAS.inputField.hscroll = (Windows.clip.inputWindow.testField.textWidth - 225) * TAS.inputField.maxhscroll / (TAS.inputField.textWidth - 395);
		}
	}
	
	static function updateError(err, field) {
		var w = Windows.clip.inputWindow;
		
		if (field === TAS.inputField) {
			TAS.inputFieldError = err;
		} else if (field === TAS.offsetField) {
			TAS.offsetFieldError = err;
		}
		
		if (err && Selection.getFocus() === String(field)) {
			var pos = err.pos;
			
			if (field === TAS.inputField && !TAS.isAtStringEnd()) {
				if (TAS.curFrame === TAS.valueArray[TAS.curIndex]) {
					pos += pos >= TAS.indArray[TAS.curIndex + 1]? 1 : 0;
				} else {
					pos += pos >= TAS.indArray[TAS.curIndex]? 1 + String(TAS.curFrame).length : 0;
				}
			}
			
			Selection.setSelection(pos, pos);
		}
		
		var activeErr = TAS.offsetFieldError || TAS.inputFieldError;
		if (activeErr) {
			
			w.obj.headerOptions = [
				"Error: " + activeErr.message,
				TAS.offsetFieldError?
				function(w) {
					Selection.setFocus(TAS.offsetField);
					Selection.setSelection(TAS.offsetFieldError.pos, TAS.offsetFieldError.pos);
				}
				:
				function(w) {
					Selection.setFocus(TAS.inputField);
					TAS.loadInputs(-1);
				}
			];
			
			w.updateMainField(false);
			
		} else if (delete w.obj.headerOptions) {
			w.updateMainField(false);
		}
		
		field.backgroundColor = err? 0xFFCCCC : 0xFFFFFF;
	}

	static function foif() {
		return Selection.getFocus() == "_level0.window_clip.inputWindow.inputField";
	}
	
	static function foof() {
		return Selection.getFocus() == "_level0.window_clip.inputWindow.offsetField";
	}
	
	static function hitOffset(inp) {
		var curArr = TAS.offsetSetup[TAS.curPattern];
		
		if (!curArr) {
			return;
		}
		
		var somethingChanged = false;
		
		for (var i = TAS.curPatternInd; i < curArr.length; i += 4) {
			var curTotalFrame = TAS.curPatternFrame + curArr[i];
			var curNum = curArr[i + 2];
			
			if (TAS.totalFrame > curTotalFrame + curNum + 4) {
				if (i === TAS.curPatternInd) {
					TAS.curPatternInd += 4;
				}
				continue;
			}
			
			if (TAS.totalFrame < curTotalFrame - 5) {
				break;
			}
			
			if (curArr[i + 1] !== inp) {
				continue;
			}
			
			curArr[i + 3] |= 1 << (TAS.totalFrame - curTotalFrame + 5);
			somethingChanged = true;
		}
		
		if (somethingChanged) {
			TAS.updateOffsetBars();
		}
	}
	
	static function updatePattern(curPatternData) {
		if (TAS.curPattern !== curPatternData[1] || TAS.curPatternFrame !== TAS.totalFrame + curPatternData[0]) {
			TAS.curPattern = curPatternData[1];
			TAS.curPatternInd = 0;
			TAS.curPatternFrame = TAS.totalFrame + curPatternData[0];
			TAS.clearOffsets(TAS.offsetSetup[TAS.curPattern]);
			TAS.updateOffsetBars();
		}
	}

	static function checkKeys() {
		if (TAS.totalFrame < -TAS.beginningFrames) {
			TAS.totalFrame++;
			return;
		}
		
		if (TAS.initOffsetInd !== -1) {
			while (TAS.initOffsetInd < TAS.offsetSetup.length && (TAS.offsetSetup[TAS.initOffsetInd] < TAS.totalFrame || !TAS.offsetSetup[TAS.initOffsetInd + 3].length)) {
				TAS.initOffsetInd += 4;
			}
			
			if (TAS.initOffsetInd < TAS.offsetSetup.length && TAS.offsetSetup[TAS.initOffsetInd] - TAS.offsetSetup[TAS.initOffsetInd + 1] <= TAS.totalFrame) {
				if (TAS.offsetSetup[TAS.initOffsetInd + 2]) {
					var patternObj = {};
					for (var prop in TAS.offsetSetup[TAS.initOffsetInd + 2]) {
						patternObj[prop] = [_root.game.player[prop] + TAS.offsetSetup[TAS.initOffsetInd + 2][prop][0], _root.game.player[prop] + TAS.offsetSetup[TAS.initOffsetInd + 2][prop][1]];
					}
					TAS.offsetArr.push(patternObj, TAS.offsetSetup[TAS.initOffsetInd] - TAS.totalFrame, TAS.initOffsetInd + 3);
				} else {
					TAS.offsetObj[Utils.currentPlayerString()] = [TAS.offsetSetup[TAS.initOffsetInd] - TAS.totalFrame, TAS.initOffsetInd + 3];
				}
			}
		} else {
			var curPatternData = TAS.offsetObj[Utils.currentPlayerString()];
			if (curPatternData) {
				TAS.updatePattern(curPatternData);
			} else {
				for (var i = 0; i < TAS.offsetArr.length; i += 3) {
					var failed = false;
					for (var prop in TAS.offsetArr[i]) {
						if (_root.game.player[prop] < TAS.offsetArr[i][prop][0] || _root.game.player[prop] > TAS.offsetArr[i][prop][1]) {
							failed = true;
							break;
						}
					}
					if (!failed) {
						TAS.updatePattern([TAS.offsetArr[i + 1], TAS.offsetArr[i + 2]]);
						break;
					}
				}
			}
		}
		
		if (TAS.write) {
			var DIR_PRESSED = -1;
			var UP_PRESSED = false;
			var DOWN_PRESSED = false;
			
			if (!Utils.foif()) {
				if ((Key.isDown(37) || Key.isDown(65)) && (Key.isDown(39) || Key.isDown(68))) {
					if (com.nitrome.toxic.Global.LAST_DIR_PRESSED == com.nitrome.toxic.Global.LEFT) {
						DIR_PRESSED = com.nitrome.toxic.Global.LEFT;
					} else if (com.nitrome.toxic.Global.LAST_DIR_PRESSED == com.nitrome.toxic.Global.RIGHT) {
						DIR_PRESSED = com.nitrome.toxic.Global.RIGHT;
					}
				} else if (Key.isDown(37) || Key.isDown(65)) {
					DIR_PRESSED = com.nitrome.toxic.Global.LEFT;
				} else if (Key.isDown(39) || Key.isDown(68)) {
					DIR_PRESSED = com.nitrome.toxic.Global.RIGHT;
				} else {
					DIR_PRESSED = -1;
				}
				
				if(!Key.isDown(38) && !Key.isDown(87)) {
					TAS.UP_PRESSED = false;
				}
				if(!Key.isDown(40) && !Key.isDown(83)) {
					TAS.DOWN_PRESSED = false;
				}
				
				UP_PRESSED = TAS.UP_PRESSED;
				DOWN_PRESSED = TAS.DOWN_PRESSED;
			}
			
			if (TAS.override) {
				TAS.truncateCurArray();
			} else {
				TAS.splitCurLetter();
			}
			
			var atEnd = TAS.curIndex === TAS.inputArray.length - 1;
			
			var newInputs;
			var newValues;
			if (!atEnd) {
				newInputs = [TAS.curIndex + 1, 0];
				newValues = [TAS.curIndex + 1, 0];
			} else {
				newInputs = TAS.inputArray;
				newValues = TAS.valueArray;
			}
			
			var startLen = newInputs.length;
			
			if (TAS.justPause) {
				UP_PRESSED = com.nitrome.toxic.Global.UP_PRESSED;
			}
			
			if (!TAS.frozen && !com.nitrome.toxic.Global.can_jump) {
				if ((com.nitrome.toxic.Global.UP_PRESSED && !UP_PRESSED) !== TAS.releasedUp) {
					if (TAS.releasedUp) {
						newInputs.push("j");
					} else {
						newInputs.push("J");
					}
					newValues.push(1);
				}
			}
			
			if (TAS.justPlacedBombs > 0) {
				newInputs.push("b");
				newValues.push(TAS.justPlacedBombs);
			}
			if (TAS.pressedHit) {
				newInputs.push("h");
				newValues.push(1);
			}
			if (com.nitrome.toxic.Global.game_paused === TAS.justPause && TAS.pressedPause) {
				if (TAS.justPlacedBombs <= 0 || !TAS.justPause) {
					newInputs.push("P");
					newValues.push(1);
				}
			}
			
			var letter = "nadwqesADWQE".charAt(DIR_PRESSED + 1 + int(UP_PRESSED) * 3 + int(DOWN_PRESSED) * 6);
			if (TAS.justPause) {
				letter = "p";
			}
			
			var endInd = TAS.endIndArray[TAS.curIndex];
			var endString = TAS.curString.slice(endInd);
			TAS.curString = TAS.curString.slice(0, endInd);
			
			if (newInputs.length === startLen && letter === TAS.inputArray[TAS.curIndex]) {
				TAS.valueArray[TAS.curIndex]++;
				TAS.curString = TAS.curString.slice(0, TAS.indArray[TAS.curIndex]) + TAS.inputArray[TAS.curIndex] + TAS.valueArray[TAS.curIndex];
				TAS.endIndArray[TAS.curIndex] = TAS.curString.length;
			} else {
				newInputs.push(letter);
				newValues.push(1);
				if (!atEnd) {
					TAS.inputArray.splice.apply(TAS.inputArray, newInputs);
					TAS.valueArray.splice.apply(TAS.valueArray, newValues);
				}
				
				var newInds;
				var newEndInds
				if (!atEnd) {
					newInds = [TAS.curIndex + 1, 0];
					newEndInds = [TAS.curIndex + 1, 0];
				} else {
					newInds = TAS.indArray;
					newEndInds = TAS.endIndArray;
				}
				
				for (var i = startLen; i < newInputs.length; i++) {
					newInds.push(TAS.curString.length);
					TAS.curString += newInputs[i] + TAS.compact(newValues[i]);
					newEndInds.push(TAS.curString.length);
				}
				
				if (!atEnd) {
					TAS.indArray.splice.apply(TAS.indArray, newInds);
					TAS.endIndArray.splice.apply(TAS.endIndArray, newEndInds);
				}
			}
			
			if (!atEnd) {
				for (var i = TAS.curIndex + newInputs.length - 1; i < TAS.indArray.length; i++) {
					TAS.indArray[i] += TAS.curString.length - endInd;
					TAS.endIndArray[i] += TAS.curString.length - endInd;
				}
			}
			
			TAS.curString += endString;
			TAS.totalLength++;
		}
		
		var prevFullLetter = "n";
		if (TAS.isFullLetter(TAS.inputArray[TAS.curIndex])) {
			prevFullLetter = TAS.inputArray[TAS.curIndex];
		}
		// Assumes that there is something to play!
		if (TAS.curFrame >= TAS.valueArray[TAS.curIndex]) {
			TAS.curIndex++;
			TAS.curFrame = 0;
		}
		
		var didntReleaseUp = false;
		TAS.bombsThrownThisFrame = 0;
		
		while (TAS.isSubLetter(TAS.inputArray[TAS.curIndex])) {
			switch (TAS.inputArray[TAS.curIndex]) {
				case "b":
					if (com.nitrome.toxic.Global.game_paused) {
						_root.game.unpauseGame();
						_root.popup_holder.hidePopUp();
					}
					for (var i = 0; i < TAS.valueArray[TAS.curIndex]; i++) {
						_root.game.layBomb();
						TAS.bombsThrownThisFrame++;
					}
					break;
				case "r":
					RNG.rngSeed = TAS.valueArray[TAS.curIndex];
					break;
				case "j":
					com.nitrome.toxic.Global.can_jump = true;
					break;
				case "J":
					didntReleaseUp = true;
					break;
				case "P":
					_root.popup_holder.displayPopUp("game_paused");
					_root.game.pauseGame();
					break;
				case "h":
					TAS.queuedHit = true;
					break;
				default:
					var c;
					if ((c = TAS.inputArray[TAS.curIndex]).charAt(0) === "{") {
						for (var i = 0; i < TAS.valueArray[TAS.curIndex]; i++) {
							Code.interpret(TAS.codeObj[c]);
						}
					}
					break;
			}
			
			TAS.curIndex++;
			TAS.curFrame = 0;
		}
		
		var letter = TAS.inputArray[TAS.curIndex];
		
		var doOffsets = TAS.write && prevFullLetter !== letter;
		
		if (letter == "p") {
			if (!com.nitrome.toxic.Global.game_paused) {
				_root.popup_holder.displayPopUp("game_paused");
				_root.game.pauseGame();
			}
			if (doOffsets) {
				TAS.hitOffset(7);
			}
		} else {
			if (com.nitrome.toxic.Global.game_paused) {
				_root.game.unpauseGame();
				_root.popup_holder.hidePopUp();
			}
			
			var num = "nadwqesADWQE".indexOf(letter);
			com.nitrome.toxic.Global.DIR_PRESSED = (num % 3) - 1;
			if (com.nitrome.toxic.Global.UP_PRESSED && num % 6 < 3 && !didntReleaseUp) {
				com.nitrome.toxic.Global.can_jump = true;
			}
			com.nitrome.toxic.Global.UP_PRESSED = num % 6 >= 3;
			com.nitrome.toxic.Global.DOWN_PRESSED = num >= 6;
			
			if (doOffsets) {
				if (prevFullLetter === "p") {
					TAS.hitOffset(6);
				} else {
					var prevNum = "nadwqesADWQE".indexOf(prevFullLetter);
					if (prevNum % 3 - 1 !== com.nitrome.toxic.Global.DIR_PRESSED) {
						TAS.hitOffset(com.nitrome.toxic.Global.DIR_PRESSED);
					}
					if ((prevNum % 6 >= 3) !== com.nitrome.toxic.Global.UP_PRESSED) {
						TAS.hitOffset(com.nitrome.toxic.Global.UP_PRESSED? 3 : 2);
					}
					if ((prevNum >= 6) !== com.nitrome.toxic.Global.DOWN_PRESSED) {
						TAS.hitOffset(com.nitrome.toxic.Global.DOWN_PRESSED? 5 : 4);
					}
				}
			}
		}
		TAS.curFrame++;
		TAS.totalFrame++;
	}
	
	static function performQueuedHit() {
		if (TAS.queuedHit) {
			_root.game.player.startHit();
		}
	}
	
	static function resetInputCheckers() {
		TAS.justPause = com.nitrome.toxic.Global.game_paused;
		TAS.pressedPause = false;
		TAS.releasedUp = false;
		TAS.pressedHit = false;
		TAS.justPlacedBombs = 0;
		
		TAS.queuedHit = false;
	}
	
	static function addGhost(num) {
		var ghostName = "g" + num;
		_root.game.ghost_holder.attachMovie("player", ghostName, num);
		_root.game.ghost_holder[ghostName]._alpha = 30;
		TAS.updateGhost(ghostName);
	}
	
	static function updateGhosts() {
		if (TAS.totalFrame < 0) {
			return;
		}
		
		var p = _root.game.player;
		
		TAS.ghostData.push(p._x, p._y, p._currentframe, p.anim._currentframe);
		
		if (TAS.fastPlayback) {
			return;
		}
		
		for (var ghostName in _root.game.ghost_holder) {
			TAS.updateGhost(ghostName);
		}
	}
	
	static function updateGhost(ghostName) {
		var ghost = _root.game.ghost_holder[ghostName];
		var data = TAS.saveStates[ghostName.slice(1)].ghostData;
		
		var ind = Math.min(TAS.totalFrame * 4, data.length - 4);
		
		if (ind >= 0) {
			ghost._x = data[ind];
			ghost._y = data[ind+1];
			ghost.gotoAndStop(data[ind+2]);
			ghost.anim.gotoAndStop(data[ind+3]);
		} else {
			ghost.stop();
			ghost.anim.stop();
		}
	}
	
	static function skipToFrame(frame) {
		if (frame <= TAS.totalFrame) {
			return false;
		}
		
		var oldWrite = TAS.write;
		TAS.write = false;
		
		TAS.fastPlayback = true;
		while (TAS.totalFrame < frame - 1) {
			Main.gameUpdate();
		}
		TAS.fastPlayback = false;
		Main.gameUpdate();
		Main.stopAll();
		
		TAS.write = oldWrite;
		
		return true;
	}

	static function levelInit() {
		TAS.resetInputCheckers();
		
		var bubArray = [];
		
		for (var j in _root.game.acid_holder) {
			bubArray.push(_root.game.acid_holder[j]);
		}
		
		for (var j in bubArray) {
			var cur = bubArray[j];
			
			if (cur.bubbles) {
				Main._gotoAndPlay(cur.bubbles, RNG._random(267) + 1);
				//trace("Initializing " + cur.bubbles);
			} else if (cur.anim) {
				Main._gotoAndPlay(cur.anim, RNG._random(267) + 1);
				//trace("Initializing " + cur.anim);
			}
		}
		
		com.nitrome.toxic.Global.can_jump = true;
		com.nitrome.toxic.Global.UP_PRESSED = false;
		TAS.curIndex = 0;
		TAS.curFrame = TAS.valueArray[0];
		
		TAS.totalFrame = -109;
		
		TAS.ghostData = [];
		for (var i = 0; i < 10; i++) {
			if (TAS.ghostVisible[i]) {
				TAS.addGhost(i);
			}
		}
		
		TAS.curPattern = 3;
		TAS.curPatternInd = 0;
		TAS.curPatternFrame = 0;
		
		if (TAS.targetFrame !== -Infinity) {
			TAS.skipToFrame(TAS.targetFrame);
			TAS.targetFrame = -Infinity;
		} else {
			TAS.skipToFrame(-TAS.beginningFrames);
		}
		
		if (TAS.initOffsetInd === -1) {
			for (var i = 3; i < TAS.offsetSetup.length; i += 4) {
				TAS.clearOffsets(TAS.offsetSetup[i]);
			}
		}
		TAS.initOffsetInd = -1;
		TAS.updateOffsetBars();
		
		if (TAS.delayedFun) {
			Code.execute(TAS.delayedFun);
			TAS.delayedFun = null;
		}
	}
}