//
//  GameScene.swift
//  FlappyBrid
//
//  Created by Daniel on 2/2/16.
//  Copyright (c) 2016 XcodeYang. All rights reserved.
//

import SpriteKit

public extension CGFloat{
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}

struct PhysicsCatagory {
    static let ghost    : UInt32 = 0x1 << 1
    static let ground   : UInt32 = 0x1 << 2
    static let wall     : UInt32 = 0x1 << 3
    static let score    : UInt32 = 0x1 << 4
}

class GameScene: SKScene {
    
    lazy var ground = SKSpriteNode(imageNamed: "ground").then { ground in
        ground.setScale(0.5)
        ground.zPosition = 3
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size).then {
            $0.categoryBitMask = PhysicsCatagory.ground
            $0.collisionBitMask = PhysicsCatagory.ghost
            $0.contactTestBitMask = PhysicsCatagory.ghost
            $0.isDynamic = false
            $0.affectedByGravity = false
        }
    }
    
    lazy var ghost = SKSpriteNode(imageNamed: "ghost").then { ghost in
        ghost.zPosition = 2
        ghost.physicsBody = SKPhysicsBody(rectangleOf: ghost.size).then {
            $0.categoryBitMask = PhysicsCatagory.ghost
            $0.collisionBitMask = PhysicsCatagory.ground | PhysicsCatagory.wall
            $0.contactTestBitMask = PhysicsCatagory.ground | PhysicsCatagory.wall | PhysicsCatagory.score
            $0.isDynamic = true
            $0.affectedByGravity = false
        }
    }
    
    var wallPair = SKNode()
    var restartBtn = SKLabelNode()
    let scoreLabel = SKLabelNode().then {
        $0.fontSize = 60
        $0.zPosition = 5
    }
    
    var moveAndRemove = SKAction()
    
    var died = false
    var gameStarted = false
    var score = 0 {
        didSet { scoreLabel.text = "\(score)" }
    }
    
    func creatScene() {
        scoreLabel.position = CGPoint(x: frame.width/2, y: frame.height/2 + frame.height/2.5)
        addChild(scoreLabel)
        ground.position = CGPoint(x: frame.width/2, y: ground.frame.height/2)
        addChild(ground)
        ghost.position = CGPoint(x: self.frame.width/2 - ghost.frame.width, y: self.frame.height/2)
        addChild(ghost)
    }
    
    func restartScene() {
        removeAllActions()
        removeAllChildren()
        died = false
        gameStarted = false
        score = 0
        creatScene()
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        creatScene()
        ControlCentre.subscrpt(self)
    }
    
    func showRestartButton() {
        died = true
        restartBtn = SKLabelNode(text: "RESTART").then {
            $0.color = SKColor.blue
            $0.fontSize = 50
            $0.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            $0.zPosition = 6
        }
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.4))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        ControlCentre.trigger(touch)
    }
    
    func creatWalls() {
        let topwall = SKSpriteNode(imageNamed: "wall").then { topwall in
            topwall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 + 350)
            topwall.setScale(0.5)
            topwall.zRotation = CGFloat.pi
            topwall.physicsBody = SKPhysicsBody(rectangleOf: topwall.size).then {
                $0.categoryBitMask = PhysicsCatagory.wall
                $0.collisionBitMask = PhysicsCatagory.ghost
                $0.contactTestBitMask = PhysicsCatagory.ghost
                $0.isDynamic = false
                $0.affectedByGravity = false
            }
        }
        let btmwall = SKSpriteNode(imageNamed: "wall").then { btmwall in
            btmwall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 - 350)
            btmwall.setScale(0.5)
            btmwall.physicsBody = SKPhysicsBody(rectangleOf: btmwall.size).then {
                $0.categoryBitMask = PhysicsCatagory.wall
                $0.collisionBitMask = PhysicsCatagory.ghost
                $0.contactTestBitMask = PhysicsCatagory.ghost
                $0.isDynamic = false
                $0.affectedByGravity = false
            }
        }
        let scoreNode = SKSpriteNode().then { s in
            s.size = CGSize(width: 1, height: 200)
            s.color = SKColor.green
            s.position = CGPoint(x: self.frame.width, y: self.frame.height/2)
            s.physicsBody = SKPhysicsBody(rectangleOf: s.size).then {
                $0.affectedByGravity = false
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.score
                $0.collisionBitMask = 0
                $0.contactTestBitMask = PhysicsCatagory.ghost
            }
        }
        wallPair = SKNode().then {
            $0.position.y += CGFloat.random(min: -200, max: 200)
            $0.name = "wallPair"
            $0.zPosition = 1
            $0.addChild(topwall)
            $0.addChild(btmwall)
            $0.addChild(scoreNode)
            $0.run(moveAndRemove)
            addChild($0)
        }
    }
}

extension GameScene: ControlCentreDelegate {
    func callback(_ touch: UITouch) {
        if gameStarted == false {
            gameStarted = true
            score = 0
            let spawnDelay = SKAction.sequence([
                SKAction.run { self.creatWalls() },
                SKAction.wait(forDuration: 2.0)
            ])
            run(SKAction.repeatForever(spawnDelay))
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            moveAndRemove = SKAction.sequence([
                SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance)),
                SKAction.removeFromParent()
            ])
            ghost.physicsBody?.affectedByGravity = true
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            
        } else if died == false {
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
        }
        
        if died, restartBtn.contains( touch.location(in: self)) {
            restartScene()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score ||
            (secondBody.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score {
            score += 1
            if firstBody.categoryBitMask == PhysicsCatagory.score {
                firstBody.node?.removeFromParent()
            } else {
                secondBody.node?.removeFromParent()
            }
        }
        
        if (firstBody.categoryBitMask == PhysicsCatagory.ghost && secondBody.categoryBitMask == PhysicsCatagory.wall )
            || (firstBody.categoryBitMask == PhysicsCatagory.wall && secondBody.categoryBitMask == PhysicsCatagory.ghost)
            || (firstBody.categoryBitMask == PhysicsCatagory.ground && secondBody.categoryBitMask == PhysicsCatagory.ghost)
            || (firstBody.categoryBitMask == PhysicsCatagory.ghost && secondBody.categoryBitMask == PhysicsCatagory.ground) {
            showRestartButton()
            self.removeAllActions()
            enumerateChildNodes(withName: "wallPair") { (node, _) in
                node.speed = 0
                self.removeAllActions()
            }
        }
    }
}

