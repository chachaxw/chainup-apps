//
//  EXPageConfig.swift
//  Chainup
//
//  Created by chainup on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

extension SGPageTitleViewConfigure {
    
    static func defaultConfig() -> SGPageTitleViewConfigure {
        let configure = SGPageTitleViewConfigure.init()
        configure.indicatorStyle = SGIndicatorStyle.init(2)
        configure.indicatorColor = UIColor.ThemeView.highlight
        configure.indicatorHeight = 3.0
        configure.showBottomSeparator = false
        configure.equivalence = false
        configure.titleFont = UIFont.ThemeFont.HeadRegular
        configure.titleSelectedFont = UIFont.ThemeFont.HeadBold
        configure.titleColor = UIColor.ThemeLabel.colorMedium
        configure.titleSelectedColor = UIColor.ThemeLabel.colorLite
        configure.titleAdditionalWidth = 30
        configure.bottomSeparatorColor = UIColor.ThemeView.seperator
        return configure
    }
    
    static func OneLevel() -> SGPageTitleViewConfigure {
        let configure = SGPageTitleViewConfigure.init()
        configure.indicatorStyle = SGIndicatorStyle.init(2)
        configure.indicatorColor = UIColor.ThemeView.highlight
        configure.indicatorHeight = 4.0
        configure.showBottomSeparator = false
        configure.equivalence = false
        configure.titleFont = UIFont.ThemeFont.HeadRegular
        configure.titleSelectedFont = UIFont.ThemeFont.HeadBold
        configure.titleColor = UIColor.ThemeLabel.colorMedium
        configure.titleSelectedColor = UIColor.ThemeLabel.colorLite
        configure.titleAdditionalWidth = 30
        return configure
    }
    static func SecondLevel() -> SGPageTitleViewConfigure {
        let configure = SGPageTitleViewConfigure.init()
        configure.indicatorStyle = SGIndicatorStyleCover
        configure.indicatorHeight = 25
        configure.indicatorAdditionalWidth = 30
        configure.indicatorCornerRadius = 2
        configure.indicatorColor = UIColor.ThemeView.card2
        configure.showBottomSeparator = false
        configure.equivalence = false
        configure.titleFont = UIFont.ThemeFont.BodyBold
        configure.titleSelectedFont = UIFont.ThemeFont.BodyRegular
        configure.titleColor = UIColor.ThemeLabel.colorMedium
        configure.titleSelectedColor = UIColor.ThemeLabel.colorLite
        return configure
    }
}

