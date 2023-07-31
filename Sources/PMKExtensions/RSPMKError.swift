//
//  RSPMKError.swift
//  PMKExtensions
//
//  Created by Brandon Meyer on 8/7/19.
//  Copyright © 2019 rewardStyle. All rights reserved.
//

import PromiseKit

public enum RSPMKError<T>: Error, LocalizedError {
    case failedCast(to: T.Type)
    case failedCastAsPromise(promise: AnyPromise.T, to: T.Type)

    public var debugDescription: String {
        switch self {
        case .failedCast(let type):
            return "Failed to cast as \(type)"

        case .failedCastAsPromise(let promise, let to):
            return "Failed to cast object \(String(describing: promise)) to \(to)"
        }
    }

    public var localizedDescription: String {
        debugDescription
    }
}
