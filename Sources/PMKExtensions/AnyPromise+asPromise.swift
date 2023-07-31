//
//  AnyPromise+asPromise.swift
//  PMKExtensions
//
//  Created by Bri on 7/30/23.
//

import PromiseKit

extension AnyPromise {
    func asPromise<T>() -> Promise<T> {
        asPromise(type: T.self)
    }

    func asPromise<T>() -> Promise<T?> {
        asPromise(type: T.self)
    }

    func asPromise<T>(type: T.Type) -> Promise<T?> {
        Promise<T?>.init { resolver in
            self.done({ value in
                resolver.fulfill(value as? T)
            }).catch { error in
                resolver.reject(error)
            }
        }
    }

    public func asPromise<T>(type: T.Type) -> Promise<T> {
        Promise<T>.init { resolver in
            self.done({ value in
                if let value = value as? T {
                    return resolver.fulfill(value)
                }

                throw RSPMKError.failedCastAsPromise(promise: value, to: T.self)
            }).catch { error in
                resolver.reject(error)
            }
        }
    }
}
