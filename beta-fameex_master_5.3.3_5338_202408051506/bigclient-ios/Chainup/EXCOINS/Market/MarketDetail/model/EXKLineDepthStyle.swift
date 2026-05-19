//
//  EXKLineDepthStyle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXKLineDepthStyle: NSObject {
    
    static func depthStyle()->CHKLineChartStyle {
        let style = CHKLineChartStyle()
        //font size
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //Zone Border Color
        style.lineColor = UIColor(white: 0.7, alpha: 1)
        //background color 
        style.backgroundColor = UIColor.ThemekLine.viewBg
        //Text color
        style.textColor = UIColor.ThemekLine.labcolorMedium
        //The inner margin of the entire chart
        style.padding = UIEdgeInsets(top: 32, left: 0, bottom: 20, right: 0)
        //Is the Y-axis embedded
        style.isInnerYAxis = true
        //The Y-axis is displayed on the right
        style.showYAxisLabel = .right
        //Boundary width
        style.borderWidth = (0, 0, 0, 0)
        
        style.bidChartOnDirection = .left
        style.showXAxisLabel = true 
        style.enableTap = false
        //The color of the buyer's deep layer UIColor (hex: 0xAD6569) UIColor (hex: 0x469777)
        style.bidColor = (UIColor.ThemekLine.up,UIColor.ThemekLine.up15, 1)
        //The color of the buyer's deep layer
        style.askColor = (UIColor.ThemekLine.down, UIColor.ThemekLine.down15, 1)
        
        return style
    }
}

