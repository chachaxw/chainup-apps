//
//  LottieAnimationView+Ex.swift
//  Chainup
//
//  Created by youbin on 2023/8/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Lottie

extension LottieAnimationView {
    
    func updateColorValue(keypaths: [String]? = [], color: UIColor? = .Ex.main1) {
        guard let keypaths = keypaths, keypaths.count != 0 else {
            return
        }
        guard let rgba = color?.arrayFromRGBAComponents(), rgba.count == 4 else {
            return
        }
        let lottieColor = LottieColor(r: rgba[0] as! Double,
                                      g: rgba[1] as! Double,
                                      b: rgba[2] as! Double,
                                      a: rgba[3] as! Double)
        let colorProvider = ColorValueProvider(lottieColor)
        keypaths.forEach { path in
            let _path = path.trimmingCharacters(in: .whitespacesAndNewlines)
            if _path.isEmpty { return }
            
            let keypath = AnimationKeypath(keypath: _path)
            setValueProvider(colorProvider, keypath: keypath)
        }
    }
    
    func updateTabbarItemColorValue(color: UIColor? = .Ex.main1) {
        guard let rgba = color?.arrayFromRGBAComponents(), rgba.count == 4 else {
            return
        }
        guard allHierarchyKeypaths().count != 0 else { return }
        let lottieColor = LottieColor(r: rgba[0] as! Double,
                                      g: rgba[1] as! Double,
                                      b: rgba[2] as! Double,
                                      a: rgba[3] as! Double)
        let colorProvider = ColorValueProvider(lottieColor)
        allHierarchyKeypaths().forEach { path in
            if path.contains("tabbar_home_hover") && path.contains("轮廓.组 2.填充 1.Color") {
                let keypath = AnimationKeypath(keypath: path)
                setValueProvider(colorProvider, keypath: keypath)
            }
            if path.contains("tabbar_quotation_hover") && path.contains("轮廓.组 2.填充 1.Color") {
                let keypath = AnimationKeypath(keypath: path)
                setValueProvider(colorProvider, keypath: keypath)
            }
            if path.contains("tabbar_tradingt_hover") && path.contains("轮廓.组 2.填充 1.Color") {
                let keypath = AnimationKeypath(keypath: path)
                setValueProvider(colorProvider, keypath: keypath)
            }
            if path.contains("tabbar_contract_hover") && (
                path.contains("轮廓.组 1.填充 1.Color") ||
                path.contains("轮廓.组 2.填充 1.Color") ||
                path.contains("轮廓.组 7.填充 1.Color")) {
                let keypath = AnimationKeypath(keypath: path)
                setValueProvider(colorProvider, keypath: keypath)
            }
            if path.contains("tabbar_assest_hover") && path.contains("轮廓.组 3.填充 1.Color") {
                let keypath = AnimationKeypath(keypath: path)
                setValueProvider(colorProvider, keypath: keypath)
            }
        }
    }
    
}
