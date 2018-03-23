# FlapyBird
Swift4写的经典小游戏SpriteKit版像素鸟

![](/imgs/demo.png)

# 部分代码预览

```swift
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
```

```swift
private func createPipes() {
        let marginx:CGFloat = 65 + size.width
        let width:CGFloat = 52.0
        let totalHeight = size.height - floor.size.height
        let maxPipeHeight = totalHeight - kPipeVoidGap - kMinPipeHeight
        let count = pipesInScreen()
        for i in 0 ..< count {
            let xpos = marginx + (width + kPipeGapx) * CGFloat(i)
            let topHeight = CGFloat(arc4random_uniform(UInt32(maxPipeHeight + 1 - kMinPipeHeight))) + kMinPipeHeight
            let bottomHeight = totalHeight - kPipeVoidGap - topHeight
            let top = Pipe.init(imageNamed: "pipe_top2")
            top.type = .top
            top.position = .init(x: xpos, y: size.height - topHeight)
            top.anchorPoint = .zero
            top.physicsBody = SKPhysicsBody.init(edgeLoopFrom: .init(x: 0, y: 0, width: width, height: topHeight))
            top.physicsBody?.categoryBitMask = SKSpriteNodeBitMaskPipe
            top.physicsBody?.contactTestBitMask = SKSpriteNodeBitMaskBird
            addChild(top)
            topPipes.append(top)
            
            let bottom = Pipe.init(imageNamed: "pipe_bottom2")
            bottom.position = .init(x: xpos, y: bottomHeight - bottom.size.height + floor.size.height)
            bottom.anchorPoint = .zero
            bottom.type = .bottom
            bottom.physicsBody = SKPhysicsBody.init(edgeLoopFrom: .init(x: 0, y: bottom.size.height - bottomHeight, width: width, height: bottomHeight))
            bottom.physicsBody?.categoryBitMask = SKSpriteNodeBitMaskPipe
            bottom.physicsBody?.contactTestBitMask = SKSpriteNodeBitMaskBird
            addChild(bottom)
            bottomPipes.append(bottom)
        }
    }
```

```swift
//MARK: -
//MARK: Update
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        guard stae == .playing else {
            return
        }
        updatePipes()
        updateScoreIfNeed()
    }
    private func updatePipes() {
        if topPipes.count == 0 || bottomPipes.count == 0 {
            return
        }
        let width:CGFloat = 52.0
        let totalHeight = size.height - floor.size.height
        let maxPipeHeight = totalHeight - kPipeVoidGap - kMinPipeHeight
        let maxXpos = (width + kPipeGapx) * CGFloat(pipesInScreen())
        for i  in 0..<pipesInScreen() {
            let topPipe = topPipes[i]
            let bottomPipe = bottomPipes[i]
            let topHeight = CGFloat(arc4random_uniform(UInt32(maxPipeHeight + 1 - kMinPipeHeight))) + kMinPipeHeight
            topPipe.position = .init(x: topPipe.position.x - kPipeSpeed, y: topPipe.position.y)
            if topPipe.position.x <= -size.width {
                let xpos = maxXpos + topPipe.position.x
                topPipe.position = .init(x: xpos, y: size.height - topHeight)
            }
            bottomPipe.position = .init(x: bottomPipe.position.x - kPipeSpeed, y: bottomPipe.position.y)
            if bottomPipe.position.x <= -size.width {
                let xpos = maxXpos + bottomPipe.position.x
                let bottomHeight = totalHeight - kPipeVoidGap - topHeight
                bottomPipe.position = .init(x: xpos, y: bottomHeight - bottomPipe.size.height + floor.size.height)
            }
        }
    }
    private func resetPipePosition() {
        if topPipes.count == 0 || bottomPipes.count == 0 {
            return
        }
        let marginx:CGFloat = 65 + size.width
        let width:CGFloat = 52.0
        let totalHeight = size.height - floor.size.height
        let maxPipeHeight = totalHeight - kPipeVoidGap - kMinPipeHeight
        for i  in 0..<pipesInScreen() {
            let top = topPipes[i]
            let bottom = bottomPipes[i]
            let xpos = marginx + (width + kPipeGapx) * CGFloat(i)
            let topHeight = CGFloat(arc4random_uniform(UInt32(maxPipeHeight + 1 - kMinPipeHeight))) + kMinPipeHeight
            let bottomHeight = totalHeight - kPipeVoidGap - topHeight
            top.position = .init(x: xpos, y: size.height - topHeight)
            bottom.position = .init(x: xpos, y: bottomHeight - bottom.size.height + floor.size.height)
        }
    }
    private func updateScoreIfNeed() {
        if scoreLb.isHidden {
            scoreLb.isHidden = false
        }
        for p in topPipes {
            let reference = p.position.x + p.size.width / 2
            let birdx = bird.position.x
            if birdx > reference && birdx < (reference + kPipeSpeed) {
                score += 1
                scoreLb.text = String(score)
                run(scoreSound)
            }
        }
        let best = UserDefaults.standard.integer(forKey: "best")
        if score > UInt(best) {
            UserDefaults.standard.set(Int(score), forKey: "best")
            UserDefaults.standard.synchronize()
        }
    }
    private func resetScore() {
        score = 0
        scoreLb.text = "0"
    }
}
```

```swift
//MARK: -
//MARK: Touches Began
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if stae == .playing {
            run(jumpSound)
            bird.flap()
        } else if stae == .gameover {
            stae = .ready
            lose.removeFromParent()
            resetPipePosition()
            bird.position = birdStartPosition
            addTips()
            bird.ready()
            scoreLb.isHidden = true
            resetScore()
        } else {//ready
            stae = .playing
            removeTips()
            bird.go()
            createPipes()
        }
    }
}
//MARK: -
//MARK: SKPhysicsContactDelegate
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        if stae == .gameover {
            return
        }
        gameover()
    }
}
//MARK: -
//MARK: Game Over
extension GameScene {
    private func gameover() {
        stae = .gameover
        run(collsionSound)
        shake()
        showScore()
        self.bird.die()
        isUserInteractionEnabled = false
        run(SKAction.wait(forDuration: 2), completion: {
            self.bird.physicsBody = nil
            self.isUserInteractionEnabled = true
        })
    }
    private func shake() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let animation = CABasicAnimation.init(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint.init(x: size.width/2 - 4.0, y: size.height/2)
        animation.toValue = CGPoint.init(x: size.width/2 + 4.0, y: size.height/2)
        view?.layer.add(animation, forKey: "position")
    }
    private func showScore() {
        addChild(lose)
        resultLb.text = String(score)
        bestLb.text = String(UserDefaults.standard.integer(forKey: "best"))
        var img  = "bronze"
        if score >= 40 {
            img = "platinum"
        }else if score >= 30 {
            img = "gold"
        }else if score >= 20 {
            img = "silver"
        }else if score >= 10 {
            img = "bronze"
        }else{
            img = "bronze"
        }
        if img.count == 0 {
            medal.isHidden = true
        }else{
            medal.isHidden = false
        }
        medal.texture = SKTexture.init(imageNamed: img)
    }
}
```

```swift
import UIKit
import SpriteKit

class Bird: SKSpriteNode {
    private var flapAction:SKAction?
    
    class func bird() -> Bird {
        let b = Bird()
        b.texture = SKTexture.init(imageNamed: "frog")
        b.size = .init(width: 34, height: 28)

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
    }
}

```

```swift
import UIKit
import SpriteKit

enum PipeType {
    case top
    case bottom
}

class Pipe: SKSpriteNode {
    var type:PipeType = .top
}
```
