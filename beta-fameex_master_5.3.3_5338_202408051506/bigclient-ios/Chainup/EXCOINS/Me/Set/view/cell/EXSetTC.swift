//
//  EXSetTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXSetTC: UITableViewCell {
    typealias InfoBtnCallBacK = (EXSetEntity)->()
    var onInfoBtnAction:InfoBtnCallBacK?
    var entity:EXSetEntity = EXSetEntity()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadRegular
        return label
    }()
    
    lazy var explainBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.themeImageNamed(imageName: "assets_doubt"), for: .normal)
        btn.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(infoBtnAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var rightNewDot : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.layer.cornerRadius = 3
//        view.layer.borderColor = UIColor.white.cgColor
//        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.ThemeState.fail
        view.isHidden = true
        return view
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,lineV,rightLabel,rightBtn,explainBtn,rightNewDot])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.height.equalTo(1)
            make.bottom.right.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rightBtn.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right).offset(20)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalToSuperview()
        }
        
        explainBtn.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(6)
            make.height.width.equalTo(13)
            make.centerY.equalToSuperview()
        }
        
        rightNewDot.snp.makeConstraints { (make) in
            make.right.equalTo(rightLabel.snp.left).offset(-4)
            make.width.height.equalTo(6)
            make.centerY.equalToSuperview()
        }
    }
    
    func setCell(_ entity : EXSetEntity){
        self.entity = entity
        nameLabel.text = entity.name
        rightLabel.text = entity.rightName
        lineV.isHidden = entity.action != .theme
        explainBtn.isHidden = entity.hideExplain
        rightNewDot.isHidden = entity.hideRedDot
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
    
    @objc func infoBtnAction(sender:UIButton) {
        self.onInfoBtnAction?(self.entity)
    }

}
