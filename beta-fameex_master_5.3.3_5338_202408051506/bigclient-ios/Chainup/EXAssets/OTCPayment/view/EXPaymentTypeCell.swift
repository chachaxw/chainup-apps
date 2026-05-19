//
//  EXPaymentTypeCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXPaymentTypeCell: UITableViewCell {
    @IBOutlet var paymentIcon: UIImageView!
    @IBOutlet var paymentLabel: UILabel!
    @IBOutlet var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        arrow.image = EXKitBundle.image(named: "public_positions_arrow_right")
        arrow.contentMode = .scaleAspectFit
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updatePaymentinfo(_ paymentModel:OTCPaymentModel) {
        let url = paymentModel.icon
    
        paymentIcon.yy_setImage(with: URL.init(string: url), placeholder: nil)
        paymentLabel.text = paymentModel.title
    }
    
}
