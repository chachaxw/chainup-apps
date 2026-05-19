//

//  Chainup
//
//  Created by chainup on 2023/9/2.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXSHorizontalThreeLabelTableViewCell: UITableViewCell {
    //高度30 English: Height 30
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var mainView:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.backgroundColor = UIColor.ThemeView.bgIcon
        v.config(titleColor: UIColor.Ex.text1, font: UIFont.Ex.fontWith(size: 14, weight: .bold))
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
//        contentView.exs_addSubViews([mainView,horLineView])
//        mainView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        horLineView.snp.makeConstraints { (make) in
//            make.height.equalTo(0.5)
//            make.left.right.bottom.equalToSuperview()
//        }
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.exs_addSubViews([mainView])
        contentView.backgroundColor = UIColor.ThemeView.bgIcon
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
            make.top.bottom.equalToSuperview()
        }
        /// 正常高度30 高度变化也无所谓 English: /Normal height 30, height changes don't matter
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.height.equalTo(18)
            make.leading.trailing.equalToSuperview()
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

class EXSwapTransactionDetailHeaderCell: UITableViewCell {
    //高度35 English: Height 35
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
     
    var mainView:EXShorizontalThreeLabelView = {
       
        let v = EXShorizontalThreeLabelView(user: .header)
        v.backgroundColor = UIColor.ThemeView.bgIcon
        return v
    }()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.exs_addSubViews([mainView])
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bgIcon
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
            make.top.bottom.equalToSuperview()
        }
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.bottom.leading.trailing.equalToSuperview()
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


class EXSwapFeelistCell: UITableViewCell {
    //高度35 English: Height 35
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
     
    var mainView:EXShorizontalThreeLabelView = {
       
        let v = EXShorizontalThreeLabelView(user: .header)
        v.backgroundColor = UIColor.ThemeView.bgIcon
        return v
    }()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.exs_addSubViews([mainView])
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bgIcon
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
            make.top.bottom.equalToSuperview()
        }
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.bottom.leading.trailing.equalToSuperview()
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

