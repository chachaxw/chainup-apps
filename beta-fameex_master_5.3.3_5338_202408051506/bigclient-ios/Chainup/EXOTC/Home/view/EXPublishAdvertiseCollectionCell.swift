//
//  EXPublishAdvertiseCollectionCell.swift
//  Chainup
//
//  Created by ljw on 2023/11/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
enum align {
    case Left
    case center
    case right
}
class EXPublishAdvertiseCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIStackView!
    var model : EXOTCPaymentListModel = EXOTCPaymentListModel(){
        didSet {
            chooseBtn.isSelected = self.model.isChoose
            imageBtn.yy_setImage(with: URL.init(string: self.model.icon), for: UIControl.State.normal, placeholder: nil)
            label.text = self.model.title
        }
    }
    var modelsArr = [EXOTCPaymentListModel]()
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!

    
    lazy var label : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    
    var alignMent : align = .Left
//    {
//        didSet {
//            if alignMent == .Left {
//             backView.snp.remakeConstraints { (make) in
//                 make.left.equalTo(contentView)
//             }
//            }else if alignMent == .center {
//                backView.snp.remakeConstraints { (make) in
//                    make.centerX.equalTo(contentView)
//
//                }
//            }else if alignMent == .right {
//                backView.snp.remakeConstraints { (make) in
//                   make.right.equalTo(contentView)
//
//                }
//            }
//        }
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        self.backView.addArrangedSubview(label)
        self.backView.spacing = 5
        self.backView.distribution = .fill
        self.backView.snp_remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.chooseBtn.snp_remakeConstraints { make in
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        self.imageBtn.snp_remakeConstraints { make in
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        self.label.snp_remakeConstraints { make in
            make.centerY.equalToSuperview()
        }
        self.imageBtn.imageView?.contentMode = .scaleAspectFit
        chooseBtn.imageView?.contentMode = .scaleAspectFit
        chooseBtn.setImage(UIImage.themeImageNamed(imageName: "assets_selected"), for: UIControl.State.selected)
        chooseBtn.setImage(UIImage.themeImageNamed(imageName: "lineswitching_unselected"), for: UIControl.State.normal)
//        showNameBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
//        showNameBtn.isHidden = true
//        self.backView.removeArrangedSubview(self.showNameBtn)
        
        
//        showNameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(top))
        self.addGestureRecognizer(tap)
    }

   @objc func top() {
    var count = 0
    for item in modelsArr {
        if item.isChoose {
            count = count + 1
            
        }
    }
    //Cannot exceed 3
    if count == 3 && !model.isChoose{
        EXAlert.showFail(msg: "otc_getMoney_Method".localized())
        return
    }
        model.isChoose = !model.isChoose
        chooseBtn.isSelected = model.isChoose
    }
}

