//
//  EXContractAssetRecordCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
public class EXContractAssetRecordHeaderCell: UITableViewCell {

    lazy var mainView:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.secondLabel.isHidden = true
        v.firstLabel.font = UIFont.ThemeFont.MinimumRegular
        v.thirdLabel.font = UIFont.ThemeFont.MinimumRegular
        v.backgroundColor = UIColor.ThemeView.bg
        return v
    }()
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        view.isHidden = true
        return view
    }()
    func setCell(left:String, right:String) {
        mainView.setData(left: left, middle: "", right: right)
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        contentView.exs_addSubViews([mainView,horLineView])
        mainView.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

