//
//  EXUIMeasure.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXUIMeasure: NSObject {
    
    //0.7/0.8, etc
    class func getPercentX(_ persent:CGFloat) ->CGFloat {
        return CGFloat(ceilf(Float(SCREEN_WIDTH * persent)))
    }

}

