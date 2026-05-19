//
//  EXLogger.swift
//  EXKit
//
//  Created by zq on 2023/7/4.
//  Copyright © 2023 EXKit. All rights reserved.
//

import Foundation
import os

@available(iOS 12.0, *)
public class EXLogger {
    ///
    public enum Level: String {
        case `default`
        case info
        case debug
        case error
        case fault
    }
    ///
    public struct Scene: Hashable, RawRepresentable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
        public typealias RawValue = String
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        ///
        public typealias StringLiteralType = String
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
        ///
        public static let `default`: Self = "default"
        public static let network  : Self = "network"
        public static let websocket: Self = "websocket"
        ///
        public var description: String { rawValue }
    }
    ///
    public static var isEnabled: Bool = isDebugMode
    ///
    public static var level: Level = .default
    ///
    public static var scene: Scene = .default
    ///
    public static var outputLevelScene: Bool = false
    ///
    public static var outputLocation: Bool = false
    ///
    public static var outputFunction: Bool = false
    ///
    public static var outputCallStack: Bool = false
}

extension EXLogger {
    ///
    public class func log(level: Level = .default,
                          scene: Scene = scene,
                          file: String = #fileID,
                          line: UInt = #line,
                          function: String = #function,
                          callStack: Bool? = nil,
                          message: String) {
        guard isEnabled, Self.level <= level else { return }
        var logs:[String] = []
        if outputLevelScene {
            if oslogDisabled { logs.append("[\(scene.rawValue)]") }
            logs.append("[\(level.rawValue)]")
        }
        if outputLocation { logs.append("\(((file as NSString).lastPathComponent as NSString).deletingPathExtension):\(line)") }
        if outputFunction { logs.append(function) }
        if !logs.isEmpty { logs.append("=>") }
        logs.append(message)
        var log = logs.joined(separator: " ")
        if isDebugMode, callStack ?? Self.outputCallStack {
        #if DEBUG
            let stack = EXBacktrace.parser(Thread.callStackSymbols.dropFirst(2).map({$0}))
            if !stack.isEmpty { log += "\n\(stack.joined(separator: "\n"))" }
        #endif
        }
        if oslogDisabled {
            print("\(now())  \(log)")
        }else{
            if #available(iOS 14.0, *) {
                logger(of: scene).log(level: level.osLogLevel, "\(log)")
            } else {
                os_log(level.osLogLevel, log: osLogger(of: scene), "%@", log)
            }
        }
    }
    ///
    public class func info(scene: Scene = scene,
                           file: String = #fileID,
                           line: UInt = #line,
                           function: String = #function,
                           callStack: Bool? = nil,
                           message: String) {
        log(level:.info, scene:scene, file:file, line:line, function:function, callStack:callStack, message:message)
    }
    ///
    public class func debug(scene: Scene = scene,
                            file: String = #fileID,
                            line: UInt = #line,
                            function: String = #function,
                            callStack: Bool? = nil,
                            message: String) {
        log(level:.debug, scene:scene, file:file, line:line, function:function, callStack:callStack, message:message)
    }
    ///
    public class func error(scene: Scene = scene,
                            file: String = #fileID,
                            line: UInt = #line,
                            function: String = #function,
                            callStack: Bool? = nil,
                            message: String) {
        log(level:.error, scene:scene, file:file, line:line, function:function, callStack:callStack, message:message)
    }
    ///
    public class func fault(scene: Scene = scene,
                            file: String = #fileID,
                            line: UInt = #line,
                            function: String = #function,
                            callStack: Bool? = nil,
                            message: String) {
        log(level:.fault, scene:scene, file:file, line:line, function:function, callStack:callStack, message:message)
    }
}




extension EXLogger {
    ///
    private static let oslogDisabled: Bool = {
        let env = ProcessInfo.processInfo.environment["OS_ACTIVITY_MODE"]
        if env?.lowercased() == "disable" {
            print("")
            print("********************************************************")
            print("***********   OSLog is disabled by the env   ***********")
            print("***********   OS_ACTIVITY_MODE => \(env!)    ***********")
            print("***********   `print` will be used instead   ***********")
            print("********************************************************")
            print("")
            return true
        }
        return false
    }()
    ///
    private static let isDebugMode: Bool = {
        #if DEBUG
            true
        #else
            false
        #endif
    }()
    ///
    private static let bundleIdentifier = (Bundle.main.bundleIdentifier ?? Bundle(for: EXLogger.self).bundleIdentifier) ?? "com.exkit.logger"
    ///
    @available(iOS 14.0, *) private static var loggers: [Scene: Logger] = [:]
    @available(iOS 14.0, *) private static func logger(of scene: Scene) -> Logger {
        if let logger = loggers[scene] { return logger }
        objc_sync_enter(loggers)
        defer { objc_sync_exit(loggers) }
        if let logger = loggers[scene] { return logger }
        let logger = Logger(osLogger(of: scene))
        loggers[scene] = logger
        return logger
    }
    ///
    private static var osLoggers: [Scene: OSLog] = [:]
    private static func osLogger(of scene: Scene) -> OSLog {
        if let osLogger = osLoggers[scene] { return osLogger }
        objc_sync_enter(osLoggers)
        defer { objc_sync_exit(osLoggers) }
        if let osLogger = osLoggers[scene] { return osLogger }
        let osLogger = OSLog(subsystem: bundleIdentifier, category: scene.rawValue)
        osLoggers[scene] = osLogger
        return osLogger
    }
    ///
    private static let dateFormatterFraction = ".#"
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss\(dateFormatterFraction)Z"
        return dateFormatter
    }()
    ///
    private static func now() -> String {
        ///
        let now = Date()
        var string = dateFormatter.string(from: now)
        let fraction = String(now.timeIntervalSince1970).components(separatedBy: ".").last
        string = string.replacingOccurrences(of: dateFormatterFraction, with: fraction != nil ? ".\(fraction!)" : "")
        return string
    }
}

extension EXLogger.Level: Comparable {
    public static func < (lhs: EXLogger.Level, rhs: EXLogger.Level) -> Bool {
        return lhs.value < rhs.value
    }
    ///
    fileprivate var osLogLevel: OSLogType {
        switch self {
            case .default: return .default
            case .info:    return .info
            case .debug:   return .debug
            case .error:   return .error
            case .fault:   return .fault
        }
    }
    private var value: Int {
        switch self {
            case .default: return 0
            case .debug:   return 1
            case .info:    return 2
            case .error:   return 3
            case .fault:   return 4
        }
    }
}
