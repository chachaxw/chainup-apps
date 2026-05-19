//
//  EXBtoCwithDrawAddAccountTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBtoCwithDrawAddAccountTC: UITableViewCell {
    
    typealias ClickSelectFieldBlock = (Int) -> ()
    var clickSelectFieldBlock : ClickSelectFieldBlock?
    
    typealias InputITextBlock = (Int,String) -> ()
    var inputITextBlock : InputITextBlock?
    
    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.isHidden = true
        text.enableTitleModel = true
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.inputText(str)
        }
        return text
    }()
    
    lazy var selectField : EXIconSelectionField = {
        let text = EXIconSelectionField()
        text.extUseAutoLayout()
        text.iconBtn.imageView?.contentMode = .scaleAspectFit
        text.iconBtn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
        text.textfieldDidTapBlock = {[weak self]() in
            self?.clickSelectField()
        }
        text.isHidden = true
        text.enableTitleModel = true
        return text
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([textField,selectField])
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(20)
            make.bottom.equalToSuperview()
        }
        selectField.snp.makeConstraints { (make) in
            make.edges.equalTo(textField)
        }
    }
    
    func setCell(_ entity : EXBtoCwithDrawAddAccountModel){
        textField.isHidden = true
        selectField.isHidden = true
        if entity.state == "0"{
            textField.isHidden = false
            textField.setText(text: entity.text)
            textField.setTitle(title: entity.title)
            textField.isUserInteractionEnabled = entity.editor
            textField.setPlaceHolder(placeHolder: entity.placeHolder)
        }else if entity.state == "1"{
            selectField.isHidden = false
            selectField.setText(text: entity.text)
            selectField.setTitle(title: entity.title)
            selectField.isUserInteractionEnabled = entity.editor
            selectField.setPlaceHolder(placeHolder: entity.placeHolder)
        }
    }
    
    func clickSelectField(){
        self.clickSelectFieldBlock?(self.tag - 1000)
    }
    
    func inputText(_ text : String){
        self.inputITextBlock?(self.tag - 1000,text)
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
