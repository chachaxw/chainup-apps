//
//  EXDropDownItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum DropDownSectionType: Int {
    case inputStyle //Input of the column
    case btnSelectionStyle //Button selection
    case btnExpandStyle //Expandable button selection
    case dateStyle //date
    case switchStyle //switch
    case inputExpandMixStyle//Comprehensive selection and input?? undetermined
}


class EXDropDownItem: NSObject {
    var key:String = ""
    var title:String = ""
    var select:String = ""
}

public struct DropDownSection {
    var sectionTitle: String
    var sectionType: DropDownSectionType
    var items: [EXDropDownItem]
    
    init (sectionTitle: String,type:DropDownSectionType, items: [EXDropDownItem]) {
        self.items = items
        self.sectionTitle = sectionTitle
        self.sectionType = type
    }
}

