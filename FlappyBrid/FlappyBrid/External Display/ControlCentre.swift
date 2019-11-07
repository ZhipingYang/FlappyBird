//
//  ControlCentre.swift
//  FlappyBrid
//
//  Created by Daniel Yang on 2019/11/7.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

import UIKit

protocol ControlCentreDelegate {
    func callback(_ touch: UITouch)
}

class ControlCentre {
    static var share = ControlCentre()
    private var delegates = NSHashTable<AnyObject>.weakObjects()

    class func subscrpt(_ delegate: ControlCentreDelegate & AnyObject) {
        if share.delegates.contains(delegate) { return }
        share.delegates.add(delegate)
    }
    
    class func remove(_ delegate: ControlCentreDelegate & AnyObject) {
        share.delegates.remove(delegate)
    }
    
    class func trigger(_ touch: UITouch) {
        share.delegates.allObjects.forEach { ($0 as? ControlCentreDelegate)?.callback(touch) }
    }
}
