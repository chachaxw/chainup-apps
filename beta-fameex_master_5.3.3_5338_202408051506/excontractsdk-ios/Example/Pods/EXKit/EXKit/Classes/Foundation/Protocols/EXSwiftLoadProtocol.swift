//
//  EXSwiftLoadProtocol.swift
//  EXKit
//
//  Created by zq on 2023/4/4.
//

import Foundation
import UIKit

/**
 You need update your main entry.
 
 1.add `main.swift`
 
 2.add the codes below to main.swift
 ```
 import EXKit
 
 EXSwift.load()
 
 UIApplicationMain(Swift.CommandLine.argc, Swift.CommandLine.unsafeArgv, NSStringFromClass(UIApplication.self), NSStringFromClass(AppDelegate.self))
 ```
 
 3.remove `@UIApplicationMain` , `@NSApplicationMain` , `@main`
 */
@objc public protocol EXSwiftLoadProtocol {
    @objc optional static func swiftLoad()
}

/// - `see`: EXSwiftLoadProtocol
public struct EXSwift {
    /// - `see`: EXSwiftLoadProtocol
    public static func load() {
        Self.swiftLoad
    }
    private static let swiftLoad: Void = {
        let count = objc_getClassList(nil, 0)
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(count))
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, count)
        for index in 0 ..< Int(count) {
            guard class_conformsToProtocol(types[index], EXSwiftLoadProtocol.self) else { continue }
            guard let cls = types[index] as? EXSwiftLoadProtocol.Type else { continue }
            cls.swiftLoad?()
        }
        types.deallocate()
    }()
}
