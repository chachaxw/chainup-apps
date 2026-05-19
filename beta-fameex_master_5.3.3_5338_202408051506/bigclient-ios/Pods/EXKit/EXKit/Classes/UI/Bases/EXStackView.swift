//
//  EXStackView.swift
//  EXKit
//
//  Created by zq on 2023/4/6.
//

import UIKit

public class EXStackView: UIStackView {
    ///
    public class Separator: UIView {
        ///
        public struct Configuration {
            public let color:UIColor
            public let width:CGFloat
            public let height:CGFloat
            public let cornerRadius:CGFloat
            //
            fileprivate weak var stackView:EXStackView?
            //
            public var isHidden:Bool = false {
                didSet {
                    stackView?.setNeedsLayout()
                    if stackView?.superview != nil { stackView?.layoutIfNeeded() }
                }
            }
            ///
            public static let `default`:Self = Configuration()
            public static let pixelOfOne:CGFloat = 1/UIScreen.main.scale
            ///
            public init(color: UIColor = .Ex.fill5, width: CGFloat = -1, height: CGFloat = -1, cornerRadius: CGFloat = -1) {
                self.color = color
                self.width = width
                self.height = height
                self.cornerRadius = cornerRadius
            }
        }
    }
    private var isLayoutDisabled = false
    public var separatorConfiguration:Separator.Configuration? = .default {
        didSet {
            guard !isLayoutDisabled else { return }
            setNeedsLayout()
            if superview != nil { layoutIfNeeded() }
        }
    }
    //
    private var separators:[Separator] = []
    //
    public override func layoutSubviews() {
        super.layoutSubviews()
        separators.forEach({ $0.removeFromSuperview() })
        separators.removeAll()
        //
        isLayoutDisabled = true
        separatorConfiguration?.stackView = self
        isLayoutDisabled = false
        guard let separatorConfiguration = separatorConfiguration, !separatorConfiguration.isHidden else { return }
        //
        let arrangedSubviews = self.arrangedSubviews.filter({ !$0.isHidden && $0.alpha > 0.01 })
        if arrangedSubviews.count <= 1 { return }
        guard bounds.width > 0, bounds.height > 0 else { return }
        //
        var width  = separatorConfiguration.width
        if width < Separator.Configuration.pixelOfOne {
            width = axis == .vertical ? bounds.width : Separator.Configuration.pixelOfOne
        }
        //
        var height = separatorConfiguration.height
        if height < Separator.Configuration.pixelOfOne {
            height = axis == .vertical ? Separator.Configuration.pixelOfOne : bounds.height
        }
        //
        var cornerRadius = separatorConfiguration.cornerRadius
        if cornerRadius < 0 {
            cornerRadius = (min(width, height)) / 2
            if cornerRadius < Separator.Configuration.pixelOfOne { cornerRadius = 0 }
        }
        for idx in 0..<(arrangedSubviews.count - 1) {
            let view = arrangedSubviews[idx]
            let nextView = arrangedSubviews[idx + 1]
            let center = axis == .vertical ?
            CGPoint(x: bounds.midX, y: (nextView.frame.minY + view.frame.maxY) / 2) :
            CGPoint(x: (nextView.frame.minX + view.frame.maxX) / 2, y: bounds.midY)
            //
            let separator = Separator(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            separator.backgroundColor = separatorConfiguration.color
            separator.corneradius = cornerRadius
            addSubview(separator)
            separator.center = center
            separators.append(separator)
        }
    }
}
