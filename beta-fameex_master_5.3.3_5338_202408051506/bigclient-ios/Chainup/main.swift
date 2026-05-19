//
//  main.swift
//  Chainup
//
//  Created by cwd on 2023/12/2.
//  Copyright © 2023 Chainup. All rights reserved.
//
import Foundation
import UIKit
import EXKit

EXKit.EXSwift.load()
LanguageTools.shareInstance.isPrivate = true
UIApplicationMain(Swift.CommandLine.argc, Swift.CommandLine.unsafeArgv, NSStringFromClass(UIApplication.self), NSStringFromClass(AppDelegate.self))
