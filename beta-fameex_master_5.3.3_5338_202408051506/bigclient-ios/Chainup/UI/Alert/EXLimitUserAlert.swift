//
//  EXLimitUserAlert.swift
//  Chainup
//
//  Created by youbin on 2023/6/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXLimitUserAlert: UIView {
    
    lazy var mainView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var backImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var headerImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.image = UIImage.themeImageNamed(imageName: "limit_user_notice")
        return v
    }()
    
    lazy var containerV: UIImageView = {
        let v = UIImageView()
        v.isUserInteractionEnabled = false
        v.extUseAutoLayout()
        v.extSetCornerRadius(15)
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        v.image = UIImage.themeImageNamed(imageName: "earth")
        v.extSetBorderWidth(1, color: UIColor.extColorWithHex("#F1F3F8"))
        return v
    }()
    
    lazy var streamerImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleToFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor.extColorWithHex("#F1F3F8")
        return v
    }()
    
    lazy var moreImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage.themeImageNamed(imageName: "limit_user_more")
        return v
    }()

    lazy var titleLabel : UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.textAlignment = .left
        v.textColor = UIColor.ThemeLabel.colorLite
        v.font = UIFont.ThemeFont.HeadMedium
        v.text = "customSetting_limitAccess_title".localized()
        return v
    }()
    
    lazy var tipsView : UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.extUseAutoLayout()
        textView.backgroundColor = .clear
        textView.textColor       = UIColor.ThemeLabel.colorMedium
        textView.font            = UIFont.ThemeFont.BodyMedium
        textView.isScrollEnabled = false
        textView.textAlignment   = .left
        textView.isEditable      = false
//        textView.isScrollEnabled = true
        return textView
    }()
    //Earth in the lower right corner
    lazy var earthImg : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "earth")
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame:.zero)
        self.backgroundColor = .clear
        setupView()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT)
        }
        mainView.addSubViews([backImgV, containerV, headerImgV])
        mainView.bringSubviewToFront(headerImgV)
        backImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
        }
        headerImgV.snp.makeConstraints { make in
            make.bottom.equalTo(containerV.snp.top).offset(17)
            make.centerX.equalToSuperview()
            make.height.equalTo(85)
            make.width.lessThanOrEqualTo(containerV.snp.width)
        }
        containerV.addSubViews([streamerImgV ,titleLabel, tipsView])
        streamerImgV.addSubview(moreImgV)
        streamerImgV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(29)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(streamerImgV.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        tipsView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(0)
        }

        moreImgV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 16, height: 4))
        }
    }
    
    func bindViewModel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        containerV.addGestureRecognizer(tap)
    }
    
    @objc func dismiss() {
        EXAlert.dismiss()
    }
    
    func setForbidCountry(_ name: String) {
        
        let text = name
//            name//String(format: "customSetting_limitAccess_desc".localized() , name)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        style.paragraphSpacing = 24
        let attributes = [NSAttributedString.Key.paragraphStyle : style,
                          .foregroundColor:UIColor.ThemeLabel.colorMedium,
                          .font:UIFont.ThemeFont.getPFSCFont(size: 14, aweight: .medium)]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
       var textHeight = attributedText.boundingRect(with:CGSize(width: (SCREEN_WIDTH - 110), height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height + 40
        
//        var textHeight = ceilf(Float(attributedText.string.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: SCREEN_WIDTH - 110).height)) + 40
        let maxHeight = CGFloat(SCREEN_HEIGHT * 0.7)
        textHeight = textHeight > maxHeight ? maxHeight : textHeight
        self.tipsView.snp.updateConstraints { make in
            make.height.equalTo(textHeight)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
            self.containerV.layoutIfNeeded()
//            self.containerV.insertSubview(self.earthImg, at: 0)
//            self.tipsView.backgroundColor = .clear
//            self.earthImg.backgroundColor = .red
//            self.earthImg.snp.makeConstraints { make in
//                make.width.height.equalTo(45)
//                make.right.equalToSuperview().offset(-50)
//                make.bottom.equalToSuperview().offset(-50)
//
//            }
        } completion: { finished in }
        
        self.tipsView.attributedText = attributedText
    }
    
}

