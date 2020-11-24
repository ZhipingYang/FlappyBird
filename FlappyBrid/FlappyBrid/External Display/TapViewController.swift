//
//  TapViewController.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2019/11/7.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

import GameController
import UIKit

class TapViewController: UIViewController {
    lazy var textLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .darkText
        $0.text = "No Game Controller"
        $0.font = UIFont.systemFont(ofSize: 22)
    }

    lazy var actionBtn = UIButton(type: .roundedRect).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
        $0.setTitle("Jump", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addSubview(actionBtn)
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),

            actionBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            actionBtn.widthAnchor.constraint(equalToConstant: 120),
            actionBtn.heightAnchor.constraint(equalToConstant: 60),
        ])
        addNotis()
        ControlCentre.subscrpt(self)
    }

    private func addNotis() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: nil) { [unowned self] notification in
            guard let controller = notification.object as? GCController else { return }
            if #available(iOS 13.0, *) {
                self.textLabel.text = controller.productCategory
            } else {
                self.textLabel.text = controller.vendorName
            }
        }
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: nil) { [unowned self] notification in
            self.textLabel.text = "Disconnected"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        ControlCentre.trigger(.touch(touch))
    }

    @objc func actionClick() {
        ControlCentre.trigger(.touch(nil))
    }
}

extension TapViewController: ControlCentreDelegate {
    func callback(_ event: EventType) {
        if case .gameover = event {
            actionBtn.setTitle("Restart", for: .normal)
        } else {
            actionBtn.setTitle("Jump", for: .normal)
        }

        guard case .touch = event else { return }

        let dot = UIView().then {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .lightGray
            $0.frame = CGRect(x: 0, y: 0, width: 120, height: 60)
            $0.layer.cornerRadius = 30
            $0.layer.masksToBounds = true
            $0.center = actionBtn.center
        }
        view.addSubview(dot)

        UIView.animate(withDuration: 0.6, animations: {
            dot.alpha = 0
            dot.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { finished in
            dot.removeFromSuperview()
        }
    }
}
