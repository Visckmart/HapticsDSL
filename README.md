# HapticsDSL

An easy-to-use domain-specific language to build haptic patterns from Core Haptics.

## Overview

The Core Haptics framework allows you to "Compose and play haptic patterns to customize your iOS app’s haptic feedback.". These patterns consist of sequences of haptic events. The HapticsDSL framework allows the easy of these patterns. For example:
```swift
let pattern = HapticPattern(delayBetweenEvents: 0.1) {
    TransientEvent()
    ContinuousEvent(duration: 1)
    TransientEvent()
}

// ...

let coreHapticsPattern = try CHHapticPattern(fromPatternSequence: [pattern])
// play the pattern...
```

This pattern is made of a very quick vibration, followed by one that lasts 1 second, followed by another very quick vibration.

There’s also a specified delay of 0.1 s between each vibration. 

To learn how to play a `CHHapticPattern` visit the [Core Haptics documentation](https://developer.apple.com/documentation/corehaptics).

## Essentials

The Haptic Events are defined by the `HapticEvent` class. They consist of an event type, which can be `nil` in case of a delay event; a duration and a specificTime to be played, which can be `nil` in case of an event that should be played after the previous one.

There are three main event types:
- Transient Event: This is a very short vibration, which takes 0.1 s and uses the `.hapticTransient` type.
- Continuous Event: This is a variable duration vibration, which uses the `.hapticContinuous` type.
- Delay Event: This is a way to specify that the next event should wait before it starts playing.

## Advanced Features

### Out of sequence events

Every event can be played at an specific time. To express this intention, the `startingExactlyAt` parameter should be used.
Important: the events that follow the declaration of an event that starts at a specific time do not play out after them. They are played after the last sequential event finishes.

```swift
HapticPattern(delayBetweenEvents: 0.1) {
    ContinuousEvent(duration: 1)
    TransientEvent(startingExactlyAt: 5)
    ContinuousEvent(duration: 1)
}
```

This pattern will play out as follows: a continuous event that will play immediately and last for 1 second, a delay of 0.1 s, a continuous event that will play from 1.1 s for 1 second, a delay until the 5 s mark and then a transient event.

If you want the last continuous event to play after the transient event, you should declare a new pattern and set it to start at the 5 second mark instead. This way you would make use of the default sequential behavior as usual. 

### Defining new event types

The three event types discussed previously are subclasses of the HapticEvent class. You can make your own subclass if you wish.

### Visualizing the pattern

This framework comes with a helper module called `HapticsDSLUI`. It consists of a SwiftUI View that is capable of showing a timeline of the pattern.

```swift
import SwiftUI

// ...

let (hapticEvents, lastEventTime) = pattern.generateHapticEventsTimeline(startingAt: 0)
HapticsTimelineView(hapticEvents: hapticEvents,
                    timelineEnd: lastEventTime,
                    currentTime: $currentTime)
```

### Control flow

The pattern DSL supports control flow statements, which enable you to write really expressive patterns. Below are some examples:

```swift
HapticPattern(delayBetweenEvents: 0.1) {
    TransientEvent()
    
    if condition {
        ContinuousEvent(duration: 1.5)
    } else {
        HapticDelay(duration: 1.5)
    }
    
    for i in 0...3 {
        TransientEvent()
        HapticDelay(duration: Double(i) * 0.1)
    }
    
    if anotherCondition {
        ContinuousEvent(duration: 2, startingExactlyAt: 5)
    }
}
```
