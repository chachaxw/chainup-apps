//
//  EXOneByTwoCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/18.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXOneByTwoCell: EXHomeBaseCell {
    
    lazy var oneView : EXHomeFuncOneView = {
        let view = EXHomeFuncOneView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(4)
        view.isHidden = true
        return view
    }()
    
    lazy var twoView : EXHomeFuncOtherView = {
        let view = EXHomeFuncOtherView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(4)
        view.isHidden = true
        return view
    }()
    
    lazy var threeView : EXHomeFuncOtherView = {
        let view = EXHomeFuncOtherView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(4)
        view.isHidden = true
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
    
    //Old logic, take it over first
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([oneView,twoView,threeView])
        self.backgroundColor = UIColor.ThemeNav.bg
        contentView.backgroundColor = UIColor.ThemeNav.bg
        
        oneView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.height.equalTo(102)
            make.width.equalTo(redproportion * 230)
        }
        twoView.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.height.equalTo(46)
            make.left.equalTo(oneView.snp.right).offset(10)
        }
        threeView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(twoView.snp.bottom).offset(10)
            make.height.equalTo(46)
            make.left.equalTo(oneView.snp.right).offset(10)
        }
    }
    
    //Set view
    func setView(_ arr : [CmsAppDataItem]){
        if arr.count > 0{
            oneView.isHidden = false
            oneView.bindModel(arr[0])
        }
        if arr.count > 1{
            twoView.isHidden = false
            twoView.bindModel(arr[1])
        }
        if arr.count > 2{
            threeView.isHidden = false
            threeView.bindModel(arr[2])
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

