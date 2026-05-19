//
//  EXTransactionCell.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXTransactionCellType {
    case vertical//Vertical plate
    case horizontalbuy//Horizontal version buying
    case horizontalsell//Horizontal selling
}

class EXTransactionCell: UITableViewCell {
    
    var color: UIColor = .Ex.kLine.up1
    {
        didSet{
            self.setColor()
        }
    }
    
    var type = EXTransactionCellType.vertical

    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = .Ex.regular(12)
        return label
    }()
    
    lazy var volumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = .Ex.text1
        label.font = .Ex.regular(12)
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.isHidden = true
        view.backgroundColor = .Ex.fill5
        return view
    }()
    
    lazy var dotView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.isHidden = true
        view.layer.cornerRadius = 2
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell(.clear, selStyle: .default, isRemoveSelectedBackgroundView: true)
        
        contentView.addSubViews([backView,priceLabel,volumLabel,dotView,lineV])
        lineV.snp.makeConstraints { (make) in
            make.centerY.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXDepthEntity){
        priceLabel.text = entity.price
        volumLabel.text = entity.num
        reloadBackView(entity.depth)
        setLineV(true)
        self.color = entity.color
        dotView.backgroundColor = entity.color
        dotView.isHidden = !entity.showOrder
    }
    
    func setColor(){
        priceLabel.textColor = color
        dotView.backgroundColor = color
        backView.backgroundColor = color.withAlphaComponent(0.15)
    }
    
    func setLineV(_ hidden : Bool){
        lineV.isHidden = hidden
    }
    
    func reloadBackView(_ depth : CGFloat){
        switch type {
        case .horizontalbuy://Horizontal version buying
            backView.snp.remakeConstraints { (make) in
                make.right.bottom.top.equalToSuperview()
                make.width.equalTo(depth)
            }
            break
        case .horizontalsell://Horizontal selling
            backView.snp.remakeConstraints { (make) in
                make.left.bottom.top.equalToSuperview()
                make.width.equalTo(depth)
            }
            break
        case .vertical://Vertical plate
            backView.snp.remakeConstraints { (make) in
                make.right.bottom.top.equalToSuperview()
                make.width.equalTo(depth)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? .Ex.fill3 : .clear
    }

}

//Vertical depth
class EXTransactionVerticalCell : EXTransactionCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        volumLabel.textAlignment = .right
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
        dotView.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(2)
            make.width.height.equalTo(4)
            make.centerY.equalToSuperview()
        }
        
        volumLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(dotView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Horizontal version buying
class EXTransactionHorizontalbuyCell : EXTransactionCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        priceLabel.textAlignment = .right
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
        volumLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(contentView.snp.centerX)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
        
        dotView.snp.makeConstraints { (make) in
            make.right.equalTo(priceLabel.snp.left).offset(-2)
            make.width.height.equalTo(4)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Horizontal selling
class EXTransactionHorizontalsellCell : EXTransactionCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        volumLabel.textAlignment = .right
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
        volumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(contentView.snp.centerX)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
    
        dotView.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(2)
            make.width.height.equalTo(4)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum EXTransactionDepthHVType {
    case vertical//Vertical plate
    case horizontal//Horizontal plate
}

class EXTransactionDepthHeadV : UIView{
    
    var type = EXTransactionDepthHVType.horizontal
    {
        didSet{
            self.setConstraints()
        }
    }
    
    lazy var leftVolumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "charge_text_volume")
        label.textColor = .Ex.text3
        label.font = .Ex.regular(10)
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "contract_text_price")
        label.textColor = .Ex.text3
        label.font = .Ex.regular(10)
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var righeVolumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "charge_text_volume")
        label.textColor = .Ex.text3
        label.font = .Ex.regular(10)
        label.layoutIfNeeded()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([leftVolumLabel,priceLabel,righeVolumLabel])
        leftVolumLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(14)
        }
        righeVolumLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func setConstraints() {
        if self.type == .horizontal{
            leftVolumLabel.isHidden = false
            priceLabel.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalTo(14)
            }
        }else{
            leftVolumLabel.isHidden = true
            priceLabel.snp.remakeConstraints { (make) in
                make.centerY.left.equalToSuperview()
                make.height.equalTo(14)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

