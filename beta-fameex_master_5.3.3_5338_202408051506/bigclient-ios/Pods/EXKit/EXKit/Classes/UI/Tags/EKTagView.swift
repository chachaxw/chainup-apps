//
//  EKTagView.swift
//  EXKit-EXKit
//
//  Created by liuxuan on 2022/7/26.
//

import UIKit

public class EKTagView: UIView {
    public typealias ClickTagCB = (Int) -> ()//点击取消按钮的回调
    public var onTagIdxCallback:ClickTagCB?

    var maxWidth = Device_W - 32

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindingTags(_ tags:[String]) {
        var currentX:CGFloat = 0
        var currentY:CGFloat = 0
        let lineH:CGFloat = 22
        let spaceX:CGFloat = 8

        for (idx,tagitem) in tags.enumerated() {
            let nameWidth = tagitem.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: CGFloat.greatestFiniteMagnitude).width + 16
            let bindV = UIButton.init(type: .custom)
            bindV.adjustsImageWhenHighlighted = false
            bindV.setBackgroundColor(color: UIColor.ThemeView.card2, forState: .normal)
            bindV.layer.cornerRadius = 4
            bindV.addTarget(self, action: #selector(onClickTagBtn(_:)), for: .touchUpInside)
            bindV.tag = idx
            bindV.setTitle(tagitem, for: .normal)
            bindV.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            bindV.titleLabel?.font = UIFont.ThemeFont.BodyMedium
            bindV.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            self.addSubview(bindV)
            let width = min(maxWidth, nameWidth)
            if currentX + width > maxWidth {
                currentX = 0
                currentY += lineH + spaceX
            }
            
            bindV.snp.makeConstraints { make in
                make.left.equalTo(currentX)
                make.top.equalTo(currentY)
                make.height.equalTo(lineH)
            }
            
            currentX += (width+spaceX)
        }
    }
    
    @objc func onClickTagBtn(_ sender:UIButton) {
        self.onTagIdxCallback?(sender.tag)
    }
    
    public class func heightForTagV(_ tags:[String]) -> CGFloat {
        let maxWidth = Device_W - 32
        var currentX:CGFloat = 0
        var currentY:CGFloat = 0
        let lineH:CGFloat = 22
        let spaceX:CGFloat = 8
        for ( _ ,tagitem) in tags.enumerated() {
            let nameWidth = tagitem.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: CGFloat.greatestFiniteMagnitude).width + 16
            let width = min(maxWidth, nameWidth)
            if currentX + width > maxWidth {
                currentX = 0
                currentY += lineH + spaceX
            }
            currentX += (width+spaceX)
        }
        return currentY + lineH
    }
}
