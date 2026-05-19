//
//  EXUIimageExtension.swift
//  Chainup
//
//  Created by cwd on 2023/4/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

public enum ImageVersion{
    case five
    case six
}
extension UIImage {
    
    class func getImagesBundle() -> Bundle? {
        if let bundlePath = Bundle.main.path(forResource: "ImageBundle", ofType: ".bundle"),let bundle = Bundle(path: bundlePath) {
          return bundle
        }
        return nil
    }
    public static func svgImage(named: String,version: ImageVersion? = .six) -> UIImage? {
        if version == .five{
            return EXKitFiveBundle.svgImage(named: named)
        }
        return EXKitBundle.svgImage(named: named)
    }
}
