//
//  EXArrowBtn.swift
//  Chainup
//
//  Created by cwd on 2023/1/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXArrowBtn: EXCOCustomBaseView {
    var normalColor = UIColor.ThemeLabel.colorMedium
    var selectedColor = UIColor.ThemeLabel.colorLite
    var isSelected: Bool = false{
        didSet{
            let color = isSelected ? selectedColor : normalColor
            titleLabel.textColor = color
        }
    }
    var btnClick: EXComVoidBlock?
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var imageView : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down")
        return arrowImmg
    }()
    override func setSubView() {
        self.addSubview(titleLabel)
        self.addSubview(imageView)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right)
            make.width.height.equalTo(6)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    func roate(){
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let news = self else{return}
            news.imageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        }
    }
    func normal(){
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let news = self else{return}
            news.imageView.layer.transform = CATransform3DIdentity
        }
    }
    func updateFrame(){
        let  leftRight:CGFloat = 2
        let  topAndBottom:CGFloat = 2
        let title = self.titleLabel.text ?? " "
        let font = self.titleLabel.font ?? UIFont.ThemeFont.BodyRegular
        var size = title.ext_textSizeWithFont(font, width: Device_W)
        size.width += self.imageView.width
        var width = CGSize(width: size.width + leftRight * 2, height: size.height + topAndBottom * 2).width
        if width < 45 {
            width = 45
        }
        self.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    @objc func click(){
        self.btnClick?()
    }
}
