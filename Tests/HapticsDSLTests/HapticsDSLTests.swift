import XCTest
@testable import HapticsDSL

final class HapticsDSLTests: XCTestCase {
    
    static let defaultDelayBetweenEvents: TimeInterval = 0.1
    static let defaultStartingAt: TimeInterval = 0
    
    func testTransientEvent_UniqueStatic() throws {
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
            TransientEvent()
        }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: .hapticTransient,
                                duration: 0.1,
                                relativeTime: Self.defaultStartingAt)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testContinuousEvent_UniqueStatic() throws {
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
            ContinuousEvent(duration: 1)
        }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: .hapticContinuous,
                                duration: 1,
                                relativeTime: Self.defaultStartingAt)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testDelay_UniqueStatic() throws {
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
                HapticDelay(duration: 1)
            }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: nil,
                                duration: 1,
                                relativeTime: Self.defaultStartingAt)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testContinuousEvent_UniqueRandom() throws {
        let duration = TimeInterval.random(in: 0.1...100)
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
            ContinuousEvent(duration: duration)
        }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: .hapticContinuous,
                                duration: duration,
                                relativeTime: Self.defaultStartingAt)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents,
                       "The duration of the continuous haptic event was not handled correctly")
    }
    
    func testMultipleEvents_UniqueRandom() throws {
        let delayDuration = TimeInterval.random(in: 0.1...100)
        let continuousEventDuration = TimeInterval.random(in: 0.1...100)
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
                TransientEvent()
                HapticDelay(duration: delayDuration)
                ContinuousEvent(duration: continuousEventDuration)
            }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: .hapticTransient,
                                duration: 0.1,
                                relativeTime: Self.defaultStartingAt),
            CompleteHapticEvent(eventType: nil,
                                duration: delayDuration,
                                relativeTime: Self.defaultStartingAt + Self.defaultDelayBetweenEvents + 0.1),
            CompleteHapticEvent(eventType: .hapticContinuous,
                                duration: continuousEventDuration,
                                relativeTime: Self.defaultStartingAt + Self.defaultDelayBetweenEvents + 0.1 + Self.defaultDelayBetweenEvents + delayDuration)
        ]
        
        print(generatedEvents.map(\.description))
        print(expectedEvents.map(\.description))
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testContinuousEvent_MultipleRandom() throws {
        for _ in 0...100 {
            let duration = TimeInterval.random(in: 0.1...100)
            let pattern = HapticPattern(
                delayBetweenEvents: Self.defaultDelayBetweenEvents,
                startingAt: Self.defaultStartingAt) {
                ContinuousEvent(duration: duration)
            }
            let generatedEvents = pattern.generateHapticEventsTimeline().events
            
            let expectedEvents = [
                CompleteHapticEvent(eventType: .hapticContinuous,
                                    duration: duration,
                                    relativeTime: Self.defaultStartingAt)
            ]
            
            XCTAssertEqual(generatedEvents, expectedEvents,
                           "The duration of the continuous haptic event was not handled correctly")
        }
    }
    
    func testDelayTransientEvent_UniqueStatic() throws {
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
            HapticDelay(duration: 1)
            TransientEvent()
        }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: nil,
                                duration: 1,
                                relativeTime: Self.defaultStartingAt),
            CompleteHapticEvent(eventType: .hapticTransient,
                                duration: 0.1,
                                relativeTime: 1.0 + Self.defaultDelayBetweenEvents)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testDelayContinuousEvent_UniqueStatic() throws {
        let pattern = HapticPattern(
            delayBetweenEvents: Self.defaultDelayBetweenEvents,
            startingAt: Self.defaultStartingAt) {
                HapticDelay(duration: 1)
                ContinuousEvent(duration: 1)
            }
        let generatedEvents = pattern.generateHapticEventsTimeline().events
        
        let expectedEvents = [
            CompleteHapticEvent(eventType: nil,
                                duration: 1,
                                relativeTime: Self.defaultStartingAt),
            CompleteHapticEvent(eventType: .hapticContinuous,
                                duration: 1,
                                relativeTime: 1.0 + Self.defaultDelayBetweenEvents)
        ]
        
        XCTAssertEqual(generatedEvents, expectedEvents)
    }
    
    func testEventEquality() {
        for _ in 0...100 {
            var newEvent: HapticEvent
            let random = Int.random(in: 0...2)
            switch random {
            case 0:
                let randomStartingTime = Bool.random() ? nil : TimeInterval.random(in: 0.1...100)
                newEvent = TransientEvent(startingExactlyAt: randomStartingTime)
            case 1:
                let randomDuration = TimeInterval.random(in: 0.1...100)
                let randomStartingTime = Bool.random() ? nil : TimeInterval.random(in: 0.1...100)
                newEvent = ContinuousEvent(duration: randomDuration,
                                           startingExactlyAt: randomStartingTime)
            default:
                let randomDuration = TimeInterval.random(in: 0.1...100)
                newEvent = HapticDelay(duration: randomDuration)
            }
            let differentEvent = HapticEvent(eventType: newEvent.eventType,
                                             duration: newEvent.duration,
                                             specificTime: newEvent.specificTime)
            differentEvent.duration += Double.random(in: 0.1...10)
            differentEvent.specificTime? += Double.random(in: 0.1...10)
            XCTAssertEqual(newEvent, newEvent)
            XCTAssertNotEqual(newEvent, differentEvent)
        }
    }
}
