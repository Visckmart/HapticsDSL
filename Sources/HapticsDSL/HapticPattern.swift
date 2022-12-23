//
//  HapticPattern.swift
//  HapticsDSL
//
//  Created by Victor Martins on 22/12/22.
//

import CoreHaptics

public final class HapticPattern {
    let delayBetweenEvents: TimeInterval
    let startDelay: TimeInterval
    let hapticEvents: [HapticEvent]
    
    public init(delayBetweenEvents: TimeInterval = 0.1,
                startingAt startDelay: TimeInterval = 0,
                @HapticBuilder _ builder: () -> [HapticEvent]) {
        self.delayBetweenEvents = delayBetweenEvents
        self.startDelay = startDelay
        self.hapticEvents = builder()
    }
    
    public func generateHapticEventsTimeline(startingAt startOffset: TimeInterval = 0) -> (events: [CompleteHapticEvent], endsAt: TimeInterval) {
        var finalHapticEvents = [CompleteHapticEvent]()
        // Esperar o delay inicial dessa pattern
        var currentTime = startOffset + self.startDelay
        // Preparar o cálculo do final do último evento
        var lastEventEnd: TimeInterval = 0
        
        for hapticEvent in self.hapticEvents {
            // Calcular o tempo relativo
            let relativeTime: TimeInterval
            if let specificTime = hapticEvent.specificTime {
                relativeTime = startOffset + self.startDelay + specificTime
            } else {
                relativeTime = currentTime
            }
            
            let completeHapticEvent = CompleteHapticEvent(eventType: hapticEvent.eventType,
                                                          duration: hapticEvent.duration,
                                                          relativeTime: relativeTime)
            // Atualizar o final do último evento
            lastEventEnd = max(lastEventEnd, completeHapticEvent.endTime)
            // Adicionar o CHHapticEvent na lista de eventos
            finalHapticEvents.append(completeHapticEvent)
            
            // Se o evento não for posicionado em um tempo específico,
            // significa que ele precisa avançar o marcador auxiliar
            if hapticEvent.specificTime == nil {
                // Avançar o marcador de tempo auxiliar
                currentTime += hapticEvent.duration + self.delayBetweenEvents
            }
        }
        return (finalHapticEvents, lastEventEnd)
    }
}


public class CompleteHapticEvent {
    
    open var eventType: CHHapticEvent.EventType?
    open var duration: TimeInterval
    open var relativeTime: TimeInterval
    open var endTime: TimeInterval {
        relativeTime + duration
    }
    
    public init(eventType: CHHapticEvent.EventType?,
                duration: TimeInterval,
                relativeTime: TimeInterval) {
        self.eventType = eventType
        self.duration = duration
        self.relativeTime = relativeTime
    }
    
    public func generateRealHapticEvent() -> CHHapticEvent? {
        guard let eventType = self.eventType else { return nil }
        return CHHapticEvent(eventType: eventType,
                             parameters: [],
                             relativeTime: relativeTime,
                             duration: duration)
    }
}

extension CompleteHapticEvent: Equatable {
    public static func == (lhs: CompleteHapticEvent, rhs: CompleteHapticEvent) -> Bool {
        return lhs.eventType == rhs.eventType
        && lhs.duration.distance(to: rhs.duration) <= 0.0001
        && lhs.relativeTime.distance(to: rhs.relativeTime) <= 0.0001
        && lhs.endTime.distance(to: rhs.endTime) <= 0.0001
    }
}

extension CompleteHapticEvent: CustomStringConvertible {
    public var description: String {
        let formattedEventType = self.eventType?.description ?? "delay"
        let formattedRelativeTime = String(format: "%.3f", self.relativeTime)
        let formattedEndTime = String(format: "%.3f", self.endTime)
        let formattedDuration = String(format: "%.3f", self.duration)
        return "\(formattedEventType) (\(formattedRelativeTime) -(\(formattedDuration))-> \(formattedEndTime))"
    }
}

extension CHHapticEvent.EventType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .hapticTransient:  return "hapticTransient"
        case .hapticContinuous: return "hapticContinuous"
        case .audioContinuous:  return "audioContinuous"
        case .audioCustom:      return "audioCustom"
        default:                return String(describing: self)
        }
    }
}
