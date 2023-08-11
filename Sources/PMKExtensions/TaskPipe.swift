//
//  TaskPipe.swift
//  Extensions
//
//  Created by Bri on 5/12/23.
//

import Foundation
import PromiseKit

@available(iOS 13.0, *)
/// Use `firstly {}` or `.then { _ in }` to create an instance of a `TaskPipe` to inject an `async` task into the beginning or middle of an existing `Promise` chain.
///
/// This is useful when you have legacy business logic leveraging promises, but you have a newer service that leverages `async` methods to load a remote resource, or maybe an `actor` that has an isolated scope. This way you can still access these objects and services with `async` interfaces, right inside your current feature's promise chain code.
public final class TaskPipe<T>: Thenable, CatchMixin {
    /// The resolved result or nil if pending.
    /// - Note: `Thenable` conformance
    public var result: Result<T>?

    /// The internal `async` block that will determine how to resolve the promise chain.
    var operation: () async throws -> T

    /// DispatchQueue that the result returns on
    var queue: DispatchQueue

    /// Create a new `TaskPipe` with an `async` block.
    /// - Parameter task: The `async` block that will determine how to resolve the promise chain.
    public init(on queue: DispatchQueue = .main, operation: @escaping () async throws -> T) {
        self.queue = queue
        self.operation = operation
    }

    /// `pipe` is immediately executed when this `Thenable` is resolved
    /// - Note: `Thenable` conformance
    public func pipe(to: @escaping (Result<T>) -> Void) {
        Task {
            do {
                let response = try await operation()
                queue.async {
                    to(.fulfilled(response))
                }
            } catch {
                queue.async {
                    to(.rejected(error))
                }
            }
        }
    }
}

/// Judicious use of `firstly` *may* make chains more readable.
///
/// Compare:
/// ```swift
/// URLSession.shared.dataTask(url: url1).then {
///     URLSession.shared.dataTask(url: url2)
/// }.then {
///     URLSession.shared.dataTask(url: url3)
/// }
/// ```
///
/// With:
///
/// ```swift
/// firstly {
///     URLSession.shared.dataTask(url: url1)
/// }.then {
///     URLSession.shared.dataTask(url: url2)
/// }.then {
///     URLSession.shared.dataTask(url: url3)
/// }
/// ```
///
/// - Note: the block you pass executes immediately on the current thread/queue.
/// - Parameter task: The `async` `Task` to be executed. When this `Task` resolves the promise will also resolve with the same value and type.
/// - Returns: A `TaskPipe` instance, which is `Thenable`.
@available(iOS 13.0, *)
public func firstly<T>(on queue: DispatchQueue = .main, operation: @escaping () async throws -> T) -> TaskPipe<T> {
    TaskPipe(on: queue, operation: operation)
}

@available(iOS 13.0, *)
public extension Thenable {
    /// The provided closure executes when this promise is fulfilled.
    ///
    /// This allows chaining promises. The promise returned by the provided closure is resolved before the promise returned by this closure resolves.
    ///
    /// - Parameter on: The queue to which the provided closure dispatches.
    /// - Parameter body: The closure that executes when this promise is fulfilled. It must return a promise.
    /// - Returns: A new promise that resolves when the promise returned from the provided closure resolves.
    ///
    /// For example:
    /// ```
    ///   firstly {
    ///       URLSession.shared.dataTask(.promise, with: url1)
    ///   }.thenAsync { response in
    ///       transform(data: response.data)
    ///   }.done { transformation in
    ///       //…
    ///   }
    /// ```
    func then<U>(
        on queue: DispatchQueue = .main,
        priority: TaskPriority? = nil,
        operation: @escaping (T) async throws -> U
    ) -> Promise<U> {
        Promise { resolver in
            pipe { result in
                switch result {
                case .fulfilled(let value):
                    Task(
                        priority: priority,
                        operation: {
                            do {
                                let result = try await operation(value)
                                queue.async {
                                    resolver.fulfill(result)
                                }
                            } catch {
                                queue.async {
                                    resolver.reject(error)
                                }
                            }
                        }
                    )
                case .rejected(let error):
                    queue.async {
                        resolver.reject(error)
                    }
                @unknown default:
                    break
                }
            }
        }
    }
}
