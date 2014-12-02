//
//  MainScene.swift
//  FlappyFlySwift
//
//  Created by Aleksey Zhilin (synthetic@nm.ru) on 01.12.14.
//  Copyright (c) 2014 Aleksey Zhilin. All rights reserved.
//
//  This code based on original tutorial from site https://www.makeschool.com
//  Link to original post writen by Benjamin Encz
//  https://www.makeschool.com/gamernews/369/build-your-own-flappy-bird-with-spritebuilder-and
//

// override of the multiplication operator for scrolling code (see the update method)
func * (a: CCTime, b: CGFloat) -> CGFloat
{
    return CGFloat(a) * b;
}
func * (a: CGFloat, b: CCTime) -> CGFloat
{
    return a * CGFloat(b);
}

class MainScene: CCNode, CCPhysicsCollisionDelegate
{
    // drawing order enum
    enum DrawingOrder: Int
    {
        case DrawingOrderPipes = 0, DrawingOrderGround, DrawingOrdeHero
    }

    // code connection vars from SpriteBuilder
    var _hero:          CCSprite!;
    var _ground1:       CCNode!;
    var _ground2:       CCNode!;
    var _physicsNode:   CCPhysicsNode!;
    var _scoreLabel:    CCLabelTTF!;
    var _restartButton: CCButton!;

    // this vars literally initialized
    var _points:                  Int        = 0;
    var _gameOver:                Bool       = false;
    var _scrollSpeed:             CGFloat    = 80;

    // obstacles position constants
    let firstObstaclePosition:    CGFloat    = 280.0;
    let distanceBetweenObstacles: CGFloat    = 160.0;

    // this vars should be explicitly initialized during init()
    var _sinceTouch: CCTime;
    var _grounds:    Array<CCNode>;
    var _obstacles:  Array<CCNode>;

    // initializer
    override init()
    {
        // initialize the vars
        _sinceTouch = CCTime();
        _grounds    = Array<CCNode>();
        _obstacles  = Array<CCNode>();
    }

    // prepare some stuff after loading the scene
    func didLoadFromCCB()
    {
        _scrollSpeed = 80;
        self.userInteractionEnabled = true;

        // grounds setup
        _grounds = [_ground1, _ground2];
        for ground in _grounds
        {
            ground.physicsBody.collisionType = "level";
            ground.zOrder = DrawingOrder.DrawingOrderGround.rawValue;
        }

        // hero setup
        _hero.physicsBody.collisionType = "hero";
        _hero.zOrder = DrawingOrder.DrawingOrdeHero.rawValue;

        // collision delegate setup
        _physicsNode.collisionDelegate = self;

        // spawn obstacles
        self.spawnNewObstacle();
        self.spawnNewObstacle();
        self.spawnNewObstacle();
    }

    // collision handler between hero and level obstacles
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero nodeA: CCNode!, level nodeB: CCNode!) -> ObjCBool
    {
        self.gameOver();
        return true;
    }

    // collision handler between hero and goal
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero nodeA: CCNode!, goal nodeB: CCNode!) -> ObjCBool
    {
        nodeB.removeFromParent();
        _points++;
        _scoreLabel.string = String(_points);
        return true;
    }

    // stopping the game
    func gameOver()
    {
        if !_gameOver
        {
            _scrollSpeed = 0;
            _gameOver = true;
            _restartButton.visible = true;
            _hero.rotation = 90;
            _hero.physicsBody.allowsRotation = false;
            _hero.stopAllActions();
            _hero.paused = true;

            let moveBy = CCActionMoveBy(duration: 0.2, position: ccp(-2, 2));
            let reverseMovement = moveBy.reverse();
            let shakeSequence = CCActionSequence.actionWithArray([moveBy, reverseMovement]) as CCActionSequence;
            let bounce = CCActionEaseBounce.actionWithAction(shakeSequence) as CCActionEaseBounce;
            self.runAction(bounce);
        }
    }

    // restarting the game
    func restart()
    {
        let scene = CCBReader.loadAsScene("MainScene");
        CCDirector.sharedDirector().replaceScene(scene);
    }

    #if os(iOS)
    // touch handler - this code works only on iOS devices
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        self.doFlap();
    }
    #elseif os(OSX)
    // mouse down handler - this code works only on OS X
    override func mouseDown(theEvent: NSEvent!)
    {
        self.doFlap();
    }
    #endif

    // flap!!!
    func doFlap()
    {
        if !_gameOver
        {
            _hero.physicsBody.applyImpulse(ccp(0, CGFloat(400)));
            _hero.physicsBody.applyAngularImpulse(CGFloat(10_000));
            _sinceTouch = 0;
        }
    }

    // spawn new obstacles
    func spawnNewObstacle()
    {
        let previousObstacle = _obstacles.last;
        var previousObstacleXPosition: CGFloat;

        if previousObstacle != nil
        {
            previousObstacleXPosition = previousObstacle!.position.x;
        }
        else
        {
            previousObstacleXPosition = firstObstaclePosition;
        }

        // load new obstacle from file and place it on right side
        let obstacle = CCBReader.load("Obstacle") as Obstacle;
        obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
        // randomize obstacle vertical position and fix drawing order
        obstacle.zOrder = DrawingOrder.DrawingOrderPipes.rawValue;
        obstacle.setupRandomPosition();

        // add new obstacle to scene
        _physicsNode.addChild(obstacle);
        _obstacles.append(obstacle);
    }

    // scene update
    override func update(delta: CCTime)
    {
        // scrolling code
        // multiplication CCTime on CGFloat does not work without of the override "*" operator
        _hero.position = ccp(_hero.position.x + (delta * _scrollSpeed), _hero.position.y);
        _physicsNode.position = ccp(_physicsNode.position.x - (delta * _scrollSpeed), _physicsNode.position.y);

        // clamp vertical velocity of hero
        let yVelocity: Float = clampf(Float(_hero.physicsBody.velocity.y), -Float(Int.max), 200);
        _hero.physicsBody.velocity = ccp(0, CGFloat(yVelocity));

        // clamp angular velocity and rotation of hero
        _sinceTouch += delta;
        _hero.rotation = clampf(_hero.rotation, -30, 90);
        if _hero.physicsBody.allowsRotation
        {
            let angularVelocity = clampf(Float(_hero.physicsBody.angularVelocity), -2, 1);
            _hero.physicsBody.angularVelocity = CGFloat(angularVelocity);
        }
        if _sinceTouch > 0.5
        {
            _hero.physicsBody.applyAngularImpulse(-40_000 * delta);
        }

        // respawn the obstacles when they out of screen
        var offScreenObstacles = Array<CCNode>();
        for obstacle in _obstacles
        {
            let obstacleWorldPosition: CGPoint = _physicsNode.convertToWindowSpace(obstacle.position);
            let obstacleScreenPosition: CGPoint = self.convertToNodeSpace(obstacleWorldPosition);
            if obstacleScreenPosition.x < -obstacle.contentSize.width
            {
                offScreenObstacles.append(obstacle);
            }
        }
        if !offScreenObstacles.isEmpty
        {
            for (i, obstacleToRemove) in enumerate(offScreenObstacles)
            {
                obstacleToRemove.removeFromParent();
                _obstacles.removeAtIndex(i);
                self.spawnNewObstacle();
            }
        }

        // reposition the grounds when they out of screen
        for ground in _grounds
        {
            let groundWorldPosition = _physicsNode.convertToWorldSpace(ground.position);
            let groundScreenPosition = self.convertToNodeSpace(groundWorldPosition);
            if groundScreenPosition.x <= -(ground.contentSize.width)
            {
                ground.zOrder = DrawingOrder.DrawingOrderGround.rawValue;
                ground.position = ccp(ground.position.x + (CGFloat(2) * ground.contentSize.width), ground.position.y);
            }
        }
    }

}




