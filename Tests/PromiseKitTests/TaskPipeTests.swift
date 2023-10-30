//
//  TaskPipeTests.swift
//  
//
//  Created by Bri on 7/30/23.
//

import XCTest
import PromiseKit
@testable import PMKExtensions

@available(iOS 13.0, *)
final class TaskPipeTests: XCTestCase {

    let error = NSError(domain: "I am a teapot 🫖", code: 418)

    func failingTask() async throws -> String {
        throw error
    }

    func meow() async throws -> String {
        "Meow"
    }

    func meow() -> Promise<String> {
        Promise { resolver in
            resolver.fulfill("Meow")
        }
    }

    func addMeow(to meow: String) async throws -> String {
        let meow2 = try await self.meow()
        return [meow, meow2].joined(separator: " ")
    }

    func addMeow(to meow: String) -> Promise<String> {
        firstly {
            self.meow()
        }
        .then { meow2 in
            [meow, meow2].joined(separator: " ")
        }
    }

    func testFirstlyThen() {
        _ = firstly {
            try await self.meow()
        }
        .then { meow in
            try await self.addMeow(to: meow)
        }
        .done { meows in
            XCTAssertEqual(meows, "meow meow")
        }
    }

    func testInterspersedPromisesAndTasks() {
        _ = firstly {
            try await self.meow()
        }
        .then { meow in
            self.addMeow(to: meow)
        }
        .done { meows in
            XCTAssertEqual(meows, "meow meow")
        }
    }

    func testThrowingFirstly() {
        _ = firstly {
            try await self.failingTask()
        }
        .catch { error in
            XCTAssertEqual(error as NSError, self.error)
        }
    }

    func testThrowingFirstlyPassthroughThen() {
        _ = firstly {
            try await self.failingTask()
        }
        .then { meow in
            self.addMeow(to: meow)
        }
        .catch { error in
            XCTAssertEqual(error as NSError, self.error)
        }
    }

    func testThrowingThen() {
        _ = firstly {
            self.meow()
        }
        .then { meow in
            try await self.failingTask()
        }
        .catch { error in
            XCTAssertEqual(error as NSError, self.error)
        }
    }

    func testWhen() {
        let firstMeow = meow()
        let secondMeow = meow()
        let thirdMeow = meow()
        let fourthMeow = Promise(
            TaskPipe {
                try await self.meow()
            }
        )
        let fifthMeow = Promise(
            TaskPipe {
                try await self.meow()
            }
        )
        _ = when(resolved: [firstMeow, secondMeow, thirdMeow, fourthMeow, fifthMeow])
            .then { results in
                for result in results {
                    switch result {
                    case .fulfilled(let meow):
                        XCTAssertEqual(meow, "Meow")
                    case .rejected(let error):
                        XCTFail("Caught error: " + error.localizedDescription)
                    @unknown default:
                        break
                    }
                }
            }
    }
}
