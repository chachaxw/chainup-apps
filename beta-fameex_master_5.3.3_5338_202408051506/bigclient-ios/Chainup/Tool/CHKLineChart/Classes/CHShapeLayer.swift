//
//  CHShapeLayer.swift
//  CHKLineChart
//
//  Created by Chance on 2023/6/23.
//  Copyright © 2023年 bitbank. All rights reserved.
//

import Foundation
import UIKit

open class CHShapeLayer: CAShapeLayer {
    
    //Turn off the implicit animation of CAShapeLayer to avoid the phenomenon of residual shadows when sliding or cross hairs appear (in fact, the implicit animation is generated due to changes in the position attribute of the Layer)
    open override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

open class CHTextLayer: CATextLayer {
    
    //Turn off the implicit animation of CAShapeLayer to avoid the phenomenon of residual shadows when sliding or cross hairs appear (in fact, the implicit animation is generated due to changes in the position attribute of the Layer)
    open override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

