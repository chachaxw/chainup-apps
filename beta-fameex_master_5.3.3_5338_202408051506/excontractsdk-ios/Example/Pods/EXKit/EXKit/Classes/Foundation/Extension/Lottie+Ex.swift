//
//  Lottie+Ex.swift
//  EXKit
//
//  Created by bradjohn on 2023/8/30.
//

import UIKit
import Lottie

public extension LottieAnimationView {
    
    func updateColor(keypaths:[String]? = [], color: UIColor? = nil) {
        guard let keypaths = keypaths, keypaths.count != 0 else { return }
        guard let color = color else { return }
        var r:CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard color.getRed(&r, green: &g, blue: &b, alpha: &a) else { return }
        let colorProvider = ColorValueProvider(LottieColor(r: r, g: g, b: b, a: a))
        keypaths.filter({!$0.isEmpty}).forEach({setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: $0))})
    }
    
}
