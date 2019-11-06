//
//  GameViewController.swift
//  FlappyBrid
//
//  Created by Daniel on 2/2/16.
//  Copyright (c) 2016 XcodeYang. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override var shouldAutorotate: Bool { true }
    override var prefersStatusBarHidden: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let scene = GameScene(fileNamed:"GameScene"),
            let skView = self.view as? SKView
            else { return }
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}
