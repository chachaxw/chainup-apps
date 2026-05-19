//
//  GestureValidationVM.swift
//  Chainup
//
//  Created by zewu wang on 2023/9/3.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class GestureValidationVM: NSObject {

    var vc : GestureValidationVC?
    
    func setVC(_ vc : GestureValidationVC){
        self.vc = vc
    }
    
}

