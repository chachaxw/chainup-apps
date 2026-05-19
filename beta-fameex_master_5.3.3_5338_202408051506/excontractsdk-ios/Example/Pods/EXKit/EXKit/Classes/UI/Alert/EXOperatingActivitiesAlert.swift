//
//  EXOperatingActivitiesAlert.swift
//  EXKit
//
//  Created by cwd on 2023/5/17.
//

import UIKit
// 运营活动的弹框
open class EXOperatingActivitiesAlert: EXBaseView{
    public func config(title: String, content: String, image: UIImage?){
        titleLabel.text = title
        contentLabel.text = content
        activityImg.image = image
    }
    
    open override func setSubView() {
        self.backgroundColor = .clear
        addSubViews([mainView,closeImage])
        mainView.addSubViews([titleLabel,contentLabel,activityImg])
        mainView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo((400+56)~)
        }
        closeImage.snp.makeConstraints { make in
            make.top.equalTo(mainView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(32~)
            make.height.equalTo((32+24)~)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23~)
            make.left.equalToSuperview().offset(21~)
            make.right.equalToSuperview().offset(-23~)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14~)
            make.left.right.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        activityImg.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(295~)
            make.height.equalTo(214~)
            make.centerX.equalToSuperview()
        }
    }
    
    
    //MARK: lazy
    lazy var mainView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill6
        v.corneradius = 12
        return v
    }()
    
    
    lazy var closeImage = {
        let img = UIImageView()
        img.image = EXKitBundle.image(named: "home_close")
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        img.addGestureRecognizer(tap)
        img.isUserInteractionEnabled = true
        return img
    }()
    
    @objc func click(){
        EXKitAlert.dismiss()
    }
    ///名称
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.fontWith(size: 20, weight: .medium), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        return label
    }()
    ///内容
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var activityImg : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        //MARK: fix 删除 图
        img.backgroundColor = .red
        return img
    }()
}
