//
//  EXRealNameOneTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXCustomInputDelegate: NSObject {
    //special
    var limitPattern = "[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]"
}

class EXRealNameOneTC: UITableViewCell {
    
    typealias ClickTextBlock = (EXRealNameEntity , EXSelectionField) -> ()
    var clickTextBlock : ClickTextBlock?
    
    typealias TextfieldValueChangeBlock = () -> ()
    var textfieldValueChangeBlock : TextfieldValueChangeBlock?
    
    lazy var inputDelegete = EXCustomInputDelegate()
    
    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.layoutIfNeeded()
        text.enableTitleModel = true
        text.inputLimitPattern = inputDelegete.limitPattern
        return text
    }()
    
    lazy var textFieldSelect : EXSelectionField = {
        let text = EXSelectionField()
        text.extUseAutoLayout()
        text.enableTitleModel = true
        text.triangle.useBig = true
        return text
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([textField,textFieldSelect])
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        textFieldSelect.snp.makeConstraints { (make) in
            make.edges.equalTo(textField)
        }
    }
    
    func setCell(_ entity :  EXRealNameEntity){
        textFieldSelect.isHidden = entity.type == "2"
        textFieldSelect.isUserInteractionEnabled = entity.isUserInteractionEnabled

        textField.isHidden = entity.type == "1"
        textField.isUserInteractionEnabled = entity.isUserInteractionEnabled

        if entity.type == "1"{ //1 Select 2 Fill in
            textFieldSelect.setTitle(title: entity.title)
            textFieldSelect.setPlaceHolder(placeHolder: entity.placeholder)
            textFieldSelect.setText(text: entity.text)
            textFieldSelect.textfieldDidTapBlock = {[weak self]() in
                guard let mySelf = self else{return}
                self?.clickTextBlock?(entity,mySelf.textFieldSelect)
            }
        }else if entity.type == "2"{
            if entity.count > 0{
                self.textField.input.rx.text.orEmpty.asObservable().subscribe({ (event) in
                    if let text = event.element{
                        if text.count > entity.count{
                            self.textField.input.text = text[0...entity.count]
                        }
                    }
                }).disposed(by: disposeBag)
            }
            textField.setText(text: entity.text)
            textField.setTitle(title: entity.title)
            textField.setPlaceHolder(placeHolder: entity.placeholder)
            textField.textfieldValueChangeBlock = {[weak self](str) in
                entity.info = str
                self?.textfieldValueChangeBlock?()
            }
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

