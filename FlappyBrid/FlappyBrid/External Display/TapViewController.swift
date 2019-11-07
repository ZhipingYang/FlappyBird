//
//  TapViewController.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2019/11/7.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

import UIKit

class TapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        ControlCentre.trigger(touch)
        
        let dot = UIView().then {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .lightGray
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
            $0.center = touch.location(in: view)
        }
        view.addSubview(dot)
        UIView.animate(withDuration: 0.6, animations: {
            dot.alpha = 0
            dot.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { (finished) in
            dot.removeFromSuperview()
        }
    }
}
