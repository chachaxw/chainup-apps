//
//  EXPosPorjectDescVC.swift
//  Chainup
//
//  Created by lcus on 2023/10/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosPorjectDescVC: NavCustomVC {

    var descInfo : String = ""
    var projectShortName = ""
    let name:UILabel = {
        let lable = UILabel()
        lable.text = "pos_string_projectName".localized()
        lable.font = UIFont.ThemeFont.BodyRegular
        lable.textColor = UIColor.ThemeLabel.colorMedium
        return lable
    }()
    
    let nameDetail:UILabel = {
        let lable = UILabel()
        lable.font = UIFont.ThemeFont.BodyRegular
        lable.textColor = UIColor.ThemeLabel.colorLite
        
        return lable
    }()
    
    let desc:UILabel = {
        
        let lable = UILabel()
        lable.text = "market_text_coinInfo".localized()
        lable.font = UIFont.ThemeFont.BodyRegular
        lable.textColor = UIColor.ThemeLabel.colorMedium
        return lable
    }()
    
    let detail:UILabel = {
        
        let lable = UILabel()
        lable.font = UIFont.ThemeFont.BodyRegular
        lable.textColor = UIColor.ThemeLabel.colorLite
        lable.numberOfLines = 0
        
        return lable
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navtype = .listtitle
        self.navCustomView.middleTitle.text = "pos_string_prodetail".localized()
        // Do any additional setup after loading the view.
        self.view.addSubViews([name,nameDetail,desc,detail])
        self.view.backgroundColor = UIColor.ThemeView.bg
        self.detail.text = self.descInfo
        self.nameDetail.text = self.projectShortName
        name.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(NAV_SCREEN_HEIGHT+15)
            make.left.equalTo(self.view).offset(15)
            
        }
        nameDetail.snp.makeConstraints { (make) in
            
            make.right.equalTo(self.view).offset(-15)
            make.centerY.equalTo(name)
        }
        
        desc.snp.makeConstraints { (make) in
            
            make.left.equalTo(self.view).offset(15)
            make.top.equalTo(name.snp.bottom).offset(15)
        }
        
        detail.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(15)
            make.top.equalTo(desc.snp.bottom).offset(20)
            make.right.equalTo(self.view).offset(-15)
        }
        
        
//
    }
    


}
