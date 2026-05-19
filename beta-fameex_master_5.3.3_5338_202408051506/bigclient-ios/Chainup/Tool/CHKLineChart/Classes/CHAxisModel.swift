//
//  YAxis.swift
//  CHKLineChart
//
//  Created by Chance on 2023/8/31.
//  Copyright © 2023年 Chance. All rights reserved.
//

import Foundation
import UIKit




/**
The position displayed on the Y-axis
 
-Left: Left
-Right: Right
-None: Do not display
 */
public enum CHYAxisShowPosition {
    case left, right, none
}

///Axis Guide Style Style
///
///- none: Do not display
///- dash: dashed line
///- solid: solid line
public enum CHAxisReferenceStyle {
    case none
    case dash(color: UIColor, pattern: [NSNumber])
    case solid(color: UIColor)
}

/**
*Y-axis data model
 */
public struct CHYAxis {
    
    public var max: CGFloat = 0                //Maximum value of Y-axis
    public var min: CGFloat = 0                //Minimum value of Y-axis
    public var ext: CGFloat = 0.00             //The proportion of overflow values at the upper and lower boundaries
    public var baseValue: CGFloat = 0          //Fixed base value
    public var tickInterval: Int = 4           //Number of intermittent displays
    public var pos: Int = 0
    public var decimal: Int = 2                //Constrain decimal places
    public var isUsed = false
    
    ///Guide Line Style
    public var referenceStyle: CHAxisReferenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
    
}

/**
*X-axis data model
 */
public struct CHXAxis {
    
    public var tickInterval: Int = 6           //Number of intermittent displays
    
    ///Guide Line Style
    public var referenceStyle: CHAxisReferenceStyle = .solid(color:UIColor(white:0.2,alpha: 1))
}

