//
//  EXInvitationRecordTableViewCell.swift
//  Chainup
//
//  Created by chainup on 2023/9/2.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXCOhorizontalThreeLabelTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    lazy var mainView:EXCOhorizontalThreeLabelView = {
       
        let v = EXCOhorizontalThreeLabelView(user: .cell)
        
        return v
    }()
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        contentView.addSubViews([mainView,horLineView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHighlightLabel(left:Bool, middle:Bool, right:Bool) {
        mainView.setHighlight(highlight: (left,middle,right))
    }
    
    func setCell(left:String, middle:String, right:String) {
        mainView.setData(left: left, middle: middle, right: right)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

