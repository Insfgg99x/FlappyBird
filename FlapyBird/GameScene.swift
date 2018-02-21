//
//  GameScene.swift
//  FlapyBird
//
//  Created by xgf on 2018/2/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit
import AudioToolbox

enum GameState {
    case ready
    case playing
    case gameover
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var topPipes = [Pipe]()
    private var bottomPipes = [Pipe]()
    private var bird = Bird.bird()
    private var birdStartPosition = CGPoint.zero
    private var back = SKScrollableNode()
    private var floor = SKScrollableNode()
    private var ready = SKSpriteNode.init(imageNamed: "ready")
    private var tip = SKSpriteNode.init(imageNamed: "tip")
    private var stae:GameState = .ready
    private var scoreLb = SKLabelNode.init(fontNamed: "Helvetica-Bold")
    private var score:UInt = 0
    private var resultLb = SKLabelNode.init(fontNamed: "VCR OSD Mono")
    private var bestLb = SKLabelNode.init(fontNamed: "VCR OSD Mono")
    private var medal = SKSpriteNode.init(imageNamed: "")
    private var jumpSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    private var collsionSound = SKAction.playSoundFileNamed("collsion.caf", waitForCompletion: false)
    private var scoreSound = SKAction.playSoundFileNamed("score.caf", waitForCompletion: false)
    private lazy var lose:SKSpriteNode = {
        //116+38+20
        let node = SKSpriteNode.init(color: .clear, size: .init(width: 226, height: 174))
        var pos:CGPoint = .init(x: size.width/2 - 100, y: size.height/2 - 87)//6p
        var resultx = node.size.width - 30
        if size.width == 320 {
            pos = .init(x: size.width/2 - 80, y: size.height/2 - 87)//4s 5 5s 6 6s
            resultx = node.size.width - 55
        } else if size.width == 375 {
            pos = .init(x: size.width/2 - 92, y: size.height/2 - 87)//4s 5 5s 6 6s
            resultx = node.size.width - 40
        }
        node.position = pos
        //add sub nodes
        let gameover = SKSpriteNode.init(imageNamed: "gameover")
        gameover.position = .init(x: node.position.x, y: node.size.width - gameover.size.height/2)
        node.addChild(gameover)
        let bg = SKSpriteNode.init(imageNamed: "score_bg")
        bg.position = .init(x: node.position.x, y: node.size.height - bg.size.height/2)
        node.addChild(bg)
        
        resultLb.text = "0"
        resultLb.fontSize = 16
        resultLb.fontColor = .gray
        resultLb.horizontalAlignmentMode = .right
        resultLb.position = .init(x: resultx, y: 125)
        node.addChild(resultLb)
        
        bestLb.text = "0"
        bestLb.fontSize = 16
        bestLb.fontColor = .gray
        bestLb.horizontalAlignmentMode = .right
        bestLb.position = .init(x: resultx, y: 85)
        node.addChild(bestLb)
        
        medal.position = .init(x: 41, y: 109)
        medal.size = .init(width: 44, height: 44)
        medal.isHidden = true
        node.addChild(medal)
        
        return node
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(size: CGSize) {
        super.init(size: size)
        setup()
        addBackNode()
        addBird()
        addTips()
    }
    private func setup() {
        physicsWorld.contactDelegate = self
        stae = .ready
        let bgSound = SKAction.playSoundFileNamed("bg.caf", waitForCompletion: false)
        let duration = SKAction.wait(forDuration: 30)
        let bgSoundSequence = SKAction.sequence([bgSound, duration])
        let repeatSound = SKAction.repeatForever(bgSoundSequence)
        run(repeatSound)
    }
}
//MARK: -
//MARK: Create Notes
extension GameScene {
    private func addBackNode() {
        back = SKScrollableNode.init(size: size, imageNamed: "back")
        back.position = .zero
        back.anchorPoint = .zero
        back.size = size
        back.scrollSpeed = kBackSpeed
        back.physicsBody = SKPhysicsBody.init(edgeLoopFrom: back.frame)
        back.physicsBody?.categoryBitMask = SKSpriteNodeBitMaskBack
        back.physicsBody?.contactTestBitMask = SKSpriteNodeBitMaskBird
        addChild(back)
        back.enableScroll()
        
        floor = SKScrollableNode.init(size: .init(width: size.width, height: size.width * 212.0/616.0), imageNamed: "floor")
        floor.position = .zero
        floor.anchorPoint = .zero
        floor.zPosition = 1
        floor.scrollSpeed = kFloorSpeed
        floor.physicsBody = SKPhysicsBody.init(edgeLoopFrom: floor.frame)
        floor.physicsBody?.categoryBitMask = SKSpriteNodeBitMaskFloor
        floor.physicsBody?.contactTestBitMask = SKSpriteNodeBitMaskBird
        addChild(floor)
        floor.enableScroll()
        
        let font = size.height - floor.size.height - 100
        scoreLb.fontSize = font
        scoreLb.position = .init(x: size.width/2, y: floor.size.height + 150)
        scoreLb.fontColor = .white
        scoreLb.text = "0"
        scoreLb.alpha = 0.3
        scoreLb.isHidden = true
        addChild(scoreLb)
    }
    private func addBird() {
        birdStartPosition = .init(x: size.width/2-65, y: size.height/2)
        bird.position = birdStartPosition
        //bird.size = .init(width: 34, height: 28)
        addChild(bird)
        bird.ready()
    }
    private func addTips() {
        if ready.parent != nil {
            ready.removeFromParent()
        }
        ready.position = .init(x: bird.position.x + ready.size.width / 2, y: bird.position.y + 80)
        addChild(ready)
        if tip.parent != nil {
            tip.removeFromParent()
        }
        tip.position = .init(x: bird.position.x + 5 + tip.size.width / 2, y: bird.position.y - 30)
        addChild(tip)
    }
    private func removeTips() {
        ready.removeFromParent()
        tip.removeFromParent()
    }
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
            let top = Pipe.init(imageNamed: "pipe_top")
            top.type = .top
            top.position = .init(x: xpos, y: size.height - topHeight)
            top.anchorPoint = .zero
            top.physicsBody = SKPhysicsBody.init(edgeLoopFrom: .init(x: 0, y: 0, width: width, height: topHeight))
            top.physicsBody?.categoryBitMask = SKSpriteNodeBitMaskPipe
            top.physicsBody?.contactTestBitMask = SKSpriteNodeBitMaskBird
            addChild(top)
            topPipes.append(top)
            
            let bottom = Pipe.init(imageNamed: "pipe_bottom")
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
    private func removeAllPipes() {
        topPipes.forEach{
            $0.removeFromParent()
        }
        bottomPipes.forEach{
            $0.removeFromParent()
        }
    }
    private func pipesInScreen() -> Int {
        let count = Int(ceil(size.width / kPipeGapx)) + 1
        return count
    }
}
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
            back.enableScroll()
            floor.enableScroll()
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
        floor.disableScroll()
        back.disableScroll()
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
        var img  = ""
        if score >= 40 {
            img = "platinum"
        }else if score >= 30 {
            img = "gold"
        }else if score >= 20 {
            img = "silver"
        }else if score >= 10 {
            img = "bronze"
        }else{
            img = ""
        }
        if img.count == 0 {
            medal.isHidden = true
        }else{
            medal.isHidden = false
        }
        medal.texture = SKTexture.init(imageNamed: img)
    }
}
