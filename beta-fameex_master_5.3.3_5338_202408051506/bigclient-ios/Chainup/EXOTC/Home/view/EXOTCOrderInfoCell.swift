//
//  EXOTCOrderInfoCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXCellPosition {
    case top
    case middle
    case bottom
    case single 
}

class EXOTCOrderInfoCell: UITableViewCell {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var topGap: UIView!
    @IBOutlet var bottomGap: UIView!
    @IBOutlet var topGapConstant: NSLayoutConstraint!
    @IBOutlet var bottomGapConstant: NSLayoutConstraint!
    @IBOutlet var orderTitle: UILabel!
    @IBOutlet var orderValue: UILabel!
    @IBOutlet var actionBtn: UIButton!
    
    @IBOutlet weak var valueLabelTraining: NSLayoutConstraint!
    typealias ActionBtnCallback = (OTCOrderInfoActionType) -> ()
    var actionCallback : ActionBtnCallback?
    
    var cellModel :OTCOrderInfoModel = OTCOrderInfoModel()
    
//    var cellPosition:EXCellPosition = .middle {
//        didSet {
//            switch cellPosition {
//            case .top:
//                topGapConstant.constant = 3
//                bottomGapConstant.constant = 0
//            case .bottom:
//                bottomGapConstant.constant = 3
//                topGapConstant.constant = 0
//            case .middle:
//                topGapConstant.constant = 0
//                bottomGapConstant.constant = 0
//            case .single:
//                topGapConstant.constant = 3
//                bottomGapConstant.constant = 3
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.actionBtn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        self.actionBtn.imageView?.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateInfo(model:OTCOrderInfoModel) {
        self.cellModel = model
        
        orderTitle.text = model.title
        orderTitle.textColor = model.titleColor
        orderValue.text = model.value
        orderValue.textColor = model.valueColor
        if model.actionType == .none {
            actionBtn.isHidden = true
            self.valueLabelTraining.constant = 10
        }else {
            self.valueLabelTraining.constant = 30
            actionBtn.isHidden = false
            if model.actionType == .actionCopy {
                actionBtn.setImage(UIImage.themeImageNamed(imageName: "trade_compared"), for: .normal)
            }else if model.actionType == .actionQRCode {
                actionBtn.setImage(UIImage.themeImageNamed(imageName: "personal_qrcode"), for: .normal)
            }else if model.actionType == .actionContact {
                actionBtn.imageView?.contentMode = .scaleAspectFit
//                actionBtn.setImage(UIImage.image(named: "otc_phone",version: .five,imageType: .svg), for: .normal)
                actionBtn.setImage(UIImage.themeImageNamed(imageName: "fiat_contactnumber"), for: .normal)
            }
        }
        self.setNeedsDisplay()
    }
    
    @IBAction func actionBtnClick(_ sender: Any) {
        if cellModel.actionType == .actionCopy {
            cellModel.value.copyToPasteBoard()
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }else if cellModel.actionType == .actionQRCode {
            EXAlert.showPhotoBrowser(urls: [self.cellModel.valueIcon])
        }else if cellModel.actionType == .actionContact {
            actionCallback?(.actionContact)
        }
    }
    
}
