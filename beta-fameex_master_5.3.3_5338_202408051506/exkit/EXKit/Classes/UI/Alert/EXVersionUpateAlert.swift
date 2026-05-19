//
//  EXVersionUpateAlert.swift
//  EXKit
//
//  Created by cwd on 2023/5/17.
//

import UIKit
public class EXNewVersionUpateAlert: UIView {
    private let margin: CGFloat = 40
    public typealias AlertCallback = (BottomBtnType) -> ()
    public var alertCallBack: AlertCallback?
    
    //MARK: lazy
    //头部icon
    lazy var headImageView: UIImageView = {
        let v = UIImageView()
        v.image = EXKitBundle.svgImage(named:"home_prompt_new")
        return v
    }()
    
    //标题
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.numberOfLines = 5
        v.font = .Ex.medium(16)
        v.textColor = .Ex.text1
        v.lineBreakMode = .byTruncatingTail
        v.preferredMaxLayoutWidth = Device_W - margin * 2
        return v
    }()
    
    lazy var contentView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.indicatorStyle = EXThemeManager.isNight() ? .white : .default
        return scrollView
    }()
    //中间可滚动 文案
    lazy var contentLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.font = .Ex.regular(14)
        v.textColor = .Ex.text2
        v.preferredMaxLayoutWidth = Device_W - margin * 2
        return v
    }()
    
    //底部按钮
    lazy var bottomBtnView: UIView = {
        let v = UIView()
        return v
    }()
    //更新按钮
    lazy var updateBtn : EXButton = {
        let btn = EXButton()
        btn.clearColors()
        btn.backgroundColor = .Ex.main1
        btn.titleLabel?.font = .Ex.medium(14)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(onClickAction(sender:)), for: UIControl.Event.touchUpInside)
        btn.tag = 1
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        return btn
    }()
    //取消
    lazy var cancelBtn : EXButton = {
        let btn = EXButton()
        btn.clearColors()
        btn.titleLabel?.font = .Ex.medium(14)
        btn.backgroundColor = .Ex.fill3
        btn.setTitleColor(UIColor.Ex.text1, for: .normal)
        btn.addTarget(self, action: #selector(onClickAction(sender:)), for: UIControl.Event.touchUpInside)
        btn.tag = 0
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        return btn
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
     func setSubView() {
        corneradius = 12
        self.backgroundColor = UIColor.Ex.fill6
        self.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        self.addSubViews([headImageView,titleLabel,contentView,updateBtn,cancelBtn])
        headImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(95)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        contentView.addSubview(contentLabel)
        contentLabel.snp.updateConstraints { make in
            make.edges.width.equalTo(contentView)
        }
        updateBtn.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(updateBtn.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
    }
    
    
    //MARK: action
    @objc func onClickAction(sender: UIButton){
        EXKitAlert.dismiss()
        if let type = BottomBtnType(rawValue: sender.tag) {
            self.alertCallBack?(type)
        }
    }
    
    
    /*
     headImage: 图片
     title: 标题
     content: 内容 以\n 拼接
     updateTitle: 更新标题
     cancelTitle: 标题
     forceUpdate: 是否强制更
     */
    public func configAlert(headImage: UIImage? = nil,
                     title: String,
                     content: String,
                     updateTitle: String? = nil,
                     cancelTitle: String? = nil,
                     forceUpdate: Bool = false,
                     alertCallBack: @escaping AlertCallback
    ){
        self.alertCallBack = alertCallBack
        if let headImage = headImage {
            headImageView.image = headImage
        }
        titleLabel.text = title
        
        let attributedText = NSMutableAttributedString(string: content , attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.Ex.text2,
            NSMutableAttributedString.Key.font: UIFont.Ex.regular(14)
        ])
        attributedText.yy_maximumLineHeight = 20
        attributedText.yy_minimumLineHeight = 20
        contentLabel.attributedText = attributedText
        
        if let updateTitle = updateTitle {
            updateBtn.setTitle(updateTitle, for: .normal)
            updateBtn.setTitle(updateTitle, for: .highlighted)
        }
        
        if let cancelTitle = cancelTitle {
            cancelBtn.setTitle(cancelTitle, for: .normal)
            cancelBtn.setTitle(cancelTitle, for: .highlighted)
        }
        
        let titleHeight = titleLabel.intrinsicContentSize.height
        /// 内容的高度
        let contentHeight = contentLabel.intrinsicContentSize.height
        
        let top: CGFloat = titleHeight + 95 + 20 + 20 + 16 // 顶部
        var bottom: CGFloat = 20 + 44 + 8 + 44 + 20 //底部的高度
        if forceUpdate == true{
            cancelBtn.isHidden = true
            bottom = 20 + 44 + 20 //只有一个按钮的高度
        }
        
        
        let maxH = Device_H * 0.6
        let contentMax = maxH - top - bottom
        let _contentHeight = min(contentHeight, contentMax)
        
        let total = top + bottom + _contentHeight
        contentView.snp.updateConstraints { make in
            make.height.equalTo(_contentHeight)
        }
        
        self.snp.updateConstraints { make in
            make.height.equalTo(total)
        }
        
    }
    
}

