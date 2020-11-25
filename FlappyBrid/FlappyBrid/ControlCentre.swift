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
        if #available(iOS 14.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(didConnectKeyboard), name: .GCKeyboardDidConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(didConnectMouse), name: .GCMouseDidConnect, object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectController), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectController), name: .GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery {
            print("there are no any game controller!")
        }
    }

    @objc func didConnectController(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
//        GCController.current

        let buttonAHandler: GCControllerButtonValueChangedHandler = { button, value, pressed in
            print("buttonA:\(button) value:\(value) pressed:\(pressed)")
            if #available(iOS 14.0, *) {
                let color = pressed ? GCColor(red: 1, green: 1, blue: 1) : GCColor(red: 0, green: 0, blue: 0)
                controller.light?.color = color
            }
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

        // test new iOS features
        let thumbstickHandler: GCControllerDirectionPadValueChangedHandler = { directionPad, x, y in
            print("directionPad:\(directionPad) x:\(x) y:\(y)")
        }
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = thumbstickHandler
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = thumbstickHandler

        if #available(iOS 14.0, *) {
            guard let motion = controller.motion else { return }
            if motion.sensorsRequireManualActivation {
                motion.sensorsActive = true
            }
            motion.valueChangedHandler = { motion in
                print(motion)
            }
        }
    }

    @available(iOS 14.0, *)
    @objc func didConnectKeyboard(_ notification: Notification) {
        guard
            let keyboard = notification.object as? GCKeyboard,
            let keyboardInput = keyboard.keyboardInput
        else { return }
//        GCKeyboard.coalesced

        let handle: GCControllerButtonValueChangedHandler = { keyboard, value, pressed in
            guard pressed else { return }
            ControlCentre.trigger(.jump(.keyboard))
        }
        keyboardInput.button(forKeyCode: .spacebar)?.valueChangedHandler = handle
        keyboardInput.button(forKeyCode: .upArrow)?.valueChangedHandler = handle
        keyboardInput.keyChangedHandler = { keyboard, key, keyCode, pressed in
            if (keyCode == .upArrow || keyCode == .spacebar) && pressed {
                print("jump key:\(key)")
            } else {
                print("other key:\(key)")
            }
        }
    }

    @available(iOS 14.0, *)
    @objc func didConnectMouse(_ notification: Notification) {
        guard let mouse = notification.object as? GCMouse else { return }
//        GCMouse.current

        mouse.mouseInput?.mouseMovedHandler = { mouse, x, y in
            print("mouse:\(mouse) x:\(x) y:\(y)")
        }
        mouse.mouseInput?.leftButton.pressedChangedHandler = { btn, value, pressed in
            guard pressed else { return }
            ControlCentre.trigger(.jump(.keyboard))
        }
    }

    @objc func didDisconnectController(_ notification: Notification) {}
}
