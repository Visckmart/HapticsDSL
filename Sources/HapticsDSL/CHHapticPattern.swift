//
//  CHHapticPattern.swift
//  HapticsDSL
//
//  Created by Victor Martins on 22/12/22.
//

import CoreHaptics

extension CHHapticPattern {
    public convenience init(delayBetweenPatterns: TimeInterval = 0.1,
                            startingAt start: TimeInterval = 0,
                            fromPatternSequence patterns: [HapticPattern]) throws {
        // Array que armazena os eventos de haptics processados
        var finalHapticEvents = [CHHapticEvent]()
        
        // Marcador de tempo atual
        var currentTime: TimeInterval = start
        
        // Para cada HapticEvent
        for pattern in patterns {
            let (completeEvents, lastEventEnd) = pattern.generateHapticEventsTimeline(startingAt: currentTime)
            for completeEvent in completeEvents {
                if let realHapticEvent = CHHapticEvent(completeEvent) {
                    finalHapticEvents.append(realHapticEvent)
                }
            }
            currentTime = lastEventEnd + delayBetweenPatterns
        }
        
        try self.init(events: finalHapticEvents, parameters: [])
    }
}
