//
//  SKScrollableNode.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit

class SKScrollableNode: SKSpriteNode {
    var scrollSpeed:CGFloat = 1.0
    
    convenience init(size:CGSize, imageNamed: String) {
        self.init()
        let texture = SKTexture.init(imageNamed: imageNamed)
        self.texture = texture
        self.size = size
        var xpos:CGFloat = 0
        while xpos < size.width * 2 {
            let sub = SKSpriteNode.init(imageNamed: imageNamed)
            sub.position = .init(x: xpos, y: 0)
            sub.anchorPoint = .zero
            sub.size = size
            addChild(sub)
            xpos += size.width
        }
    }
    func enableScroll() {
        let scroll = SKAction.run {
            let array = self.children as! [SKSpriteNode]
            for sub in array {
                sub.position = .init(x: sub.position.x - self.scrollSpeed, y: sub.position.y)
                if sub.position.x <= -self.size.width {
                    sub.position = .init(x: self.size.width * CGFloat(array.count - 1), y: sub.position.y)
                }
            }
        }
        let interval:TimeInterval = 1.0/60.0
        let wait = SKAction.wait(forDuration: interval)
        let sequence = SKAction.sequence([scroll, wait])
        let forever = SKAction.repeatForever(sequence)
        run(forever, withKey: "forever")
    }
    func disableScroll() {
        removeAction(forKey: "forever")
    }
}
