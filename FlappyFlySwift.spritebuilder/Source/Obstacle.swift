//
//  Obstacle.swift
//  FlappyFlySwift
//
//  Created by Aleksey Zhilin (synthetic@nm.ru) on 01.12.14.
//  Copyright (c) 2014 Aleksey Zhilin. All rights reserved.
//
//  This code based on original tutorial from site https://www.makeschool.com
//  Link to original post writen by benjaminencz
//  https://www.makeschool.com/gamernews/369/build-your-own-flappy-bird-with-spritebuilder-and
//

class Obstacle: CCNode
{
    // code connection vars from SpriteBuilder
    var _topPipe:    CCNode?;
    var _bottomPipe: CCNode?;

    // randomize division const
    let ARC4RANDOM_MAX:             Double  = 0x100000000;

    // pipes position constants
    let pipeDistance:               CGFloat = 142.0;
    let minimumYPositionTopPipe:    CGFloat = 128.0;
    let maximumYPositionBottomPipe: CGFloat = 440.0;

    // this const should be calculated during init()
    let maximumYPositionTopPipe:    CGFloat

    // initializer
    override init()
    {
        // calculate the const
        maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;
    }

    // prepare physics collision behavior for pipes
    func didLoadFromCCB()
    {
        _topPipe!.physicsBody.sensor           = true;
        _bottomPipe!.physicsBody.sensor        = true;
        _topPipe!.physicsBody.collisionType    = "level";
        _bottomPipe!.physicsBody.collisionType = "level";
    }

    // randomize pipes vertical position
    func setupRandomPosition()
    {
        let random = Double(arc4random()) / ARC4RANDOM_MAX;
        let range = maximumYPositionTopPipe - minimumYPositionTopPipe;
        _topPipe!.position = ccp(_topPipe!.position.x, minimumYPositionTopPipe + (random * range));
        _bottomPipe!.position = ccp(_bottomPipe!.position.x, _topPipe!.position.y + pipeDistance);
    }
}
