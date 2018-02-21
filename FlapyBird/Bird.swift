//
//  Bird.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit

class Bird: SKSpriteNode {
    private var flapAction:SKAction?
    
    class func bird() -> Bird {
        let b = Bird()
        b.texture = SKTexture.init(imageNamed: "bird_1")
        b.size = .init(width: 34, height: 28)
        var textures = [SKTexture]()
        for i in 1 ... 3 {
            let texture = SKTexture.init(imageNamed:"bird_\(i)")
            textures.append(texture)
        }
        b.flapAction = SKAction.animate(with: textures, timePerFrame:0.1)
        return b
    }
    //wait for start
    func ready() {
        var gapy:CGFloat = 0.0
        var speedy:CGFloat = 1.0
        let flashAction = SKAction.run {
            if gapy > 4 {
                speedy = -1.0
            }else if gapy < -4 {
                speedy = 1
            }
            self.position = CGPoint.init(x: self.position.x, y: self.position.y + gapy)
            gapy += speedy
        }
        let interval:TimeInterval = 1.0/60.0
        let wait = SKAction.wait(forDuration: interval)
        let sequence = SKAction.sequence([flashAction, wait])
        let foreverFlash = SKAction.repeatForever(sequence)
        run(foreverFlash, withKey: "flash_forever")
        
        let foreverFlapy = SKAction.repeatForever(flapAction!)
        run(foreverFlapy, withKey: "flapy_forever")
    }
    func die() {
        removeAction(forKey: "flapy_forever")
    }
    //start
    func go() {
        let body = SKPhysicsBody.init(rectangleOf: size)
        body.mass = 0.1
        body.categoryBitMask = SKSpriteNodeBitMaskBird
        physicsBody = body
        removeAction(forKey: "flash_forever")
        let rotation = SKAction.run {
            self.zRotation = .pi * body.velocity.dy * 0.0005
        }
        let wait = SKAction.wait(forDuration: 1.0/60.0)
        let sequence = SKAction.sequence([wait, rotation])
        run(SKAction.repeatForever(sequence), withKey: "rotation")
    }
    func flap() {
        let body = self.physicsBody!
        body.velocity = .init(dx: 0, dy: 0)
        body.applyImpulse(.init(dx: 0, dy: 40))
        run(self.flapAction!)
    }
}
