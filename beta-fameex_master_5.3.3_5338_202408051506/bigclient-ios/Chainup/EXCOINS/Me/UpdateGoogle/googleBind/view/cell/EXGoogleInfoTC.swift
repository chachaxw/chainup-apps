//
//  EXGoogleInfoTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXGoogleInfoTC: UITableViewCell {
    
//    lazy var numLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        label.font = UIFont.ThemeFont.BodyBoldTalic
//        return label
//    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var pasteBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle(LanguageTools.getString(key: "common_action_copy"), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickPasteBtn))
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    
    lazy var infoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var infoBackView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,infoBackView,pasteBtn,infoLabel,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-15)
        }
        infoBackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(44)
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-20)
        }
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(infoBackView).offset(15)
            make.centerY.equalTo(infoBackView)
            make.height.equalTo(20)
            make.right.equalTo(pasteBtn.snp.left).offset(-5)
        }
        pasteBtn.snp.makeConstraints { (make) in
            make.right.equalTo(infoBackView).offset(-15)
            make.height.equalTo(20)
            make.centerY.equalTo(infoBackView)
            make.width.lessThanOrEqualTo(100)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(15)
        }
    }
    
    func setCell(_ entity : EXGoogleCellEntity){
        nameLabel.text = entity.name
        infoLabel.text = entity.info1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Click on the copy button
    @objc func clickPasteBtn(){
        let past = UIPasteboard.general
        past.string = infoLabel.text
        EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_copySuccess"))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

