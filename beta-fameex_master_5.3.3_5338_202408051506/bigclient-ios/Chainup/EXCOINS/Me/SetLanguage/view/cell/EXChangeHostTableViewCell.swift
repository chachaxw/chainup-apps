//
//  EXChangeHostTableViewCell.swift
//  Chainup
//
//  Created by chainup on 2023/6/16.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXDomainSelectItem:UIButton {
    
    lazy var responseLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var statusBtn:UIButton = {
        let btn = UIButton()
        btn.isUserInteractionEnabled = false
        btn.setImage(UIImage.themeImageNamed(imageName: "lineswitching_unselected"), for: .normal)
        btn.setImage(UIImage.themeImageNamed(imageName: "lineswitching_selected"), for: .selected)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(responseLabel)
        self.addSubview(statusBtn)
        responseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        statusBtn.snp.makeConstraints { make in
            make.left.equalTo(responseLabel.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXChangeHostTableViewCell: UITableViewCell {
    
    let api_x_position = SCREEN_WIDTH * 0.285
    let ws_x_position = SCREEN_WIDTH * 0.74
    
    typealias HostCallback = (EXHostEntity) -> ()
    var domainCallback : HostCallback?
    var wsCallback : HostCallback?
    
    var apiEntity:EXHostEntity?
    var wsEntity:EXHostEntity?

    lazy var apiResposer:EXDomainSelectItem = {
        let api = EXDomainSelectItem()
        api.addTarget(self, action: #selector(onChangeApiAction(sender:)), for: .touchUpInside)
        return api
    }()
    
    lazy var wsResposer:EXDomainSelectItem = {
        let ws = EXDomainSelectItem()
        ws.addTarget(self, action: #selector(onChangeWsAction(sender:)), for: .touchUpInside)
        return ws
    }()
    
    lazy var nameLabel : UILabel = {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        
        contentView.addSubViews([nameLabel,apiResposer,wsResposer,lineV])
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.lessThanOrEqualTo(api_x_position)
        }
        
        apiResposer.snp.makeConstraints { (make) in
            make.left.equalTo(api_x_position)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        wsResposer.snp.makeConstraints { (make) in
            make.left.equalTo(ws_x_position)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        lineV.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func bindDomainEntity(entity:EXHostEntity?,wsentity:EXHostEntity?) {
        if let api = entity {
            self.apiEntity = api
            apiResposer.isHidden = false
            apiResposer.statusBtn.isSelected = api.selected
            apiResposer.responseLabel.text = api.apiRtt
            apiResposer.responseLabel.textColor = api.rttColor
        }else {
            apiResposer.isHidden = true
        }
        
        if let ws = wsentity {
            self.wsEntity = ws
            wsResposer.isHidden = false
            wsResposer.statusBtn.isSelected = ws.wsSelected
            wsResposer.responseLabel.text = ws.wsRtt
            wsResposer.responseLabel.textColor = ws.wsrttColor
        }else {
            wsResposer.isHidden = true
        }
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onChangeApiAction(sender:EXDomainSelectItem) {
        guard let apien = self.apiEntity else {return}
//        apiResposer.statusBtn.isSelected = !sender.statusBtn.isSelected
        self.domainCallback?(apien)
    }
    
    @objc func onChangeWsAction(sender:EXDomainSelectItem) {
        guard let wsen = self.wsEntity else {return}
//        wsResposer.statusBtn.isSelected = !sender.statusBtn.isSelected
        self.wsCallback?(wsen)
    }
}
