package com.yadurajiv.revenge;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;

/**
 * Copyright (c) 2010 Yadu Rajiv
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source
 * distribution.
 */
class PlayState extends FlxState 
{
	private var _map:FlxTilemap;
	private var _exit:FlxSprite;
	private var _player:FlxSprite;
	
	private var _playerSpeed:Float = 120;
	private var _playerJump:Float = 200;
	private var _flagWalking:Bool = false;
	
	/**
	 * You might notice that there is no level1() constructor here, that is because doing things in the 
	 * constructor might not be so safe, since we don't know if it is properly initialized. So the create
	 * function is called by flixel after the FlxState if properly created and ready
	 */
	override public function create():Void 
	{
		// FlxG handles input from many devices and also can control the appearence of the mouse cursor. 
		// Here we are hiding it since we don't want it visible while we move the character around
		FlxG.mouse.hide();
		
		// Fade in from black :P
		FlxG.cameraFX.flash(FlxColor.BLACK);
		
		// Loading a map!
		// The FlxTilemap class takes in a string of numbers and converts them into a map, you can either pass
		// it a string or use the built in helper static functions in FlxTilemap to convert a bitmap/image into
		// a csv; which is what I'm doing here. The second param to loadMap takes in a tilesheet to be used with
		// the tilemap. The fourth and fifth is the width and height of a single tile in the tile sheet. FlxTilemap
		// does an auto tiling for you if you want it. This is *OFF* by default and you have to set it by setting the
		// map.auto to either FlxTilemap.AUTO(for platform friendly tiling) or FlxTilemap.ALT(for the alternate top down tiling)
		_map = new FlxTilemap();
		_map.auto = FlxTilemap.AUTO;
		_map.loadMap(FlxTilemap.imageToCSV("assets/map.png"), "assets/tileset.png", 10, 10, FlxTilemap.AUTO);
		add(_map);
		
		// Adding the exit door with which we will check an overlap later for the player
		_exit = new FlxSprite(420, 190, "assets/exit.png");
		add(_exit);
		
		// Creating the player sprite, loading the sprite sheet and adding animations
		_player = new FlxSprite(240, 200);
		_player.loadGraphic("assets/aye.png", true, true, 32, 32);
		_player.addAnimation("idle", [0]);
		_player.addAnimation("walk", [1, 2, 3, 4, 5, 6], 6, true);
		_player.addAnimation("down", [7]);
		_player.addAnimation("jump", [8]);
		add(_player);
		
		// Setting some gravity and speed along with a drag for the player
		_player.acceleration.y = 420;
		_player.maxVelocity = new FlxPoint(_playerSpeed, 420);
		_player.drag = new FlxPoint(_playerSpeed * 4, _playerSpeed * 4);
		
		// Uncomment FlxG.showBounds = true to see the bounding rect for the player sprite
		// we resize the player sprite so that the collision is not completely wrong(you
		// dont want the whole 32x32 sprite to collide but the region where the player actually is)
		_player.width = 15;
		_player.height = 29;
		_player.offset.set(8, 2);
		
		// The world bounds need to be set for the collision to work properly
		FlxG.worldBounds.set(0, 0, 800, 600);
		FlxG.worldDivisions = 8;
		
		// We ask the Flixel camera subsystem to follow the player sprite with a slight lag or not(lerp)
		FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
	}
	
	/**
	 * We override the update funtion to update the player position, do collision checks and check input to move
	 * the player around each frame.
	 */
	override public function update():Void 
	{
		// Checks collision with player and the map
		FlxG.collide(_player, _map);
		
		// If the player overlaps with the exit sprite, then it calls this anonymous function
		// and fades the screen to the next state
		FlxG.overlap(_player, _exit, onOverlap);
		
		// If the player is moving in the y direction and not on the floor, he is jumping or falling
		if (_player.velocity.y == 0 && !_player.isTouching(FlxObject.FLOOR)) 
		{
			_player.play("jump");
		}
		
		// If the player is on the floor and not walking and the last animation has not finished then be idle
		if (_player.isTouching(FlxObject.FLOOR) && !_flagWalking && _player.finished) 
		{
			_player.play("idle");
		}
		
		// Check input and move left
		if (FlxG.keys.LEFT || FlxG.keys.A) 
		{
			_player.velocity.x = -_playerSpeed;
			_player.facing = FlxObject.LEFT;
			
			// If the player is actually moving right and if he is not jumping/falling then you do the walk animaiton
			if (_player.isTouching(FlxObject.FLOOR)) 
			{
				_flagWalking = true;
				_player.play("walk");
			}	
		} 
		else 
		{
			_flagWalking = false;
		}
		
		// Check input and move right
		if (FlxG.keys.RIGHT || FlxG.keys.D) 
		{
			_player.velocity.x = _playerSpeed;
			_player.facing = FlxObject.RIGHT;
			
			// If the player is actually moving right and if he is not jumping/falling then you do the walk animaiton
			if (_player.isTouching(FlxObject.FLOOR)) 
			{
				_flagWalking = true;
				_player.play("walk");
			}
		} 
		else 
		{
			_flagWalking = false;
		}
		
		// Jump! when you hit Z or Space or UP
		if (FlxG.keys.Z|| FlxG.keys.SPACE || FlxG.keys.UP || FlxG.keys.W) 
		{
			if (_player.isTouching(FlxObject.FLOOR)) 
			{
				_player.velocity.y = -_playerJump;
				_player.play("jump");
			}	
		}
		
		// Update everything else!! yes you need to do this! :P
		super.update();
	}
	
	private function onOverlap(Obj1:FlxObject, Obj2:FlxObject):Void 
	{
		FlxG.cameraFX.fade(FlxColor.BLACK, 1, false, onFade);
	}
	
	private function onFade():Void
	{
		// FlxG.fade.start also takes in a callback which is called after the fade ends!!
		FlxG.switchState(new EndState());
	}
}