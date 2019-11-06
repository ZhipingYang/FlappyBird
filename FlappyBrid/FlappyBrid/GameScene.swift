//
//  GameScene.swift
//  FlappyBrid
//
//  Created by Daniel on 2/2/16.
//  Copyright (c) 2016 XcodeYang. All rights reserved.
//

import SpriteKit

struct PhysicsCatagory {
    static let Ghost    : UInt32 = 0x1 << 1
    static let Ground   : UInt32 = 0x1 << 2
    static let Wall     : UInt32 = 0x1 << 3
    static let Score    : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    
    var wallPair = SKNode()

    var moveAndRemove = SKAction()
    
    let scoreLabel = SKLabelNode()
    
    var restartBtn = SKLabelNode()
    
    var died = Bool()
    
    var gameStarted = Bool()
    
    var score = Int()
    
    func creatScene() {
        
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        ground = SKSpriteNode(imageNamed: "ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width/2, y: ground.frame.height/2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        
        ground.zPosition = 3
        
        self.addChild(ground)
        
        
        
        ghost = SKSpriteNode(imageNamed: "ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: self.frame.width/2 - ghost.frame.width, y: self.frame.height/2)
        
        ghost.physicsBody = SKPhysicsBody(rectangleOf: ghost.size)
        ghost.physicsBody?.categoryBitMask = PhysicsCatagory.Ghost
        ghost.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        ghost.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        ghost.physicsBody?.isDynamic = true
        ghost.physicsBody?.affectedByGravity = false
        
        ghost.zPosition = 2
        
        self.addChild(ghost)

    }
    
    func restartScene() {
        
        self.removeAllActions()
        self.removeAllChildren()
        died = false
        gameStarted = false
        score = 0
        creatScene()
    }
    
    override func didMove(to view: SKView) {
        creatScene()
    }
    
    func creatBtn () {
        restartBtn = SKLabelNode(text: "RESTART")
        restartBtn.color = SKColor.blue
        restartBtn.fontSize = 50
        restartBtn.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        restartBtn.zPosition = 6
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.4))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Ghost)
            || (firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Score) {
                score += 1
                print("\(score)")
                scoreLabel.text = "\(score)"
                
                if firstBody.categoryBitMask == PhysicsCatagory.Score {
                    firstBody.node?.removeFromParent()
                } else {
                    secondBody.node?.removeFromParent()
                }
        }
        
        if (firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Wall )
        || (firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Ghost)
        || (firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Ghost)
        || (firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Ground){
                died = true
                creatBtn()
            self.removeAllActions()
            
            enumerateChildNodes(withName: "wallPair", using:{
                (node, error) -> Void in
                node.speed = 0
                self.removeAllActions()
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted = true
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                self.creatWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))

        } else {
            
            if died == true {
                
            } else {
                ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            }
        }
        
        
        for touch in touches {
            let location = touch.location(in: self)
            if died == true {
                if restartBtn.contains(location) {
                    restartScene()
                }
            }
        }
    }
    
    
    
    func creatWalls() {
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height/2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        scoreNode.color = SKColor.green
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topwall = SKSpriteNode(imageNamed: "wall")
        let btmwall = SKSpriteNode(imageNamed: "wall")
        
        topwall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 + 350)
        btmwall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 - 350)
        
        topwall.setScale(0.5)
        btmwall.setScale(0.5)
        
        topwall.physicsBody = SKPhysicsBody(rectangleOf: topwall.size)
        topwall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topwall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        topwall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        topwall.physicsBody?.isDynamic = false
        topwall.physicsBody?.affectedByGravity = false
        
        btmwall.physicsBody = SKPhysicsBody(rectangleOf: btmwall.size)
        btmwall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        btmwall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        btmwall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        btmwall.physicsBody?.isDynamic = false
        btmwall.physicsBody?.affectedByGravity = false
        
        topwall.zRotation = CGFloat.pi
        
        wallPair.addChild(topwall)
        wallPair.addChild(btmwall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
    }
}



public extension CGFloat{
    static func random() -> CGFloat {
        let sum = Float(0xFFFFFFFF)
        return CGFloat(Float(arc4random()) / sum)
    }
    
    static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}
