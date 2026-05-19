//
//  EXAddressListCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAddressListCell: UITableViewCell {
    @IBOutlet var verticalView: EXAddressVerticalView!
    var selectedAddress = ""

    @IBOutlet weak var addressIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        addressIcon.image = UIImage.themeImageNamed(imageName: "assets_withdrawaladdress")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCellItem(_ addressItem:AddressItem) {
        let coinAddress = addressItem.address
        let remark = addressItem.label
        if let _ = coinAddress.range(of: "_") {
            let addressAry = coinAddress.components(separatedBy: "_")
            if addressAry.count == 2 {
                verticalView.addressLabel.text = addressAry[0]
                verticalView.tagLabel.text = addressAry[1]
            }
        }else {
            verticalView.hideTagLabel()
            verticalView.addressLabel.text = coinAddress
        }
        verticalView.remarkLabel.text = remark
        
        verticalView.trustView.isHidden = !addressItem.isTrust()
    }
    
    func showAddressCheckMark(_ isShow:Bool) {
        verticalView.checkIcon.isHidden = !isShow
    }
    
}
