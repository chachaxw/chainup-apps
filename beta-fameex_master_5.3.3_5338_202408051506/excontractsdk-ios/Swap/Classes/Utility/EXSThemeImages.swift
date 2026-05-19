//
//  ThemeImages.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import YYCache

extension UIImage {
    
    public static func exs_themeImageNamed(imageName:String,isFromKline: Bool = false) -> UIImage {
        var newName = imageName
        if isFromKline == true && EXTheme.current == .dayKLineNight {
            newName += "_night"
        }
        return EXKitBundle.image(named: newName) ?? UIImage()
    }
    

    /**
     这个用来修改颜色的 English: This is used to modify colors
     */
    public static func svg_themeImageNamed(imageName:String,size: CGSize? = nil) -> UIImage?{
        
        return EXKitBundle.svgImage(named: imageName)
    }
    
}

