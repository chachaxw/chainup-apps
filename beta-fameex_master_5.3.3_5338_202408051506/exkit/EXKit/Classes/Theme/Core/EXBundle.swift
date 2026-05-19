//
//  EXBundle.swift
//  EXUIKit
//
//  Created by zq on 2023/1/21.
//

import Foundation

@objcMembers open class EXBundle: NSObject {
    
    @available(*, unavailable) override init() {}
    
    open class var name: String { "\(self)" }
    public class var resource: Bundle? {
        guard let path = Bundle(for: self).path(forResource: name, ofType: "bundle") else { return nil }
        return Bundle(path: path)
    }
    
    public class func path(forResource name: String?, ofType ext: String?, inDirectory subpath: String? = nil) -> String? {
        return resource?.path(forResource: name, ofType: ext, inDirectory: subpath)
    }
    
    public class func url(forResource name: String?, withExtension ext: String?, subdirectory subpath: String? = nil) -> URL? {
        return resource?.url(forResource: name, withExtension: ext, subdirectory: subpath)
    }
    
}
