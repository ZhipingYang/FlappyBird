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
    enum JumpType: Int { case keyboard, touch, buttonA, rightTrigger }
    case jump(_ type: JumpType)
    case gameover
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

    class func subscribe(_ delegate: ControlCentreDelegate & AnyObject) {
        if share.delegates.contains(delegate) { return }
        share.delegates.add(delegate)
    }

    class func unsubscribe(_ delegate: ControlCentreDelegate & AnyObject) {
        if share.delegates.contains(delegate) {
            share.delegates.remove(delegate)
        }
    }

    class func trigger(_ event: EventType) {
        share.delegates.allObjects.forEach { ($0 as? ControlCentreDelegate)?.callback(event) }
    }
}

extension ControlCentre {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectController), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectController), name: .GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery {
            print("there are no any game controller!")
        }
    }

    @objc func didConnectController(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        let buttonAHandler: GCControllerButtonValueChangedHandler = { button, value, pressed in
            print("buttonA:\(button) value:\(value) pressed:\(pressed)")
            guard pressed else { return }
            ControlCentre.trigger(.jump(.buttonA))
        }
        let rightTriggerHandler: GCControllerButtonValueChangedHandler = { button, value, pressed in
            print("rightTrigger:\(button) value:\(value) pressed:\(pressed)")
            guard pressed else { return }
            ControlCentre.trigger(.jump(.rightTrigger))
        }
        controller.extendedGamepad?.buttonA.pressedChangedHandler = buttonAHandler
        controller.extendedGamepad?.rightTrigger.pressedChangedHandler = rightTriggerHandler

        let thumbstickHandler: GCControllerDirectionPadValueChangedHandler = { directionPad, x, y in
            print("directionPad:\(directionPad) x:\(x) y:\(y)")
        }
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = thumbstickHandler
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = thumbstickHandler
    }

    @objc func didDisconnectController(_ notification: Notification) {}
}
