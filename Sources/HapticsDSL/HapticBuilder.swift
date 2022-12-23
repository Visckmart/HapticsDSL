//
//  File.swift
//  
//
//  Created by Victor Martins on 23/12/22.
//

import Foundation

@resultBuilder
public enum HapticBuilder {
    
    public static func buildBlock(_ components: HapticEventConvertible...) -> [HapticEvent] {
        components.flatMap { $0.asHapticEvents() }
    }
    
    
    public static func buildEither(first component: [HapticEventConvertible]) -> [HapticEvent] {
        component.flatMap { $0.asHapticEvents() }
    }
    public static func buildEither(second component: [HapticEventConvertible]) -> [HapticEvent] {
        component.flatMap { $0.asHapticEvents() }
    }
    
    public static func buildOptional(_ component: [HapticEventConvertible]?) -> [HapticEvent] {
        component?.flatMap { $0.asHapticEvents() } ?? []
    }
    
    public static func buildArray(_ components: [[HapticEvent]]) -> [HapticEvent] {
        components.flatMap { $0 }
    }
    
    public static func buildFinalResult(_ component: [HapticEvent]) -> [HapticEvent] {
        component
    }
}

public protocol HapticEventConvertible {
    func asHapticEvents() -> [HapticEvent]
}

extension HapticEvent: HapticEventConvertible {
    public func asHapticEvents() -> [HapticEvent] {
        [self]
    }
}

extension Array<HapticEvent>: HapticEventConvertible {
    public func asHapticEvents() -> [HapticEvent] {
        self
    }
}
