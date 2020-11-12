//
//  ControlCentre.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2019/11/7.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

import GameController
import UIKit

enum EventType {
    case touch(_ touch: UITouch?)
    case restart
}

protocol ControlCentreDelegate {
    func callback(_ event: EventType)
}

class ControlCentre {
    static var share = ControlCentre()
    private var delegates = NSHashTable<AnyObject>.weakObjects()

    init() {
        addNotifications()
    }

    class func subscrpt(_ delegate: ControlCentreDelegate & AnyObject) {
        if share.delegates.contains(delegate) { return }
        share.delegates.add(delegate)
    }

    class func remove(_ delegate: ControlCentreDelegate & AnyObject) {
        share.delegates.remove(delegate)
    }

    class func trigger(_ event: EventType) {
        share.delegates.allObjects.forEach { ($0 as? ControlCentreDelegate)?.callback(event) }
    }
}

extension ControlCentre {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectController), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectController), name: .GCControllerDidDisconnect, object: nil)
    }

    @objc func didConnectController(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        let handler: GCControllerButtonValueChangedHandler = { button, value, pressed in
            guard pressed else { return }
            ControlCentre.trigger(.touch(nil))
        }
        controller.extendedGamepad?.dpad.up.pressedChangedHandler = handler
        controller.extendedGamepad?.buttonA.pressedChangedHandler = handler
        controller.extendedGamepad?.buttonB.pressedChangedHandler = handler
        controller.extendedGamepad?.buttonX.pressedChangedHandler = handler
        controller.extendedGamepad?.buttonY.pressedChangedHandler = handler
    }

    @objc func didDisconnectController() {}
}
