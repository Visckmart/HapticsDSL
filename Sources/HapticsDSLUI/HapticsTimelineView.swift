//
//  HapticsTimelineView.swift
//  HapticsDSL
//
//  Created by Victor Martins on 12/10/22.
//

import SwiftUI
import HapticsDSL

public struct HapticsTimelineView: View {
    
    let hapticEvents: [CompleteHapticEvent]
    let timelineEnd: TimeInterval
    let idealWidth: CGFloat?
    let height: CGFloat
    
    @Binding var currentTime: Date
    
    public init(hapticEvents: [CompleteHapticEvent],
                  timelineEnd: TimeInterval,
                  currentTime: Binding<Date>,
                  oneSecondWidth width: CGFloat? = nil,
                  height: CGFloat = 50) {
        self.hapticEvents = hapticEvents
        self.timelineEnd = timelineEnd
        self._currentTime = currentTime
        self.idealWidth = width
        self.height = height
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width: CGFloat = idealWidth ?? (geo.size.width / timelineEnd)
            TimelineView(.animation) { t in
                ScrollView(self.idealWidth == nil ? [] : .horizontal, showsIndicators: true) {
                    ZStack(alignment: .leading) {
                        ForEach(hapticEvents, id: \.relativeTime) { event in
                            HapticEventView(event: event)
                                .frame(width: event.duration * width)
                                .offset(x: event.relativeTime * width)
                        }
                        if let startDate = self.currentTime, startDate != .distantPast {
                            let offs = t.date.timeIntervalSince(startDate)
                            if offs <= timelineEnd {
                                Rectangle()
                                    .fill(.red)
                                    .frame(width: 3)
                                    .offset(x: offs * width)
                                //                                .opacity(showingMarker ? 1 : 0)
                            }
                        }
                    }
                    .frame(width: timelineEnd * width, height: height, alignment: .leading)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: height + 8)
    }
}

fileprivate struct HapticEventView: View {
    let event: CompleteHapticEvent
    var body: some View {
        if let eventType = event.eventType {
            RoundedRectangle(cornerRadius: 5)
                .fill({ () -> Color in
                    switch eventType {
                    case .hapticTransient: return .green
                    case .hapticContinuous: return .blue
                    default: return .black
                    }
                }())
            //                                    .frame(height: height)
        } else {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(white: 0.75))
                .frame(height: 15)
        }
    }
}
//struct HapticsTimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//        HapticsTimelineView()
//    }
//}
