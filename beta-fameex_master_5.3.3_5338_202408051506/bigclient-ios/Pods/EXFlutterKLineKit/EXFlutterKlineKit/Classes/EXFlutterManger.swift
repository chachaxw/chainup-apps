//
//  EXCommonAlert.swift
//  EXKit
//
//  Created by cwd on 2022/7/7.
//

import UIKit
import Flutter
import FlutterPluginRegistrant

public class EXFlutterEngine{
    static let engineName = "contract flutter engine"
    public var hasInited = false
    static var _sharedInstance: EXFlutterEngine?
    open class var shared: EXFlutterEngine{
        guard let ins = _sharedInstance else{
            _sharedInstance = EXFlutterEngine()
            return _sharedInstance!
        }
        return ins
    }
   
    private init(){}
    
    public var invokeChannel: FlutterMethodChannel?
    public var callbackChannel: FlutterMethodChannel?
    public var flutterController: FlutterViewController?
    public var flutterEngine: FlutterEngine?
    public func startEngine(initialRoute: String){
//        if hasInited {
//            return
//        }
        createFlutterEngine(name: EXFlutterEngine.engineName, initialRoute: initialRoute)
//        hasInited = true
    }
    
    public func destroyInstance(){
        
    }
    private func createFlutterEngine(name: String,initialRoute: String){
        let flutterEngine = FlutterEngine(name: name)
        flutterEngine.run(withEntrypoint: nil, initialRoute: initialRoute)
        GeneratedPluginRegistrant.register(with: flutterEngine)
        self.flutterEngine = flutterEngine
        let _flutterController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        self.callbackChannel   = EXFlutterKineChannel.createCallbackChannel(messenger: _flutterController.binaryMessenger)
        self.invokeChannel     = EXFlutterKineChannel.createInvokeChannel(messenger: _flutterController.binaryMessenger)
        self.flutterController = _flutterController
    }
    //给fluter 发消息
    public func invokeMethod(method: EXInvokeFlutterMethod,arguments: String){
        self.invokeChannel?.invokeMethod(method.rawValue, arguments: arguments)
    }
}

//用于存储指标信息
public class EXFlutterKlineCache{
    static var _sharedInstance: EXFlutterKlineCache?
    open class var shared: EXFlutterKlineCache{
        guard let ins = _sharedInstance else{
            _sharedInstance = EXFlutterKlineCache()
            return _sharedInstance!
        }
        return ins
    }
    private init(){}
    public var flutterEnginCaches = [String: FlutterEngine]()
    public var klineUsePreference = [String: Any]() //Store some configuration information of the large K line, such as ma ema
    public var scaceKeyPreference = [String: String]()
}

