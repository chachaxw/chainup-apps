//
//  ThemeLabelStyle.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/5.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public extension UILabel {
    
    func h1Medium() {
        self.font = UIFont.ThemeFont.H1Medium
    }
    
    func h2Medium() {
        self.font = UIFont.ThemeFont.H2Medium
    }
    
    func headBold() {
        self.font = UIFont.ThemeFont.HeadBold
    }
    
    func headRegular() {
        self.font = UIFont.ThemeFont.HeadRegular
    }
    
    func bodyBold() {
        self.font = UIFont.ThemeFont.BodyBold
    }
    
    func bodyRegular() {
        self.font = UIFont.ThemeFont.BodyRegular
    }
    
    func secondaryBold() {
        self.font = UIFont.ThemeFont.SecondaryBold
    }
    
    func secondaryRegular() {
        self.font = UIFont.ThemeFont.SecondaryRegular
    }
    
    func minimumBold() {
        self.font = UIFont.ThemeFont.MinimumBold
    }
    
    func minimumRegular() {
        self.font = UIFont.ThemeFont.MinimumRegular
    }
    
}
