//
//  EXJapanAccountCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/18.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXJapanAccountCell: EXHomeBaseCell {
    
    lazy var noLoginView : EXHomeBannerAssetNoLoginView = {
        let view = EXHomeBannerAssetNoLoginView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var loginView : EXHomeBannerAssetLoginView = {
        let view = EXHomeBannerAssetLoginView()
        view.extUseAutoLayout()
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([noLoginView,loginView])
        noLoginView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loginView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //Click on the login button
    @objc func clickLoginBtn(){
        BusinessTools.modalLoginVC()
    }
    
    func setView(_ totalAccountBlance : String){
        noLoginView.isHidden = XUserDefault.getToken() != nil
        loginView.isHidden = XUserDefault.getToken() == nil
        loginView.setView(totalAccountBlance)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

