//
//  HapticsManager.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2020/11/24.
//  Copyright © 2020 XcodeYang. All rights reserved.
//

import CoreHaptics
import GameController

fileprivate enum HapticType {
    case jump(type: EventType.JumpType), dead
    var fileText: String {
        switch self {
        case .jump: return "jump"
        case .dead: return "dead"
        }
    }

    var mapText: String {
        switch self {
        case let .jump(t): return "jump:\(t.rawValue)"
        case .dead: return "dead"
        }
    }
}

@available(iOS 14.0, *)
class HapticsManager {
    static let share = HapticsManager()

    private var controllers = [GCController]()
    private var engineMap = [String: CHHapticEngine?]()

    func start() {
        controllers = GCController.controllers()
        addNotifications()
        ControlCentre.subscrpt(self)
    }

    func stop() {
        controllers.removeAll()
        NotificationCenter.default.removeObserver(self)
        ControlCentre.remove(self)
    }

    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectController), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectController), name: .GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery {
            print("there are no any game controller!")
        }
    }

    @objc func didConnectController(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        if !controllers.contains(controller) {
            controllers.append(controller)
        }
    }

    @objc func didDisconnectController(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        if controllers.contains(controller) {
            controllers.append(controller)
        }
    }

    private func play(_ type: HapticType) {
        guard
            let engine = getEngine(type),
            let url = Bundle.main.url(forResource: type.fileText, withExtension: "ahap")
        else { return }

        do {
            try engine.start()
//            guard let pattern = try self.getPattern(type) else { return }
//            try engine.makePlayer(with: pattern)
            try engine.playPattern(from: url)
        } catch {
            print("The engine failed: \(error)")
        }
    }

    private func getEngine(_ type: HapticType) -> CHHapticEngine? {
        if let engine = engineMap[type.mapText] { return engine }

        var locality = GCHapticsLocality.default
        if case let .jump(type: jumpType) = type {
            switch jumpType {
            case .buttonA:
                locality = .rightHandle
            case .rightTrigger:
                locality = .rightTrigger
            default:
                return nil
            }
        }
        guard let engine = controllers.first?.haptics?.createEngine(withLocality: locality) else { return nil }
        engineMap[type.mapText] = engine
        return engine
    }

    private func getPattern(_ type: HapticType) throws -> CHHapticPattern? {
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
        ], relativeTime: 0, duration: 0.6)

        let firstTransientEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
        ], relativeTime: 0.2)

        let secondTransientEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
        ], relativeTime: 0.4)
        switch type {
        case .jump:
            let events = [continuousEvent]
            return try CHHapticPattern(events: events, parameters: [])
        case .dead:
            let events = [continuousEvent, firstTransientEvent, secondTransientEvent]
            return try CHHapticPattern(events: events, parameters: [])
        }
    }
}

@available(iOS 14.0, *)
extension HapticsManager: ControlCentreDelegate {
    func callback(_ event: EventType) {
        if case .gameover = event {
            play(.dead)
        } else if case let .jump(type) = event {
            play(.jump(type: type))
        }
    }
}
