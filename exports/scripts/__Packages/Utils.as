class Utils
{
	static var bomberRangeBitmap;
	static var collisionQueryBitmap;
	static var extraVisibilities;
	static var layerVisibilities;
	static var robotRangeBitmap;
	static var testVisibilities;
	static var invulnerable = false;
	static var noDeath = false;
	static var fullLoads = false;
	static var controlAtBeginning = false;
	static var emptyStringOnExit = true;
	static var closeWindowsOnExit = false;
	static var perf = true;
	static var inaccuratePhysics = false;
	static var masked = true;
	static var zeroPoint = new flash.geom.Point(0,0);
	static var deactivateTeleport = false;
	static var laserState = 1;
	static var conveyorsOn = true;
	static var autoScroll = true;
	static var screenshake = true;
	static var visWindowArray = ["Damage",60,52,"Acid",60,52,"Object",60,52,"Bomb",31,18,"Explosion",120,120];
	static var bmps = {};
	static var empty_bmp = new flash.display.BitmapData(200,200,false);
	static var inputDisplayParams = {size:20,border:2,spacing:4};
	function Utils()
	{
	}
	static function init()
	{
		Utils.bomberRangeBitmap = new flash.display.BitmapData(499,299,true,2163588879);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(49,0,401,299),2163372556);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(149,0,201,299),2164001796);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(1,1,47,297),0);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(50,1,98,297),0);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(150,1,99,297),0);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(250,1,99,297),0);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(351,1,98,297),0);
		Utils.bomberRangeBitmap.fillRect(new flash.geom.Rectangle(451,1,47,297),0);
	}
	static function onLoadLevel(game)
	{
		Utils.robotRangeBitmap.dispose();
		Utils.robotRangeBitmap = new flash.display.BitmapData(com.nitrome.toxic.Global.level_width,com.nitrome.toxic.Global.level_height,true,0);
		game.test_holder.createEmptyMovieClip("robotRanges",game.test_holder.getNextHighestDepth());
		game.test_holder.robotRanges.attachBitmap(Utils.robotRangeBitmap,1);
		game.test_holder.createEmptyMovieClip("testPoints",game.test_holder.getNextHighestDepth());
		game.test_holder.testPoints.attachBitmap(flash.display.BitmapData.loadBitmap("testPoints"),1);
		Utils.collisionQueryBitmap.dispose();
		Utils.collisionQueryBitmap = new flash.display.BitmapData(com.nitrome.toxic.Global.level_width,com.nitrome.toxic.Global.level_height,true,0);
		game.test_holder.createEmptyMovieClip("collisionQueries",game.test_holder.getNextHighestDepth());
		game.test_holder.collisionQueries.attachBitmap(Utils.collisionQueryBitmap,1);
	}
	static function onClearAll(game)
	{
		for(var i in game.test_holder)
		{
			game.test_holder[i].removeMovieClip();
		}
	}
	static function testVisible(layer)
	{
		return _root.game.test_holder._visible && _root.game.test_holder[layer]._visible && !TAS.fastPlayback;
	}
	static function markCollisionQuery(x, y, fun)
	{
		var ans = fun(x,y);
		if(Utils.testVisible("collisionQueries"))
		{
			Utils.collisionQueryBitmap.setPixel32(x,y,ans ? 4294914816 : 4288269567);
		}
		return ans;
	}
	static function markBomberRange(x, y)
	{
		if(Utils.testVisible("robotRanges"))
		{
			Utils.robotRangeBitmap.copyPixels(Utils.bomberRangeBitmap,Utils.bomberRangeBitmap.rectangle,new flash.geom.Point(x - 249,y - 199));
		}
	}
	static function clearTestBitmaps()
	{
		if(Utils.testVisible("collisionQueries"))
		{
			Utils.collisionQueryBitmap.fillRect(Utils.collisionQueryBitmap.rectangle,0);
		}
		if(Utils.testVisible("robotRanges"))
		{
			Utils.robotRangeBitmap.fillRect(Utils.robotRangeBitmap.rectangle,0);
		}
	}
	static function cutsceneIn()
	{
		if(!TAS.fastPlayback)
		{
			_root.cutscene.gotoAndPlay("in");
		}
		else
		{
			_root.cutscene.gotoAndStop(18);
		}
	}
	static function cutsceneOut()
	{
		if(!TAS.fastPlayback)
		{
			_root.cutscene.gotoAndPlay("out");
		}
		else
		{
			_root.cutscene.gotoAndStop(1);
		}
	}
	static function levelInit()
	{
		if(!Utils.layerVisibilities)
		{
			Utils.layerVisibilities = {};
			var tempArr = [];
			for(var holder in _root.game)
			{
				if(holder.slice(-7) == "_holder")
				{
					tempArr.push(holder);
				}
			}
			for(var holder in tempArr)
			{
				Utils.layerVisibilities[tempArr[holder]] = true;
			}
			Utils.layerVisibilities.test_holder = false;
			Utils.testVisibilities = {testPoints:true,collisionQueries:false,robotRanges:false};
			Utils.extraVisibilities = {pipes:true,big_pipes:true,acid_holder:true,bomb_panel:true,health_panel:true,powercell_panel:true,text_display:true,cutscene:true,popup_holder:true};
		}
		for(var holder in _root.game)
		{
			if(holder.slice(-7) == "_holder")
			{
				_root.game[holder]._visible = Utils.layerVisibilities[holder];
			}
		}
		for(var layer in Utils.extraVisibilities)
		{
			_root[layer]._visible = Utils.extraVisibilities[layer];
		}
		for(var sprite in Utils.testVisibilities)
		{
			_root.game.test_holder[sprite]._visible = Utils.testVisibilities[sprite];
		}
	}
	static function doKeyDown(code)
	{
		if(code == 77)
		{
			var w = Windows.createEmptyWindow(100,100);
			Utils.mainMenu(w);
			return true;
		}
	}
	static function mainMenu(w)
	{
		w.updateMainField({title:"Main menu",curWindow:Utils.mainMenu,options:["Testing vars",Utils.testingVarsWindow,"Bruteforcing",Utils.bruteforcingWindow,"Info windows",Utils.infoWindowsWindow,"Preferences",Utils.preferenceWindow,"Layer visibility",Utils.layerVisibilityWindow,"Value view",Utils.valueViewWindow]});
	}
	static function testingVarsWindow(w)
	{
		var obj = {title:"Testing vars",curWindow:Utils.testingVarsWindow,options:[]};
		Utils.addToggleVarOptions(obj.options,["Invulnerability",Utils,"invulnerable","No death",Utils,"noDeath","Wrong physics",Utils,"inaccuratePhysics","Deactivate teleport",Utils,"deactivateTeleport"]);
		Utils.addCycleOption(obj.options,"Lasers",Utils,"laserState",["off","on","simple"]);
		Utils.addToggleVarOptions(obj.options,["Conveyors",Utils,"conveyorsOn"]);
		obj.options.push("Back",Utils.mainMenu);
		w.updateMainField(obj);
	}
	static function addToggleVarOptions(options, stuffArray)
	{
		var i = 0;
		while(i < stuffArray.length)
		{
			var name = stuffArray[i];
			var stump = stuffArray[i + 1];
			var varName = stuffArray[i + 2];
			options.push(name + ": " + (stump[varName] ? "on" : "off"));
			options.push([Utils.toggleVar,stump,varName]);
			i += 3;
		}
	}
	static function toggleVar(w, stump, varName)
	{
		stump[varName] = !stump[varName];
		w.obj.curWindow(w);
	}
	static function addCycleOption(options, name, stump, varName, values)
	{
		options.push(name + ": " + values[stump[varName]]);
		options.push([Utils.cycleVar,stump,varName,values]);
	}
	static function cycleVar(w, stump, varName, values)
	{
		stump[varName]++;
		stump[varName] %= values.length;
		w.obj.curWindow(w);
	}
	static function bruteforcingWindow(w)
	{
		w.updateMainField({title:"Bruteforcing",curWindow:Utils.bruteforcingWindow,options:["Copy collision data 📋",Utils.copyCollisionData,"Back",Utils.mainMenu]});
	}
	static function copyCollisionData(w)
	{
		var collisionData = [];
		var y = 0;
		while(y < com.nitrome.toxic.Global.level_height)
		{
			var xcol = 0;
			while(xcol < com.nitrome.toxic.Global.level_cols)
			{
				var curInt = 0;
				var xmod = 0;
				while(xmod < 32)
				{
					if(_root.game.getSceneryCollision(xcol * 32 + xmod,y))
					{
						curInt |= 1 << xmod;
					}
					xmod++;
				}
				collisionData.push(curInt);
				xcol++;
			}
			y++;
		}
		collisionData.push(com.nitrome.toxic.Global.level_cols);
		System.setClipboard(collisionData.toString());
	}
	static function toggleMask(w)
	{
		Utils.masked = !Utils.masked;
		if(Utils.masked)
		{
			_root.setMask(mask);
		}
		else
		{
			_root.setMask(null);
		}
		w.obj.curWindow(w);
	}
	static function preferenceWindow(w)
	{
		var obj = {title:"Preferences",curWindow:Utils.preferenceWindow,options:[]};
		Utils.addToggleVarOptions(obj.options,["Perf optimizations",Utils,"perf","Auto scroll",Utils,"autoScroll","Screenshake",Utils,"screenshake"]);
		obj.options.push("Back",Utils.mainMenu);
		w.updateMainField(obj);
	}
	static function infoWindowsWindow(w)
	{
		var options = [];
		var i = 0;
		while(i < Utils.visWindowArray.length)
		{
			options.push(Utils.visWindowArray[i] + " visualization 🗗",[Utils.activateStaticWindow,Windows.clip[Utils.visWindowArray[i] + "VisWindow"]]);
			i += 3;
		}
		options.push("Input display 🗗",[Utils.activateStaticWindow,Windows.clip.inputDisplay]);
		options.push("Back",Utils.mainMenu);
		w.updateMainField({title:"Info windows",curWindow:Utils.infoWindowsWindow,options:options});
	}
	static function activateStaticWindow(w, w2)
	{
		w2._visible = true;
	}
	static function clearBitmap(bmp)
	{
		bmp.copyPixels(Utils.empty_bmp,new flash.geom.Rectangle(0,0,bmp.width,bmp.height),Utils.zeroPoint);
	}
	static function imgMinimize(w)
	{
		w.minimized = !w.minimized;
		w.img._visible = !w.minimized;
		w.updateMainField(false);
	}
	static function updateVisBitmap(n, source_bmp)
	{
		var dest_bmp = Utils.bmps[n];
		if(!TAS.fastPlayback && Windows.clip[n + "VisWindow"]._visible)
		{
			Utils.clearBitmap(dest_bmp);
			dest_bmp.copyPixels(source_bmp,new flash.geom.Rectangle(0,0,source_bmp.width,source_bmp.height),Utils.zeroPoint);
		}
	}
	static function layerVisibilityWindow(w)
	{
		for(var holder in _root.game)
		{
			if(holder.slice(-7) == "_holder")
			{
				_root.game[holder]._visible = Utils.layerVisibilities[holder];
			}
		}
		var obj = {title:"Layer visibility",curWindow:Utils.layerVisibilityWindow,options:[]};
		var arr = [];
		for(var holder in Utils.layerVisibilities)
		{
			arr.push(holder.slice(0,-7),Utils.layerVisibilities,holder);
		}
		obj.options.push("Back",Utils.mainMenu);
		obj.options.push("Extra",Utils.extraVisibilityWindow);
		Utils.addToggleVarOptions(obj.options,arr);
		w.updateMainField(obj);
	}
	static function extraVisibilityWindow(w)
	{
		for(var sprite in Utils.testVisibilities)
		{
			_root.game.test_holder[sprite]._visible = Utils.testVisibilities[sprite];
		}
		for(var layer in Utils.extraVisibilities)
		{
			_root[layer]._visible = Utils.extraVisibilities[layer];
		}
		var obj = {title:"Extra visibility",curWindow:Utils.extraVisibilityWindow,options:[]};
		var arr = [];
		if(Utils.layerVisibilities.test_holder)
		{
			for(var sprite in Utils.testVisibilities)
			{
				arr.push(sprite,Utils.testVisibilities,sprite);
			}
		}
		for(var layer in Utils.extraVisibilities)
		{
			arr.push(layer,Utils.extraVisibilities,layer);
		}
		obj.options.push("Back",Utils.layerVisibilityWindow);
		obj.options.push("Mask: " + (Utils.masked ? "on" : "off"),Utils.toggleMask);
		Utils.addToggleVarOptions(obj.options,arr);
		w.updateMainField(obj);
	}
	static function valueViewWindow(w)
	{
		w.updateMainField({title:"Value view",curWindow:Utils.valueViewWindow,options:["Basic 🗗",[Utils.activateStaticWindow,Windows.clip.varWindow],"Watch 🗗",[Utils.activateStaticWindow,Windows.clip.watchWindow],"Inspect",[Utils.inspectWindow,"_root.game"],"Back",Utils.mainMenu]});
	}
	static function inspectWindow(w, str, isProp)
	{
		if(str === "_root")
		{
			Utils.valueViewWindow(w);
			return undefined;
		}
		var obj = {title:str.slice(str.lastIndexOf(".") + 1) + (isProp ? "" : "/"),update:[Utils.inspectWindow,str,isProp],options:["Back"]};
		if(isProp)
		{
			obj.options.push([Utils.inspectWindow,str,false]);
		}
		else
		{
			obj.options.push([Utils.inspectWindow,str.slice(0,str.lastIndexOf(".")),false]);
		}
		var currentObj = eval(str);
		if(currentObj)
		{
			if(!isProp)
			{
				obj.options.push("Properties",[Utils.inspectWindow,str,true]);
			}
			else if(typeof currentObj === "movieclip")
			{
				var i = 0;
				while(i < 3)
				{
					var curName = ["_x","_y","_currentframe"][i];
					obj.options.push(curName + ": " + currentObj[curName],[Utils.copyVar,str + "." + curName]);
					i++;
				}
			}
			for(var i in currentObj)
			{
				switch(typeof currentObj[i])
				{
					case "function":
						break;
					case "object":
					case "movieclip":
						if(!isProp)
						{
							obj.options.push(i,[Utils.inspectWindow,str + "." + i]);
						}
						break;
					default:
						if(isProp)
						{
							obj.options.push(i + ": " + currentObj[i],[Utils.copyVar,str + "." + i]);
						}
				}
			}
		}
		w.updateMainField(obj);
	}
	static function setClipboard(w, str)
	{
		System.setClipboard(str);
	}
	static function copyVar(w, str)
	{
		var ind = Code.indOf(str,".");
		while(ind < str.length)
		{
			var nextInd = Code.indOf(str,".",ind + 1);
			var varType = 0;
			if(Code.isVarMiddle(str.charAt(ind + 1)))
			{
				if(Code.isDigit(str.charAt(ind + 1)))
				{
					varType = 1;
				}
				var i = ind + 2;
				while(i < nextInd)
				{
					if(varType === 0 && !Code.isVarMiddle(str.charAt(i)) || varType === 1 && !Code.isDigit(str.charAt(i)))
					{
						varType = 2;
						break;
					}
					i++;
				}
			}
			else
			{
				varType = 2;
			}
			if(varType !== 0)
			{
				var replacement = str.slice(ind + 1,nextInd);
				if(varType === 2)
				{
					replacement = "\"" + replacement.split("\\").join("\\\\").split("\"").join("\\\"").split("\n").join("\\n").split("\r").join("\\r") + "\"";
				}
				str = str.slice(0,ind) + "[" + replacement + "]" + str.slice(nextInd);
				nextInd = ind + replacement.length + 2;
			}
			ind = nextInd;
		}
		if(str.slice(0,10) === "_root.game")
		{
			str = "g" + str.slice(10);
		}
		System.setClipboard(str);
	}
	static function getLast(arr)
	{
		return arr[arr.length - 1];
	}
	static function pushO(arr, frame, inp, num)
	{
		Utils.getLast(arr).push(frame - arr[arr.length - 4],inp,num,0);
	}
	static function foif()
	{
		return eval(Selection.getFocus()).type === "input";
	}
	static function currentPlayerString()
	{
		var p = _root.game.player;
		return [p._x,p._y,p.state,p.vx,p.vy].join("/");
	}
}
