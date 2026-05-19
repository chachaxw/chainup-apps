//
//  EXHomeFootView.swift
//  Chainup
//
//  Created by lcus on 2023/10/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHomeFootView: UIView {
    
    var title :UILabel = {
        let lable = UILabel()
        lable.textColor = UIColor.ThemeLabel.colorLite
        lable.font = UIFont.ThemeFont.HeadBold
        return lable
    }()
    var detail:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0;
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.preferredMaxLayoutWidth = SCREEN_WIDTH-30
        return label
    }()
    
    var faqbutton:UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        button.setTitle("pos_sting_faq".localized(), for: .normal)
        button.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        button.addTarget(self, action: #selector(didClikButton), for: .touchUpInside)
        return button;
    }()
    
    var contract:UILabel = {
       let lable = UILabel()
        lable.font = UIFont.ThemeFont.SecondaryRegular
        lable.textColor = UIColor.ThemeLabel.colorMedium
        return lable;
        
    }()
    
    var sepView:UIView = {
        let view = UIView ()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
        
    }()
    
    var sepLine:UIView = {
        let view = UIView ()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    var faqURL:String = ""
    
    func setFootData(enitey:EXPosHomeTypesEntity){
        
        self.title.text = enitey.footTitle
        self.detail.text = enitey.detail
        self.contract.text = enitey.contact
        self.faqURL = enitey.faqUrl
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(title)
        self.addSubview(detail)
        self.addSubview(faqbutton)
        self.addSubview(contract)
        self.addSubview(sepView)
        self.addSubview(sepLine)
        
        sepView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(10)
        }
        
        title.snp.makeConstraints { (make) in
            
            make.left.top.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(30)
        }
        
        sepLine.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(title.snp.bottom).offset(14)
            make.height.equalTo(1)
        }
        
        
        detail.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(title.snp.bottom).offset(35)
            make.right.equalTo(self).offset(-15).priorityHigh()
        }
        faqbutton.snp.makeConstraints { (make) in
            
            make.left.equalTo(self).offset(15)
            make.top.equalTo(detail.snp.bottom).offset(20);
            make.width.lessThanOrEqualTo(100)
            make.height.equalTo(20)
        }
        
        contract.snp.makeConstraints { (make) in
            
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.top.equalTo(faqbutton.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.bottom.equalTo(self.snp.bottom).offset(-20).priorityLow()
        }
        
        
    }
   
    @objc func didClikButton()  {
        
        let webView = WebVC()
        
        
        webView.loadUrl(self.faqURL)
        
        self.yy_viewController?.navigationController?.pushViewController(webView, animated: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
