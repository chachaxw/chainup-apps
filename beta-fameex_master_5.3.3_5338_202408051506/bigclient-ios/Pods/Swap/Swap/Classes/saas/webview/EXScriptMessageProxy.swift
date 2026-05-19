////
////  EXScriptMessageProxy.swift
////  Chainup
////
////  Created by liuxuan on 2023/8/15.
////  Copyright © 2023 zewu wang. All rights reserved.
////
//
//import UIKit
//import WebKit
//
//
//class EXScriptMessageProxy: NSObject, WKScriptMessageHandler {
//    
//    weak var delegate: WKScriptMessageHandler?
//    
//    init(delegate: WKScriptMessageHandler) {
//        self.delegate = delegate
//        super.init()
//    }
//    
//    func userContentController(_ userContentController: WKUserContentController,
//                               didReceive message: WKScriptMessage) {
//        self.delegate?.userContentController(
//            userContentController, didReceive: message)
//    }
//}
