//
//  LanguageBase.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/7.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class LanguageBase: NSObject {

    public var subject : BehaviorSubject<Int> = BehaviorSubject.init(value: 0)
    
    var items : [(Any,Selector)] = []
    
    //MARK: Single Example
    public static var sharedInstance : LanguageBase {
        struct Static {
            static let instance : LanguageBase = LanguageBase()
        }
        return Static.instance
    }
    
    //Todo: There's a problem here,
    //Subscription will change the language's hot signal
    class func getSubjectAsobsever() -> BehaviorSubject<Int>{
        return LanguageBase.sharedInstance.subject.asObserver()
    }
    
}

