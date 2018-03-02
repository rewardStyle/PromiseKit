//
//  AllTests.swift
//  PMKJSA+Tests
//
//  Created by Lois Di Qual on 2/28/18.
//

import XCTest
import PromiseKit
import JavaScriptCore

@available(iOS 10.0, *)
let resolved: @convention(block) (JSValue) -> JSPromise = { value in
    return JSPromise(promise: .value(value))
}

@available(iOS 10.0, *)
let rejected: @convention(block) (JSValue) -> JSPromise = { reason in
    let error = JSPromise.JSError(reason: reason)
    let promise = Promise<JSValue>(error: error)
    return JSPromise(promise: promise)
}

@available(iOS 10.0, *)
let deferred: @convention(block) () -> JSValue = {
    
    let context = JSContext.current()
    
    guard let object = JSValue(object: NSDictionary(), in: context) else {
        fatalError("Couldn't create object")
    }
    
    let pendingPromise = Promise<JSValue>.pending()
    let jsPromise = JSPromise(promise: pendingPromise.promise)
    
    // promise
    object.setObject(jsPromise, forKeyedSubscript: "promise" as NSString)
    
    // resolve
    let resolve: @convention(block) (JSValue) -> Void = { value in
        pendingPromise.resolver.fulfill(value)
    }
    object.setObject(resolve, forKeyedSubscript: "resolve" as NSString)
    
    // reject
    let reject: @convention(block) (JSValue) -> Void = { reason in
        let error = JSPromise.JSError(reason: reason)
        pendingPromise.resolver.reject(error)
    }
    object.setObject(reject, forKeyedSubscript: "reject" as NSString)
    
    return object
}

@available(iOS 10.0, *)
class AllTests: XCTestCase {
    
    func testAll() {
        
        let environment = MockNodeEnvironment()
        
        guard let context = JSContext() else {
            return XCTFail()
        }
        
        let bundle = Bundle(for: AllTests.self)
        guard let scriptPath = bundle.url(forResource: "build", withExtension: "js", subdirectory: "build") else {
            return XCTFail("Couldn't find test suite")
        }
        
        guard let script = try? String(contentsOf: scriptPath) else {
            return XCTFail("Couldn't read content of test suite JS file")
        }
        
        // Add a global exception handler
        context.exceptionHandler = { context, exception in
            guard let exception = exception else {
                return XCTFail("Unknown JS exception")
            }
            MockNodeEnvironment.printStackTrace(exception: exception, includeExceptionDescription: true)
        }
        
        // Setup mock functions (timers, console.log, etc)
        environment.setup(with: context)
        
        // Expose JSPromise and JSAdapter in the javascript context
        context.setObject(JSPromise.self, forKeyedSubscript: "JSPromise" as NSString)
        
        // Create adapter
        guard let adapter = JSValue(object: NSDictionary(), in: context) else {
            fatalError("Couldn't create adapter")
        }
        adapter.setObject(resolved, forKeyedSubscript: "resolved" as NSString)
        adapter.setObject(rejected, forKeyedSubscript: "rejected" as NSString)
        adapter.setObject(deferred, forKeyedSubscript: "deferred" as NSString)
        
        // Evaluate contents of `build.js`, which exposes `runTests` in the global context
        context.evaluateScript(script)
        guard let runTests = context.objectForKeyedSubscript("runTests") else {
            return XCTFail("Couldn't find `runTests` in JS context")
        }
        
        // Create a callback that's called whenever there's a failure
        let onFail: @convention(block) (JSValue, JSValue) -> Void = { test, error in
            XCTFail("\(test.toString()) failed: \(error.toString())")
        }
        let onFailValue = JSValue(object: onFail, in: context)
        
        // Create a new callback that we'll send to `runTest` so that it notifies when tests are done running.
        let expectation = self.expectation(description: "async")
        let onDone: @convention(block) (JSValue) -> Void = { failures in
            expectation.fulfill()
        }
        let onDoneValue = JSValue(object: onDone, in: context)
        
        // If there's a need to only run one specific test, provide its name here
        let testName = false ? JSValue(object: "2.3.1", in: context) : JSValue(undefinedIn: context)
        
        // Call `runTests`
        runTests.call(withArguments: [adapter, onFailValue, onDoneValue, testName])
        self.wait(for: [expectation], timeout: 1000)
    }
}
