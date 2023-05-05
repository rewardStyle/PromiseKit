//
//  PMKAnimationOptions.swift
//  
//
//  Created by Nick Le on 1.2.2023.
//

import Foundation

public struct PMKAnimationOptions : OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = Self(rawValue: 1 << 0)
    public static let appear = Self(rawValue: 1 << 1)
    public static let disappear = Self(rawValue: 1 << 2)
}
