//
//  EXAboutTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAboutTC: UITableViewCell {

    lazy var copyImgV : UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.contentMode = .scaleAspectFit
        v.image = EXKitBundle.image(named: "trade_icon_compared")
        return v
    }()

    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(16), textColor: .Ex.text1)
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var infoLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(14), textColor: .Ex.text2)
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    lazy var rightView: EXStackView = {
        let v = EXStackView()
        v.axis = .horizontal
        v.separatorConfiguration = nil
        v.spacing = 4
        v.alignment = .center
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell(isRemoveSelectedBackgroundView: true)
        contentView.addSubViews([nameLabel,rightView])
        rightView.addArrangedSubviews([infoLabel, copyImgV])
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        rightView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(nameLabel.snp.right).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.filter { $0.state == .ended }.subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            self.clickCopyBtn()
        }).disposed(by: disposeBag)
        rightView.addGestureRecognizer(tap)
    }
    
    func setCell(_ entity : EXAboutEntity){
        nameLabel.text = entity.title
        infoLabel.text = entity.content
        copyImgV.isHidden = !entity.showCopy
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
    
    @objc func clickCopyBtn(){
        if infoLabel.text?.count ?? 0 > 0{
            UIPasteboard.general.string = infoLabel.text
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }

    static func getMaxLengthWidth() -> CGFloat {
        let str = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        let maxw = self.getTextWidth(string: str, width: Device_W, font: UIFont.ThemeFont.SecondaryRegular, lineH: 0)
        return maxw + 2
    }
    
    
    static func getTextWidth(string:String,width: CGFloat = Device_W, font: UIFont, lineH: CGFloat = 0) -> CGFloat {

         let paraph = NSMutableParagraphStyle()
         paraph.lineSpacing = lineH
         //样式属性集合
        let attributes = [NSAttributedString.Key.font:font,
                          NSAttributedString.Key.paragraphStyle: paraph]
         let rect = string.boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.width
     }
    
}
