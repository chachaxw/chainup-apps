//
//  EXAddressListView.swift
//  Chainup
//
//  Created by cwd on 2023/11/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import YYText

typealias SelectAddressCallBack = (AddressItem) -> ()
class EXAddressListView: EXCustomBaseView {
    var selectAddressCallBack: SelectAddressCallBack?
    var addressList:[AddressItem]? {
        didSet{
            
            if let list = addressList,list.isEmpty == false{
                for address in addressList!{
                    configListCell(item: address)
                }
                let toatal = getViewHeight()
                self.snp.makeConstraints { make in
                    make.height.equalTo(toatal)
                }
            }else{
                self.stackView.isHidden = true
                self.emptyView.isHidden = false
                self.snp.updateConstraints { make in
                    make.height.equalTo(440)
                }
            }
        }
    }
    
    override func setSubView() {
        self.backgroundColor = .Ex.fill6
        self.addSubview(titleLabel)
        self.addSubview(cancelBtn)
        self.addSubview(scrollView)
        self.addSubview(emptyView)
        scrollView.addSubview(stackView)
        scrollView.backgroundColor = .clear
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
        }
        cancelBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Device_W - 16 * 2)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft,.topRight], radius: 12)
    }
    
    lazy var emptyView: EXScrollViewEmptyView = {
        let v = EXScrollViewEmptyView()
        v.isHidden = true
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"select_address".localized(), font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        return label
    }()
    
  
    lazy var cancelBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.titleLabel?.font = UIFont.Ex.regular(14)
        btn.setTitleColor(UIColor.Ex.text2, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("common_text_btnCancel".localized(), for: .normal)
        return btn
    }()
    
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = false
        v.showsVerticalScrollIndicator = false
        return v
    }()
   
    lazy var stackView: EXStackView = {
        let stackView = EXStackView()
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.separatorConfiguration = nil
        return stackView
    }()
    
    @objc func clickBtn(){
        EXAlert.dismiss()
    }
    
    func getViewHeight() -> CGFloat{
        var height: CGFloat = 51 + TABBAR_BOTTOM //header and footer
        let contentHeight = calculateTotalHeight(stackView: stackView)
        height += contentHeight
        
        let maxHeight = Device_H * 0.7
        let minHeight: CGFloat = 150
        if height > maxHeight {
            height = maxHeight
        }
        if height < minHeight {
            height = minHeight
        }
        return height + 10 + 5
        
    }
    
    func calculateTotalHeight(stackView: UIStackView) -> CGFloat {
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        var totalHeight: CGFloat = 0.0
        
        for subview in stackView.arrangedSubviews {
//            print("subview.frame.height = \(subview.frame.height)")
            totalHeight += subview.frame.height
        }
        
        let spacing = stackView.spacing
        let numberOfGaps = max(stackView.arrangedSubviews.count - 1, 0)
        totalHeight += spacing * CGFloat(numberOfGaps)
//        print("totalHeight = \(totalHeight)")
        return totalHeight
    }
}

extension EXAddressListView{
    func configListCell(item: AddressItem) {
        let card = EXCardView()
        card.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.addArrangedSubview(card)
        let label1 = YYLabel()
        label1.numberOfLines = 0
        label1.preferredMaxLayoutWidth = Device_W - 64
        label1.font = .Ex.medium(12)
        label1.textColor = .Ex.text1
        label1.text = item.label
        label1.attributedText = label1.ex_NSAttributedString()
        label1.isUserInteractionEnabled = false
        let attributedText = label1.ex_NSAttributedString()?.ex_mutableCopy()
        
        if item.trustType == "1" {
            attributedText?.append(NSAttributedString.yy_attachmentString(withContent: CALayer(), contentMode: .center, attachmentSize: CGSize(width: 5, height: 5), alignTo: label1.font, alignment: .center))
            let tagView = EXInsetLabel(text: "common_text_already_trust".localized(), font: .Ex.regular(10), textColor: UIColor.white, alignment: .center)
                tagView.edgeInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
                tagView.backgroundColor = UIColor.Ex.main1
                tagView.corneradius = 2
                tagView.frame = CGRect(origin: .zero, size: tagView.intrinsicContentSize)
                attributedText?.append(NSAttributedString.yy_attachmentString(withContent: tagView, contentMode: .center, attachmentSize: tagView.intrinsicContentSize, alignTo: label1.font, alignment: .center))
            
        }
        label1.attributedText = attributedText?.ex_lineSpacing(5)
        let label2 = UILabel(text: item.address, font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        label2.numberOfLines = 0
        card.contentView.addArrangedSubviews([label1,label2])
        card.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.resetAllSubView()
            card.isSelected = !card.isSelected
            self.selectAddressCallBack?(item)
        }).disposed(by: disposeBag)
        
        self.stackView.addArrangedSubview(card)
    }
    
    
    func resetAllSubView(){
        for itemView in self.stackView.arrangedSubviews{
            if let card = itemView as? EXCardView{
                card.isSelected = false
            }
            
        }
    }
}


// YYText when kit in remove
public extension YYLabel {
    @objc func ex_NSAttributedString() -> NSAttributedString? {
        return attributedText ?? text?.ex_toNSAttributedString(font: font, textColor: textColor)//.ex_alignment(textAlignment)
    }
}

class EXScrollViewEmptyView: EXCustomBaseView{
    override func setSubView() {
        self.addSubViews([cotainer])
        cotainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(EXScrollViewContainerView.height)
            make.center.equalToSuperview()
        }
    }
    
    lazy var cotainer: EXScrollViewContainerView = {
        let v = EXScrollViewContainerView()
        return v
    }()
    
}

class EXScrollViewContainerView: EXCustomBaseView{
    
    static let height = 60 + 5 + 18
    override func setSubView() {
        self.addSubViews([img,titleLabel])
        img.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    lazy var img : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage.svgImage(named: "public_nocontentyet")
        return img
    }()
    
    lazy var titleLabel: UILabel = {
        var text = EXUIDatasource.shared.common_tip_nodata
        let label = UILabel(text:text, font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
}
