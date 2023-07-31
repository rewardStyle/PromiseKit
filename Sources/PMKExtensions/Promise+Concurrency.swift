//
//  Promise+Concurrency.swift
//  PMKExtensions
//
//  Created by Bri on 7/30/23.
//

import PromiseKit

@available(iOS 13.0, *)
extension Promise {
    /// Execute this promise using Swift Concurrency. Any caught errors will be thrown.
    /// - Parameters:
    ///   - dispatchQueue: The `DispatchQueue` that the `Promise` will be returned or caught on. PromiseKit defaults to returning/catching this `Promise` on the main thread.
    ///   - flags: The work item flags for the dispatch queue
    ///   - catchPolicy: Used to skip cancellation errors, or catch all errors (in the `Promise`).
    /// - Returns: `T`, the specified type.
    func asTask(
        on dispatchQueue: DispatchQueue? = nil,
        flags: DispatchWorkItemFlags? = nil,
        catchPolicy: CatchPolicy = .allErrorsExceptCancellation
    ) async throws -> T {
        try await asTask(returnOn: dispatchQueue, catchOn: dispatchQueue, flags: flags, catchPolicy: catchPolicy)
    }

    /// Execute this `Promise` using Swift Concurrency. Any caught errors will be thrown.
    /// - Parameters:
    ///   - returnQueue: The `DispatchQueue` that the `Promise`'s value will be returned on. PromiseKit defaults to returning/catching this `Promise` on the main thread. ```
    ///   - catchQueue: The `DispatchQueue` that the `Promise` will be caught on and the error will be handled. PromiseKit defaults to returning/catching this `Promise` on the main thread.
    ///   - flags: The work item flags for the returning/catching `DispatchQueue`
    ///   - catchPolicy: Used to skip cancellation errors, or catch all errors (in the `Promise`). (Defaults to `CatchPolicy.allErrorsExceptCancellation`)
    /// - Returns: `T`, the type specified in this `Promise`.
    func asTask(
        returnOn returnQueue: DispatchQueue?,
        catchOn catchQueue: DispatchQueue?,
        flags: DispatchWorkItemFlags? = nil,
        catchPolicy: CatchPolicy = .allErrorsExceptCancellation
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            firstly { self }
                .done(on: returnQueue, flags: flags) {
                    continuation.resume(returning: $0)
                }
                .catch(on: catchQueue, flags: flags, policy: catchPolicy) {
                    continuation.resume(throwing: $0)
                }
        }
    }
}
