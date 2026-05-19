//
//  EXGoogleDownloadTC.swift
//  Chainup
//
//  Created by zewu wang on 2019/4/15.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXGoogleDownloadTC: UITableViewCell {
    
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
        return label
    }()
    
    lazy var downLoadBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        btn.setTitle(LanguageTools.getString(key: "personal_Center_text14"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickDownLoadBtn))
        return btn
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
        contentView.addSubViews([nameLabel,downLoadBtn,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(downLoadBtn)
            make.right.equalTo(downLoadBtn.snp.left).offset(-10)
            make.height.equalTo(20)
        }
        let text = LanguageTools.getString(key: "personal_Center_text14")
        let w = text.getTextWidth(width: 300, font: 14, lineH: 0) + 10
        downLoadBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(32)
            make.width.equalTo(w)
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-20)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(15)
        }
    }
    
    func setCell(_ entity : EXGoogleCellEntity){
        nameLabel.text = entity.name
    }
    
    //点击下载按钮
    @objc func clickDownLoadBtn(){
        if let url = URL.init(string: "https://itunes.apple.com/cn/app/google-authenticator/id388497605?mt=8"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
