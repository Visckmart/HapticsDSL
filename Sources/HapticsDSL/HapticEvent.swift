//
//  HapticsDSL.swift
//
//  Created by Victor Martins on 10/10/22.
//  Version 1.1
//

import Foundation
import CoreHaptics

open class HapticEvent {
    
    open var eventType: CHHapticEvent.EventType?
    open var duration: TimeInterval
    open var specificTime: TimeInterval?
    
    internal init(eventType: CHHapticEvent.EventType?,
                duration: TimeInterval,
                specificTime: TimeInterval?) {
        self.eventType = eventType
        self.duration = duration
        self.specificTime = specificTime
    }
    
}

open class TransientEvent: HapticEvent {
    
    public init(startingExactlyAt eventTime: TimeInterval? = nil) {
        super.init(eventType: .hapticTransient,
                   duration: 0.1,
                   specificTime: eventTime)
    }
    
}

open class ContinuousEvent: HapticEvent {
    
    public init(duration: TimeInterval,
                startingExactlyAt eventTime: TimeInterval? = nil) {
        super.init(eventType: .hapticContinuous,
                   duration: duration,
                   specificTime: eventTime)
    }
    
}

open class HapticDelay: HapticEvent {
    
    public init(duration: TimeInterval) {
        super.init(eventType: nil,
                   duration: duration,
                   specificTime: nil)
    }
    
}

extension HapticEvent: Equatable {
    public static func == (lhs: HapticEvent, rhs: HapticEvent) -> Bool {
        return lhs.eventType == rhs.eventType
        && lhs.duration == rhs.duration
        && lhs.specificTime == rhs.specificTime
    }
}
