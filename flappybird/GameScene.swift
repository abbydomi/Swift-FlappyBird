//
//  GameScene.swift
//  flappybird
//
//  Created by Abby Dominguez on 5/11/22.
//

import UIKit
import SpriteKit

struct PhysicsCategory {
    static let Player: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
    static let impulse = 80
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Player = SKSpriteNode()
    var wallPair = SKNode()

    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLabel = SKLabelNode()
    var gameOver = Bool()
    
    var gameOverLabelspr = SKSpriteNode()
    var restartbutton = SKSpriteNode()
    var buttonOk = SKSpriteNode()
    var taplabel = SKSpriteNode()
    var getreadylabel = SKSpriteNode()
    
    var soundHit = SKAction.playSoundFileNamed("hit", waitForCompletion: false)
    var soundFlap = SKAction.playSoundFileNamed("flap", waitForCompletion: false)
    var soundCoin = SKAction.playSoundFileNamed("coin", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        taplabel = SKSpriteNode(imageNamed: "taplabel")
        taplabel.texture?.filteringMode = .nearest
        taplabel.setScale(5)
        taplabel.position = CGPoint(x: 50,y: 0)
        taplabel.zPosition = 6
        self.addChild(taplabel)
        
        getreadylabel = SKSpriteNode(imageNamed: "getready")
        getreadylabel.texture?.filteringMode = .nearest
        getreadylabel.setScale(5)
        getreadylabel.position = CGPoint(x: 0,y: 320)
        getreadylabel.zPosition = 6
        self.addChild(getreadylabel)
        
        createScene()
    }
    
    func createbtn() {
        restartbutton = SKSpriteNode(imageNamed: "gameoverMenu")
        restartbutton.setScale(5)
        restartbutton.texture?.filteringMode = .nearest
        restartbutton.position = CGPoint(x: 0,y: -900)
        restartbutton.zPosition = 5
        
        gameOverLabelspr = SKSpriteNode(imageNamed: "gameoverlabel")
        gameOverLabelspr.texture?.filteringMode = .nearest
        gameOverLabelspr.setScale(5)
        gameOverLabelspr.position = CGPoint(x: 0, y: 320)
        gameOverLabelspr.zPosition = 6
        gameOverLabelspr.alpha = 0
        
        buttonOk = SKSpriteNode(imageNamed: "buttonOk")
        buttonOk.setScale(5)
        buttonOk.texture?.filteringMode = .nearest
        buttonOk.position = CGPoint(x: -600, y: -190)
        buttonOk.zPosition = 6
        
        gameOverLabelspr.run(SKAction.fadeAlpha(by: 1, duration: 0.3))
        
        self.addChild(gameOverLabelspr)
        self.addChild(restartbutton)
        self.addChild(buttonOk)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.restartbutton.run(SKAction.moveTo(y: 0, duration: 0.2))
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.buttonOk.run(SKAction.moveTo(x: 0, duration: 0.2))
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Player || secondBody.categoryBitMask == PhysicsCategory.Score && firstBody.categoryBitMask == PhysicsCategory.Player{
            
            score += 1
            scoreLabel.text = "\(score)"
            playSound(sound: soundCoin)
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Player || secondBody.categoryBitMask == PhysicsCategory.Wall && firstBody.categoryBitMask == PhysicsCategory.Player{
            if !gameOver{
                gameOver = true
                enumerateChildNodes(withName: "wallPair", using: {
                    (node, error) in
                    
                    node.speed = 0
                })
                self.removeAllActions()
                playSound(sound: soundHit)
                createbtn()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       if gameStarted {
           if !gameOver{
               Player.physicsBody?.velocity = CGVectorMake(0, 0)
               Player.physicsBody?.applyImpulse(CGVectorMake(0, CGFloat(PhysicsCategory.impulse)))
               Player.zRotation = 0.5
               Player.texture = SKTexture(imageNamed: "Player3")
               Player.texture?.filteringMode = .nearest
               playSound(sound: soundFlap)
           }
           
        } else {
           let spawn = SKAction.run({
                () in
                self.createWall()
            })
            let delay = SKAction.wait(forDuration: 1.3)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            let removeWalls = SKAction.removeFromParent()
            let moveWalls = SKAction.moveBy(x: -900, y: 0, duration: 2)
            moveAndRemove = SKAction.sequence([moveWalls, removeWalls])
            
            Player.physicsBody?.affectedByGravity = true
            Player.physicsBody?.velocity = CGVectorMake(0, 0)
            Player.physicsBody?.applyImpulse(CGVectorMake(0, CGFloat(PhysicsCategory.impulse)))
            Player.zRotation = 0.5
            Player.texture = SKTexture(imageNamed: "Player3")
            Player.texture?.filteringMode = .nearest
            playSound(sound: soundFlap)
        
            gameStarted = true
            
            taplabel.run(SKAction.fadeAlpha(by: -1, duration: 0.5))
            getreadylabel.run(SKAction.fadeAlpha(by: -1, duration: 0.5))
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if gameOver{
                if buttonOk.contains(location){
                    restartScene()
                }
            }
            
        }
        
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        gameOver = false
        gameStarted = false
        score = 0
        
        createScene()
    }
    
    func createScene(){
        for i in 0..<2{
            let bg = SKSpriteNode(imageNamed: "bg")
            bg.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            bg.name = "bg"
            bg.texture?.filteringMode = .nearest
            bg.size = self.frame.size
            self.addChild(bg)
        }
        for i in 0..<2{
            let ground = SKSpriteNode(imageNamed: "Ground")
            ground.position = CGPointMake(CGFloat(i) * self.frame.width, -self.frame.height/2+60)
            ground.name = "ground"
            ground.setScale(4.87)
            ground.texture?.filteringMode = .nearest
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            ground.zPosition = 3
            self.addChild(ground)
            
        }
        
        scoreLabel.position = CGPoint(x: 0, y: 500)
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 64
        scoreLabel.fontName = "04b_19"
        self.addChild(scoreLabel)
        
        Player = SKSpriteNode(imageNamed: "Player")
        Player.setScale(5)
        Player.texture?.filteringMode = .nearest
        Player.position = CGPoint(x: -150, y: 0)
        Player.physicsBody = SKPhysicsBody(circleOfRadius: Player.frame.height/2)
        Player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        Player.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Player.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Player.physicsBody?.affectedByGravity = false
        Player.physicsBody?.isDynamic = true
        Player.zPosition = 2
        self.addChild(Player)
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted && !gameOver {
            enumerateChildNodes(withName: "bg", using: ({
                (node, error) in
                
                let bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                }
            }))
        }
        if !gameOver{
            enumerateChildNodes(withName: "ground", using: ({
                (node, error) in
                
                let ground = node as! SKSpriteNode
                
                
                if ground.position.x <= -ground.size.width {
                    ground.position = CGPointMake(ground.position.x + ground.size.width * 2, ground.position.y)
                }
                ground.position = CGPoint(x: ground.position.x - 7.6, y: ground.position.y)
            }))
            
            if (Player.physicsBody?.velocity.dy)! < 0 {
                if Player.zRotation < 1.2 && Player.zRotation > -1.2{
                    Player.zRotation -= 0.12
                }
            }
        }
        
        if (Player.physicsBody?.velocity.dy)! < 408 {
            Player.texture = SKTexture(imageNamed: "Player2")
            if (Player.physicsBody?.velocity.dy)! < 200 {
                Player.texture = SKTexture(imageNamed: "Player")
            }
            Player.texture?.filteringMode = .nearest
        }
    }
    
    func createWall(){
        let scoreNode = SKSpriteNode()
        wallPair = SKNode()
        wallPair.name = "wallPair"
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        topWall.position = CGPoint(x: 400, y: self.frame.height/4+220)
        topWall.zRotation = CGFloat(Double.pi)
        bottomWall.position = CGPoint(x: 400, y: -self.frame.height/4-220)
        topWall.texture?.filteringMode = .nearest
        topWall.setScale(5)
        bottomWall.setScale(5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Player
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Player
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        scoreNode.size = CGSize(width: 1, height: 250)
        scoreNode.position = CGPoint(x: topWall.position.x, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.node?.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 1
        
        wallPair.addChild(scoreNode)
        
        let randomHeight = CGFloat.random(min: -300, max: 300)
        wallPair.position.y = wallPair.position.y + randomHeight
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    func playSound(sound: SKAction){
        run(sound)
    }
}

public extension CGFloat {
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    static func random(min :CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}
