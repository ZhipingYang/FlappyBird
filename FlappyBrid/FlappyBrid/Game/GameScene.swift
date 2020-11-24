//
//  GameScene.swift
//  FlappyBrid
//
//  Created by Daniel on 2/2/16.
//  Copyright (c) 2016 XcodeYang. All rights reserved.
//

import SpriteKit

extension SKTexture {
    var width: CGFloat { size().width }
    var height: CGFloat { size().height }
}

extension SKNode {
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
}

struct PhysicsCatagory {
    static let bird: UInt32 = 0x1 << 0
    static let land: UInt32 = 0x1 << 1
    static let pipe: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
}

struct GamezPosition {
    static let sky: CGFloat = -2
    static let pipe: CGFloat = -1
    static let score: CGFloat = 1
    static let result: CGFloat = 2
    static let resultText: CGFloat = 3
}

class GameScene: SKScene {
    let pipeTextureUp = SKTexture(imageNamed: "PipeUp").then { $0.filteringMode = .nearest }
    let pipeTextureDown = SKTexture(imageNamed: "PipeDown").then { $0.filteringMode = .nearest }
    let groundTexture = SKTexture(imageNamed: "land").then { $0.filteringMode = .nearest }
    let skyTexture = SKTexture(imageNamed: "sky").then { $0.filteringMode = .nearest }
    let birdTexture1 = SKTexture(imageNamed: "bird-1").then { $0.filteringMode = .nearest }
    let birdTexture2 = SKTexture(imageNamed: "bird-2").then { $0.filteringMode = .nearest }
    let birdTexture3 = SKTexture(imageNamed: "bird-3").then { $0.filteringMode = .nearest }

    var skyColor = SKColor(red: 81.0 / 255.0, green: 192.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
    let verticalPipeGap: CGFloat = 150.0
    var canRestart = false
    var moving = SKNode()
    var pipes = SKNode()
    var score = 0 {
        didSet { scoreLabelNode.text = String(score) }
    }

    lazy var bird = SKSpriteNode(texture: birdTexture1).then { bird in
        bird.setScale(2.0)
        bird.position = CGPoint(x: width / 2.5, y: frame.midY)
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2, birdTexture3, birdTexture2], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(anim))
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.height / 2.0).then {
            $0.isDynamic = true
            $0.allowsRotation = false
            $0.categoryBitMask = PhysicsCatagory.bird
            $0.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
            $0.contactTestBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
        }
    }

    lazy var ground = SKNode().then { ground in
        ground.position = CGPoint(x: 0, y: groundTexture.height)
        let size = CGSize(width: self.width, height: groundTexture.height * 2.0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: size).then {
            $0.isDynamic = false
            $0.categoryBitMask = PhysicsCatagory.land
        }
    }

    lazy var scoreLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide").then {
        $0.position = CGPoint(x: frame.midX, y: 3 * self.height / 4)
        $0.zPosition = GamezPosition.score
    }

    lazy var resultNode = ResultBoard(score: score).then {
        $0.zPosition = GamezPosition.result
        $0.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    }

    override func didMove(to view: SKView) {
        canRestart = true

        physicsWorld.gravity = CGVector(dx: 0.0, dy: -7.0)
        physicsWorld.contactDelegate = self
        backgroundColor = skyColor

        addChild(moving)
        moving.addChild(pipes)

        // ground
        let groundWidth = groundTexture.width * 2.0
        let moveGroundSprite = SKAction.moveBy(x: -groundWidth, y: 0, duration: TimeInterval(0.02 * groundWidth))
        let resetGroundSprite = SKAction.moveBy(x: groundWidth, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        for i in 0..<2 + Int(width / groundWidth) {
            moving.addChild(SKSpriteNode(texture: groundTexture).then {
                $0.setScale(2.0)
                $0.position = CGPoint(x: CGFloat(i) * $0.width, y: $0.height / 2.0)
                $0.run(moveGroundSpritesForever)
            })
        }
        // skyline
        let skyWidth = skyTexture.width * 2.0
        let moveSkySprite = SKAction.moveBy(x: -skyWidth, y: 0, duration: TimeInterval(0.1 * skyWidth))
        let resetSkySprite = SKAction.moveBy(x: skyWidth, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        for i in 0..<2 + Int(width / skyWidth) {
            moving.addChild(SKSpriteNode(texture: skyTexture).then {
                $0.setScale(2.0)
                $0.zPosition = GamezPosition.sky
                $0.position = CGPoint(x: CGFloat(i) * $0.width, y: $0.height / 2.0 + groundTexture.height * 2.0)
                $0.run(moveSkySpritesForever)
            })
        }
        // spawn the pipes
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnThenDelay))

        addChild(bird)
        addChild(ground)
        addChild(scoreLabelNode)
        score = 0
        moving.speed = 0
        bird.speed = 0
        bird.physicsBody?.isDynamic = false
        ControlCentre.subscrpt(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        ControlCentre.trigger(.touch(touch))
    }

    override func update(_ currentTime: TimeInterval) {
        let value = bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001)
        bird.zRotation = min(max(-1, value), 0.5)
    }

    @objc private func touchAction() {
        if !isUserInteractionEnabled { return }

        if moving.speed > 0 {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        } else if canRestart {
            resetScene()
        }
    }

    private func spawnPipes() {
        let height = UInt32(self.height / 4)
        let y = CGFloat(arc4random_uniform(height) + height)
        let pipeDown = SKSpriteNode(texture: pipeTextureDown).then { pipeDown in
            pipeDown.setScale(2.0)
            pipeDown.position = CGPoint(x: 0.0, y: y + pipeDown.height + verticalPipeGap)
            pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.pipe
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }
        let pipeUp = SKSpriteNode(texture: pipeTextureUp).then { pipeUp in
            pipeUp.setScale(2.0)
            pipeUp.position = CGPoint(x: 0.0, y: y)
            pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.pipe
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }
        let contactNode = SKNode().then { contactNode in
            contactNode.position = CGPoint(x: pipeDown.width + bird.width / 2, y: frame.midY)
            let size = CGSize(width: pipeUp.width, height: self.height)
            contactNode.physicsBody = SKPhysicsBody(rectangleOf: size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.score
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }

        // the pipes move actions
        let distanceToMove = width + 2.0 * pipeTextureUp.width
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let movePipesAndRemove = SKAction.sequence([movePipes, removePipes])

        pipes.addChild(SKNode().then {
            $0.position = CGPoint(x: width + pipeTextureUp.width * 2, y: 0)
            $0.zPosition = GamezPosition.pipe
            $0.addChild(pipeDown)
            $0.addChild(pipeUp)
            $0.addChild(contactNode)
            $0.run(movePipesAndRemove)
        })
    }

    func resetScene() {
        bird.speed = 1.0
        bird.zRotation = 0.0
        bird.position = CGPoint(x: width / 2.5, y: frame.midY)
        bird.physicsBody?.do {
            $0.isDynamic = true
            $0.velocity = CGVector(dx: 0, dy: 0)
            $0.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
        }
        score = 0
        moving.speed = 1
        canRestart = false
        pipes.removeAllChildren()
        resultNode.removeFromParent()
        touchAction()
    }

    func gameOver() {
        moving.speed = 0
        bird.speed = 0
        canRestart = true
        bird.physicsBody?.collisionBitMask = PhysicsCatagory.land
        addChild(resultNode.then {
            $0.score = score
            $0.run(SKAction.sequence([
                SKAction.scale(to: 1, duration: 0.1),
                SKAction.scale(to: 1.25, duration: 0.1),
            ]))
        })
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed <= 0 { return }

        if (contact.bodyA.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score || (contact.bodyB.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score {
            score += 1
            scoreLabelNode.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1),
            ]))
        } else {
            ControlCentre.trigger(.gameover)

            isUserInteractionEnabled = false

            removeAction(forKey: "flash_background_color")
            let red = SKAction.run { self.backgroundColor = SKColor.red }
            let sky = SKAction.run { self.backgroundColor = self.skyColor }
            let gap = SKAction.wait(forDuration: 0.06)
            let repeatSequence = SKAction.repeat(SKAction.sequence([red, gap, sky, gap]), count: 3)
            let wait = SKAction.wait(forDuration: 0.6)
            let finished = SKAction.run {
                self.isUserInteractionEnabled = true
            }
            run(SKAction.sequence([repeatSequence, wait, finished]), withKey: "flash_background_color")
        }
    }
}

extension GameScene: ControlCentreDelegate {
    func callback(_ event: EventType) {
        switch event {
        case .touch:
            touchAction()
        case .restart:
            resetScene()
        case .gameover:
            gameOver()
        }
    }
}
