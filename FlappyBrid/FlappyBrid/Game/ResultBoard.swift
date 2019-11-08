
//
//  ResultBoard.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2019/11/7.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

import SpriteKit

class ResultBoard: SKSpriteNode {
    private lazy var currentScore = SKLabelNode(fontNamed: "MarkerFelt-Wide").then {
        $0.fontSize = 16
        $0.fontColor = SKColor.darkText
    }

    private lazy var bestScore = SKLabelNode(fontNamed: "MarkerFelt-Wide").then {
        $0.fontSize = 16
        $0.fontColor = SKColor.darkText
        $0.text = String(ResultBoard.bestScore())
    }

    private lazy var medal = SKLabelNode(fontNamed: "MarkerFelt-Wide").then {
        $0.fontSize = 30
        $0.fontColor = SKColor.orange
    }

    var score: Int = 0 {
        didSet {
            currentScore.text = "\(score)"
            bestScore.text = "\(ResultBoard.bestScore())"
            medal.text = score < 3 ? "C" : (score < 10 ? "B" : (score < 15 ? "A" : "S"))
            ResultBoard.setBestScoreIfPossible(score)
        }
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(score: Int) {
        let image = SKTexture(imageNamed: "scoreboard").then { $0.filteringMode = .nearest }
        self.init(texture: image, color: UIColor.clear, size: image.size())
        addChild(currentScore)
        addChild(bestScore)
        addChild(medal)
        self.score = score
        currentScore.position = CGPoint(x: frame.midX + 75, y: frame.midY + 20)
        bestScore.position = CGPoint(x: frame.midX + 75, y: frame.midY - 25)
        medal.position = CGPoint(x: frame.midX - 64, y: frame.midY - 8)
    }
}

private extension ResultBoard {
    class func bestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "bestScore")
    }

    class func setBestScoreIfPossible(_ score: Int) {
        let best = UserDefaults.standard.integer(forKey: "bestScore")
        if score > best {
            UserDefaults.standard.set(score, forKey: "bestScore")
            UserDefaults.standard.synchronize()
        }
    }
}
