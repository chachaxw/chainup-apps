//
//  EXAddressListModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class AddressItem: EXBaseModel {
    var id = ""
    var uid = ""
    var symbol = ""
    var address = ""
    var label = ""
    var status = ""
    var ctime = ""
    var trustType = ""
    
    func isTrust() -> Bool {
        return trustType == "1"
    }
    
    
    func tagShow() -> String {
        let addressAry = address.components(separatedBy: "_")
        if addressAry.count == 2 {
            return addressAry[1]
        }
        return ""
    }
    func addressShow() -> String {
        var add = address
        let addressAry = address.components(separatedBy: "_")
        if addressAry.count == 2 {
            add = addressAry[0]
        }
//        if add.count > 19 {
//            let pre8 = String(add.prefix(8))
//            let sux8 = String(add.suffix(8))
//            return pre8 + "..." + sux8
//        }
        return add
    }
}

class EXAddressListModel: EXBaseModel {
    var addressList:[AddressItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.addressList = AddressItem.mj_objectArray(withKeyValuesArray: self.addressList).copy() as! [AddressItem]
    }
}
