//
//  ScreenMirror.swift
//  RoomsController
//
//  Created by Daniel Yang on 2019/11/4.
//  Copyright © 2019 RingCentral. All rights reserved.
//

import UIKit
import Then

class ScreenMirror: NSObject {
    static let share = ScreenMirror()
    private var externalWindow: UIWindow?

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectNotification(_:)), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectNotification(_:)), name: UIScreen.didDisconnectNotification, object: nil)
    }

    func end() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didConnectNotification(_ noti: Notification) {
        guard let newScreen = noti.object as? UIScreen else { return }
        externalWindow = UIWindow().then {
            $0.frame = newScreen.bounds
            $0.rootViewController = GameViewController()
            $0.screen = newScreen
            $0.isHidden = false
        }
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = TapViewController()
    }

    @objc func didDisconnectNotification(_ noti: Notification) {
        externalWindow?.isHidden = true
        externalWindow = nil
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = GameViewController()
    }
}
