//
//  ThemeFonts.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/12.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public extension UIFont {
    class func fontWithName(fontName: String, size: CGFloat) -> UIFont? {
        if let f = UIFont(name: fontName, size: size) {
            return f
        }
        return UIFont.systemFont(ofSize: size)

    }

    struct ThemeFont {
        public static var RMedium :UIFont { return  getFont(size: 32, aweight: .medium)}
        public static var H1Medium :UIFont { return getFont(size: 28, aweight: .medium)}
        public static var H1Bold :UIFont { return   getFont(size: 28, aweight: .medium)}
        public static var H2Medium :UIFont { return getFont(size: 24, aweight: .medium)}
        public static var H2Bold :UIFont { return   getFont(size: 24, aweight: .medium)}
        public static var H3Bold :UIFont { return   getFont(size: 18, aweight: .medium)}
        public static var H3Medium :UIFont { return getFont(size: 18, aweight: .medium)}
        public static var H3Regular :UIFont { return getFont(size: 18, aweight: .regular)}
        public static var HeadRegular :UIFont { return getFont(size: 16, aweight: .regular)}
        public static var HeadMedium :UIFont { return getFont(size: 16, aweight: .medium)}
        public static var HeadBold :UIFont { return getFont(size: 16, aweight: .medium)}
        public static var BodyRegular:UIFont { return getFont(size: 14, aweight: .regular)}
        public static var BodyMedium:UIFont { return getFont(size: 14, aweight: .medium)}
        public static var BodyBold :UIFont { return  getFont(size: 14, aweight: .medium)}
        public static var Semibold :UIFont { return  getFont(size: 14, aweight: .medium)}
        public static var BodyBoldTalic : UIFont{return UIFont.init(name: "Arial-BoldItalicMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)}
        public static var SecondaryBold:UIFont { return  getFont(size: 12, aweight: .medium)}
        public static var SecondaryRegular :UIFont { return  getFont(size: 12, aweight: .regular)}
        public static var SecondaryMedium :UIFont { return getFont(size: 12, aweight: .medium)}
        public static var MinimumRegular:UIFont { return getFont(size: 10, aweight: .regular)}
        public static var MinimumBold :UIFont { return getFont(size: 10, aweight: .medium)}
        public static var TagRegular:UIFont { return getFont(size: 10, aweight: .medium)}

        public static func getFont(size:CGFloat,aweight:Weight) ->UIFont {
            return UIFont.Ex.fontWith(size: size, weight: aweight)
//            return UIFont.Ex.DIN(size: size, weight: aweight)
        }
        
        public static func getPFSCFont(size:CGFloat,aweight:Weight) ->UIFont {
            return UIFont.Ex.fontWith(size: size, weight: aweight)
//            return UIFont.Ex.PingFang(size: size, weight: aweight)
        }
        
        
    }
}

public extension NSObject {
    
    /*
     == DINPro-Medium
     == DINPro-Regular
     == DINPro-Bold
     */
    func themeHNFont(size:CGFloat) -> UIFont{
        return UIFont.ThemeFont.getFont(size: size, aweight: .regular)
    }
    
    func themeHNBoldFont(size:CGFloat)  -> UIFont{
        return UIFont.ThemeFont.getFont(size: size, aweight: .medium)
    }
    
    func themeHNMediumFont(size:CGFloat)  -> UIFont{
        return UIFont.ThemeFont.getFont(size: size, aweight: .medium)
    }
    
    func themeHNBoldItalicFont(size:CGFloat)  -> UIFont{
        if let hnFont = UIFont.init(name: "HelveticaNeue-BoldItalic", size: size) {
            return hnFont
        }else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
}
