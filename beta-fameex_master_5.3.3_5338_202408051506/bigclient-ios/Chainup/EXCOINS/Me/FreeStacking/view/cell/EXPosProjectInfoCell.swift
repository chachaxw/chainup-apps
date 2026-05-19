//
//  EXPosProjectInfoCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXPosProjectInfoCell: UITableViewCell {

    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    var projectName:String = ""
    var projectInfo:String = ""
    func setCellData(enity:EXPosDetailPostionEnity) {
        
        if let url = URL(string: enity.logo){
            
            icon.yy_setImage(with: url, placeholder: nil)
        }
        name.text = enity.shortName;
        projectInfo = enity.info
        projectName = enity.name
       
        
    }
    func setCellData(enity:EXPosDetailProtocolEnity)  {
        
        if let url = URL(string: enity.logo){
            
            icon.yy_setImage(with: url, placeholder: nil)
        }
        name.text = enity.shortName;
        projectInfo = enity.info
        projectName = enity.name
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        detailButton.setTitle("pos_string_prodetail".localized(), for: .normal)
        arrowImg.image = EXKitBundle.image(named: "public_positions_arrow_right")
        arrowImg.contentMode = .scaleAspectFit
    }
    
    @IBAction func didClickButton(_ sender: Any) {
        
        let desc = EXPosPorjectDescVC()
        desc.descInfo = projectInfo
        desc.projectShortName = self.projectName
        self.yy_viewController?.navigationController?.pushViewController(desc, animated: true)
        
        
    }
  
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
