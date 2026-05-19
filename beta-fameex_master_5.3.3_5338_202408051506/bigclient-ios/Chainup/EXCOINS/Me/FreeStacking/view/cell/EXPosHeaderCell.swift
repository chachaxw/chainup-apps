//
//  EXPosHeaderCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosHeaderCell: UITableViewCell {

    var cellType = ""
    var positionEnity:EXPosDetailPostionEnity?
    var protocolEnity:EXPosDetailProtocolEnity?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    func setCellData(enity:EXPosDetailPostionEnity, header:[String:String]) {
        self.setCellConfig(config: header)
        self.cellType = "postion"
        self.positionEnity = enity
    }
    func setCellData(enity:EXPosDetailProtocolEnity,header:[String:String])  {
        self.setCellConfig(config: header)
        self.cellType = "protocol"
        self.protocolEnity = enity
    }
    
    func setCellConfig(config:[String:String])  {
        
        self.title.text = config["title"]
        if config["actionName"] != nil {
            
            actionButton.isHidden = false
        }else {
            actionButton.isHidden = true
        }
        
    }
    
    override var frame:CGRect{
        didSet {
            
            var newFrame = frame
            
            newFrame.origin.y += 10
            newFrame.size.height -= 10
            super.frame = newFrame
            
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.actionButton.setImage(UIImage.themeImageNamed(imageName: "exchange_order"), for: .normal)
        self.actionButton.setTitle("pos_string_all".localized(), for: .normal)
        self.actionButton.addTarget(self, action:#selector(didClickAll) , for: .touchUpInside)
    }
    @objc func didClickAll() {
        let vc = EXPosIncomeVC.instanceFromStoryboard(name: "FreeStacking")
        if self.cellType == "postion" {
            vc.dataSouce = self.positionEnity?.userGainList ?? []
            
        }else{
            vc.dataSouce = self.protocolEnity?.userGainList ?? []
            
        }
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
