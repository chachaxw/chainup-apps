//
//  EXThemeData.swift
//  Pods
//
//  Created by zq on 2023/3/20.
//

import Foundation

public extension Data {
    struct Ex {
        @available(*, unavailable) init() {}
        ///
        private static func named(_ name: String, color:UIColor.Ex.Color, bundle:Bundle?) -> Data? {
            //
            if name.isEmpty { return nil }
            //
            let dataName = name + color.resourceSuffix
            //
            guard let bundle = bundle, bundle != .main else {
                return NSDataAsset(name: dataName)?.data ?? NSDataAsset(name: name)?.data
            }
            //
            var data:Data? = NSDataAsset(name: dataName, bundle: bundle)?.data
            if data == nil { data = NSDataAsset(name: name, bundle: bundle)?.data }
            return data
        }
        
        public static func named(_ name: String?, color:UIColor.Ex.Color = .global, in bundle:EXBundle.Type? = nil) -> Data? {
            guard let name = name, !name.isEmpty else { return nil }
            return named(name, color: color, bundle: bundle?.resource)
        }
    }
}


extension EXBundle {
    public class func data(named name:String, color:UIColor.Ex.Color = .global) -> Data? {
        return Data.Ex.named(name, color: color.resolved, in: self)
    }
}
