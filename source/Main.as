class Main
{
	static var holders;
	static var scriptStack;
	static var spriteInfo;
	static var prevFrameStamp = 0;
	static var prevFrameTime = 0;
	
	static function init() {
		_root.aMode = true;
		_root._random = RNG._random;
		_root._random_double = RNG._random_double;
		_root._stop = Main._stop;
		_root._play = Main._play;
		_root._gotoAndStop = Main._gotoAndStop;
		_root._gotoAndPlay = Main._gotoAndPlay;
		
		Main.spriteInfo = _root.spriteInfo;
		Windows.init();
		Utils.init();
	}
	
	static function levelInit() {
		//_root.holders = [g.heart_holder, g.bg_holder, g.ground_holder, g.solid_holder, g.object_holder, g.safe_holder, g.danger_holder, g.bossbmp_holder, g.laser_holder, g.debris_holder, g.player_holder, g.grow_holder, g.bomb_holder, g.missile_holder, g.splash_holder, g.acid_holder, g.explosion_holder];
		var g = _root.game;
		Main.holders = [g.heart_holder, g.object_holder, g.safe_holder, g.danger_holder, g.laser_holder, g.player_holder, g.grow_holder, g.bomb_holder, g.missile_holder, g.splash_holder, g.acid_holder, g.explosion_holder];
		_root.popup_holder.stopped = true;
		
		Utils.levelInit();
		TAS.levelInit();
		Main.stopAll();
	}
	
	static function endFrame() {
		if (TAS.specialMode === 2 && TAS.totalFrame !== TAS.specialModeData[1]) {
			TAS.specialMode = 0;
		}
		if (TAS.textRefresh) {
			TAS.updateText();
		}
	}
	
	static function metaUpdate() {
		Main.prevFrameTime = getTimer() - Main.prevFrameStamp;
		Main.prevFrameStamp = getTimer();
		
		if (TAS.delayedCaretPos != -1) {
			Selection.setFocus(Windows.clip.inputWindow.inputField);
			Selection.setSelection(TAS.delayedCaretPos, TAS.delayedCaretPos);
			TAS.delayedCaretPos = -1;
		}
		
		if (!TAS.frozen) {
			// Guarantees that there is something to play!
			if (!TAS.write && TAS.isAtStringEnd()) {
				TAS.frozen = true;
			} else {
				Main.gameUpdate();
				Main.stopAll();
			}
		}
	}

	static function gameUpdate() {
		Utils.clearTestBitmaps();
		
		Main.scriptStack = [];
		
		TAS.checkKeys();
		
		Main.executeScripts(Main.scriptStack);
		Main.scriptStack = [];
		
		Main.updateAnimations();
		
		var oldStack = Main.scriptStack;
		Main.scriptStack = [];
		
		Main.executeScripts(oldStack);
		
		_root.game.doEnterFrame();
		_root.doEnterFrameBeacon();
		
		Main.executeScripts(Main.scriptStack);
		
		TAS.resetInputCheckers();
		TAS.updateGhosts();
		TAS.textRefresh = true;
	}

	static function executeScripts(stack) {
		var i = 0;
		while (i < stack.length) {
			stack[i+1](stack[i]);
			i += 2;
		}
	}

	static function updateAnimations() {
		var i = 0;
		while (i < Main.holders.length) {
			for (var objName in Main.holders[i]) {
				var obj = Main.holders[i][objName];
				Main.advanceAnimation(obj, obj.chid);
			}
			i++;
		}
		Main.advanceAnimation(_root.popup_holder, _root.popup_holder.chid);
	}
	
	static function iterateOnChildren(obj, childArray, fun1, fun2) {
		var i = 0;
		while (i < childArray.length) {
			var curChild = obj[childArray[i]];
			if (curChild) {
				var childChid = Main.determineChildChid(obj, childArray[i+1]);

				if (!curChild.justExisted)
					fun1(curChild, childChid);
				else if (fun2)
					fun2(curChild, childChid);
			}
			i += 2;
		}
	}

	static function determineChildChid(obj, chid) {
		if (typeof chid != "number") {
			var i = 0;
			while (i < chid.length) {
				if (obj._currentframe >= chid[i]) {
					return chid[i+1];
				}
				
				i += 2;
			}
			return 0;
		}
		return chid;
	}

	static function advanceAnimation(obj, chid) {
		if (!chid) return;
		var info = Main.spriteInfo["m" + chid];
		if (!info) return;
		
		if (info.length > 1) {
			var i = 0;
			while (i < info[1].length) {
				if (obj[info[1][i]]) {
					obj[info[1][i]].justExisted = true;
				}
				i += 2;
			}
		}
		
		if (info[0] && !obj.stopped) {
			if (obj._currentframe >= obj._totalframes) {
				obj.gotoAndStop(1);
			} else {
				obj.nextFrame();
			}
			
			if (typeof(info[0]) == "object") {
				if (info[0]["f" + obj._currentframe]) {
					Main.scriptStack.push(obj, info[0]["f" + obj._currentframe]);
				}
			}
		}
		
		if (info.length > 1) {
			Main.iterateOnChildren(obj, info[1], Main.checkFrameScript, Main.advanceAnimation);
		}
	}

	static function checkFrameScript(obj, chid) {
		if (!chid) return;
		var info = Main.spriteInfo["m" + chid];
		if (!info) return;
		
		if (typeof(info[0]) == "object") {
			if (info[0]["f" + obj._currentframe]) {
				Main.scriptStack.push(obj, info[0]["f" + obj._currentframe]);
			}
		}
		
		if (info.length > 1) {
			Main.iterateOnChildren(obj, info[1], Main.checkFrameScript, Main.checkFrameScript);
		}
	}
	
	static function _gotoAnd(that, frame, chid, doStop) {
		if (_root.aMode) {
			if (chid) {
				var info = Main.spriteInfo["m" + chid];
				if (!info) {
					Main._gotoAnd(that, frame, 0, doStop);
					return;
				}
				
				if (info.length > 1) {
					var i = 0;
					while (i < info[1].length) {
						if (that[info[1][i]]) {
							that[info[1][i]].justExisted = true;
						}
						i += 2;
					}
				}
				
				var oldFrame = that._currentframe;
				that.gotoAndStop(frame);
				that.stopped = doStop;
				
				if (oldFrame != that._currentframe) {
					if (typeof(info[0]) == "object") {
						if (info[0]["f" + that._currentframe]) {
							Main.scriptStack.push(that, info[0]["f" + that._currentframe]);
						}
					}
					
					if (info.length > 1) {
						Main.iterateOnChildren(that, info[1], Main.checkFrameScript, false);
					}
				}
			} else {
				that.gotoAndStop(frame);
				that.stopped = doStop;
			}
		} else {
			if (doStop)
				that.gotoAndStop(frame);
			else
				that.gotoAndPlay(frame);
		}
	}
	
	static function _gotoAndStop(that, frame, chid) {
		Main._gotoAnd(that, frame, chid, true);
	}
	
	static function _gotoAndPlay(that, frame, chid) {
		Main._gotoAnd(that, frame, chid, false);
	}
	
	static function _stop(that) {
		if (_root.aMode) {
			that.stopped = true;
		} else {
			that.stop();
		}
	}

	static function _play(that) {
		if (_root.aMode) {
			that.stopped = false;
		} else {
			that.play();
		}
	}

	static function stopAll() {
		var i = 0;
		while (i < Main.holders.length) {
			for (var objName in Main.holders[i]) {
				var obj = Main.holders[i][objName];
				Main.stopAnimation(obj, obj.chid);
			}
			i++;
		}
		Main.stopAnimation(_root.popup_holder, _root.popup_holder.chid);
	}

	static function stopAnimation(obj, chid) {
		obj.stop();
		if (!chid) return;
		var info = Main.spriteInfo["m" + chid];
		if (!info) return;
		
		if (info.length > 1) {
			Main.iterateOnChildren(obj, info[1], Main.stopAnimation, Main.stopAnimation);
		}
	}
}