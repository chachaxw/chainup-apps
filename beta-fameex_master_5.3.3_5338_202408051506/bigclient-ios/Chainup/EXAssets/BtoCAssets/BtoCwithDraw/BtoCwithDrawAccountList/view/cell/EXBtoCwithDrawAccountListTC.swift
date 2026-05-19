//
//  EXBtoCwithDrawAccountListTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCwithDrawAccountListTC: UITableViewCell {
    
    typealias ClickEditorBtnBlock = (EXBtoCwithDrawAccountListModel) -> ()
    var clickEditorBtnBlock : ClickEditorBtnBlock?

    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "bankcard")
        return imgV
    }()
    
    lazy var bankNameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorDark
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var bankNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var editorBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitle("b2c_text_edit".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickEditorBtn))
        btn.contentHorizontalAlignment = .right
        btn.setEnlargeEdgeWithTop(10, left: 0, bottom: 10, right: 10)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([imgV,bankNameLabel,nameLabel,bankNumLabel,lineV,editorBtn])
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.top.left.equalToSuperview().offset(15)
        }
        bankNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(imgV)
            make.left.equalTo(imgV.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(14)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(14)
            make.right.equalTo(editorBtn.snp.left).offset(-15)
            make.top.equalTo(imgV.snp.bottom).offset(20)
        }
        editorBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.centerY.equalTo(nameLabel)
            make.width.lessThanOrEqualTo(200)
        }
        bankNumLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(16)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
        
    }
    
    var entity = EXBtoCwithDrawAccountListModel()
    
    func setCell(_ entity : EXBtoCwithDrawAccountListModel){
        self.entity = entity
        bankNameLabel.text = entity.bankName
        nameLabel.text = entity.name
        bankNumLabel.text = entity.cardNo
    }
    
    @objc func clickEditorBtn(){
        self.clickEditorBtnBlock?(self.entity)
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
