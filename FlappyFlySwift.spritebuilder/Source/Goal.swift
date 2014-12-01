//
//  Goal.swift
//  FlappyFlySwift
//
//  Created by Aleksey Zhilin (synthetic@nm.ru) on 01.12.14.
//  Copyright (c) 2014 Aleksey Zhilin. All rights reserved.
//
//  This code based on original tutorial from site https://www.makeschool.com
//  Link to original post writen by benjaminencz
//  https://www.makeschool.com/gamernews/369/build-your-own-flappy-bird-with-spritebuilder-and
//

class Goal: CCNode
{
    // prepare physics collision behavior for goal node
    func didLoadFromCCB()
    {
        self.physicsBody.collisionType = "goal";
        self.physicsBody.sensor = true;
    }
}



