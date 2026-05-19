//
//  EXHomeRankNewCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXHomeRankNewCell: EXHomeBaseCell {
    var itemModel = EXHomeTicker()

    lazy var nameContainer : UIStackView  = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        return view
    }()
    
    //name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    //Bottom line
    lazy var tagBg : UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var tagView :EXTagView = {
        let view = EXTagView.commonTagView()
        return view
    }()
    
    //price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadMedium
        label.textColor = UIColor.ThemeLabel.colorLite
        label.textAlignment =  .right
        return label
    }()
    
    //Fluctuation range
    lazy var amplitudeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNBoldFont(size: 14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.extSetCornerRadius(2)
        return label
    }()

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
        if (highlighted) {
            self.contentView.backgroundColor = UIColor.ThemeView.card2
        }else{
            self.contentView.backgroundColor = UIColor.ThemeView.card1
        }
    }
    
    //Original fixed width
    class func nameLabelWidth() -> CGFloat {
        let width = (SCREEN_WIDTH - MARGIN_LEFT_DOUBLE - 16) * 0.3
//        let width = (SCREEN_WIDTH*0.405333).rounded(.down) - MARGIN_LEFT
        return width.rounded(.down)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        let width = EXHomeRankNewCell.nameLabelWidth()
        contentView.addSubViews([nameContainer,priceLabel,amplitudeLabel])
        nameContainer.addArrangedSubview(nameLabel)
        nameContainer.addArrangedSubview(tagBg)
        tagBg.addSubview(tagView)

        nameContainer.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(MARGIN_LEFT)
            make.width.equalTo(width)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
        }
        
        tagView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(12)
            make.width.equalTo(12)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.height.equalTo(19)
            make.centerY.equalTo(nameContainer)
            make.right.equalTo(amplitudeLabel.snp.left).offset(-28)
            make.left.equalTo(nameLabel.snp.right).offset(8)
        }

        amplitudeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-MARGIN_LEFT)
            make.height.equalTo(32)
            make.width.equalTo(72)
            make.centerY.equalToSuperview()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindCell(_ item:EXHomeTicker) {
        self.itemModel = item
        nameLabel.setCoinMap(item.showName,leftFont:UIFont().themeHNBoldFont(size: 16),handleKern: 2)
        amplitudeLabel.backgroundColor = item.backColor
        amplitudeLabel.text = item.rose
        priceLabel.text = item.close

        if item.marketTag.isEmpty {
            tagBg.isHidden = true
        }else {
            tagBg.isHidden = false
            tagView.text = item.marketTag
            tagView.titleResizeSize()
        }
    }
}

