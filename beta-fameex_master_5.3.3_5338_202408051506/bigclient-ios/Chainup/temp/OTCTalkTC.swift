
//
//  OTCTalkTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class TalkBgView : UIView {
    
    var isMe:Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
//    override func draw(_ rect: CGRect) {
//        self.backgroundColor = UIColor.clear
//        var path:UIBezierPath?
//        if isMe {
//            path = UIBezierPath.init(roundedRect: rect,
//                                     byRoundingCorners: [.topLeft,.bottomLeft,.bottomRight],
//                                     cornerRadii: CGSize(width: 2, height: 2))
//        }else {
//            path = UIBezierPath.init(roundedRect: rect,
//                                     byRoundingCorners: [.topRight,.bottomLeft,.bottomLeft],
//                                     cornerRadii: CGSize(width: 2, height: 2))
//        }
//        path =  UIBezierPath.init(roundedRect: rect,
//                                  byRoundingCorners: [.allCorners],
//                                  cornerRadii: CGSize(width: 2, height: 2))
//        UIColor.ThemeNav.bg.setStroke()
//        path?.stroke()
//        UIColor.ThemeView.highlight.setFill()
//    }
}

class OTCTalkTC: UITableViewCell {
    
    var serviceEntity = OTCServiceEntity()

    lazy var headImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.corneradius = 15
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    lazy var contentLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 14)
        return label
    }()
    
    lazy var contentBackView : TalkBgView = {
        let imgV = TalkBgView()
        imgV.extUseAutoLayout()
        imgV.backgroundColor = UIColor.ThemeView.highlight
        imgV.layer.cornerRadius = 3
        imgV.layer.masksToBounds = true
        return imgV
    }()
    
    lazy var failBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isHidden = true
        btn.setImage(UIImage.init(named: "failBtn"), for: UIControl.State.normal)
        return btn
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickImgV))
        imgV.addGestureRecognizer(tap)
        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.ThemeNav.bg
        contentView.addSubViews([headImgV,contentBackView,contentLabel,failBtn,imgV])
    }
    
    func addConstraints(){
        
    }
    
    //user
    func setCell(_ entity : OTCTalkEntity,detailEntity:EXOTCOrderDetailModel){
        imgV.isHidden = true
        contentLabel.text = entity.content
    }
    
    //Off site
    func setCellWithOTC(_ entity : OTCServiceEntity , detailEntity:EXOTCOrderDetailModel){
        serviceEntity = entity
        contentLabel.isHidden = true
        imgV.isHidden = true
        contentBackView.isHidden = true
        if entity.contentType == "1"{
            contentLabel.isHidden = false
            contentBackView.isHidden = false
            contentLabel.text = entity.replayContent
        }else if entity.contentType == "2"{
            imgV.isHidden = false
            if let url = URL.init(string: entity.replayContent){
                imgV.yy_setImage(with: url, placeholder: UIImage.init(named: "imgSendBtn"), options: YYWebImageOptions.allowBackgroundTask) { (img, url, type, s, error) in
                }
            }
        }
//        timeLabel.text = entity.ctime
    }
    
    @objc func clickImgV(){
        let previewVC = ImagePreviewVC()
        previewVC.images = [self.serviceEntity.replayContent]
        previewVC.index = 0
        previewVC.copyType = "2"//Do not display save button
        self.yy_viewController?.navigationController?.pushViewController(previewVC, animated: true)
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

}

//My Chat
class OTCMyTalkTC : OTCTalkTC{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addConstraints()
        contentLabel.textColor = UIColor.ThemeLabel.white
        contentBackView.backgroundColor = UIColor.ThemeView.highlight
    }
    
    override func addConstraints() {
        headImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(30)
            make.top.equalToSuperview().offset(15)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.height.equalTo(0)
            make.top.equalTo(headImgV).offset(7)
            make.right.equalTo(headImgV.snp.left).offset(-20)
            make.left.greaterThanOrEqualTo(60)
        }
        contentBackView.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel).offset(-7)
            make.bottom.equalTo(contentLabel).offset(7)
            make.right.equalTo(contentLabel).offset(10)
            make.left.equalTo(contentLabel).offset(-10)
        }
        failBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackView)
            make.height.width.equalTo(22)
            make.right.equalTo(contentBackView.snp.left).offset(-8)
        }

        imgV.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.top.equalTo(headImgV)
            make.right.equalTo(headImgV.snp.left).offset(-9)
        }
    }
    
    //user
    override func setCell(_ entity: OTCTalkEntity, detailEntity: EXOTCOrderDetailModel) {
        super.setCell(entity,detailEntity:detailEntity)
        let buyerID = detailEntity.buyer?.uid ?? ""
        if buyerID == entity.from {
            headImgV.setImageWithUrl(path:detailEntity.buyer?.imageUrl ?? "", text:detailEntity.buyer?.otcNickName ?? "")
        }else {
            headImgV.setImageWithUrl(path:detailEntity.seller?.imageUrl ?? "", text:detailEntity.seller?.otcNickName ?? "")
        }
        let labelHeight = ceilf(Float(entity.cellHeight)) - Float(54)
        contentLabel.snp.updateConstraints { (make) in
            make.height.equalTo(labelHeight)
        }
    }
    
    //Off site
    override func setCellWithOTC(_ entity : OTCServiceEntity,detailEntity: EXOTCOrderDetailModel){
        super.setCellWithOTC(entity,detailEntity: detailEntity)
        //picture
        let userid = UserInfoEntity.sharedInstance().uid
        let buyerID = detailEntity.buyer?.uid ?? ""
        if buyerID == userid {
            headImgV.setImageWithUrl(path:detailEntity.buyer?.imageUrl ?? "", text:detailEntity.buyer?.otcNickName ?? "")
        }else {
            headImgV.setImageWithUrl(path:detailEntity.seller?.imageUrl ?? "", text:detailEntity.seller?.otcNickName ?? "")
        }
        
        if entity.contentType == "2"{
//            timeLabel.snp.remakeConstraints { (make) in
//                make.right.equalTo(imgV)
//                make.height.equalTo(13)
//                make.top.equalTo(imgV.snp.bottom).offset(5)
//            }
        }else if entity.contentType == "1"{//characters
            let labelHeight = ceilf(Float(entity.cellHeight)) - Float(54)
            contentLabel.snp.updateConstraints { (make) in
                make.height.equalTo(labelHeight)
            }
//            timeLabel.snp.remakeConstraints { (make) in
//                make.right.equalTo(contentBackView)
//                make.height.equalTo(13)
//                make.top.equalTo(contentBackView.snp.bottom).offset(5)
//            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Chat with others
class OTCOtherTalkTC : OTCTalkTC{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addConstraints()
        contentBackView.isMe = false
        contentLabel.textColor = UIColor.ThemeLabel.white
        contentBackView.backgroundColor = UIColor.ThemeLabel.colorMedium
//        contentBackView.image = UIImage.init(named: "othertalk")
//        let edg = UIEdgeInsets.init(top: 19, left: 20, bottom: 19, right: 20)
//        contentBackView.image = contentBackView.image?.resizableImage(withCapInsets: edg)
    }
    
    override func addConstraints() {
        headImgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.height.width.equalTo(30)
            make.top.equalToSuperview().offset(15)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.height.equalTo(0)
            make.top.equalTo(headImgV).offset(8)
            make.left.equalTo(headImgV.snp.right).offset(20)
            make.right.lessThanOrEqualTo(-60)
        }
        
        contentBackView.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel).offset(-7)
            make.bottom.equalTo(contentLabel).offset(7)
            make.right.equalTo(contentLabel).offset(10)
            make.left.equalTo(contentLabel).offset(-10)
        }
        
        failBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackView)
            make.height.width.equalTo(22)
            make.left.equalTo(contentBackView.snp.right).offset(8)
        }
//        timeLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(contentBackView).offset(5)
//            make.height.equalTo(13)
//            make.top.equalTo(contentBackView.snp.bottom).offset(5)
//        }
        imgV.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.top.equalTo(headImgV)
            make.left.equalTo(headImgV.snp.right).offset(9)
        }
    }
    
    
    override func setCell(_ entity: OTCTalkEntity, detailEntity: EXOTCOrderDetailModel) {
        super.setCell(entity,detailEntity:detailEntity)
        let labelHeight = ceilf(Float(entity.cellHeight)) - Float(54)
        contentLabel.snp.updateConstraints { (make) in
            make.height.equalTo(labelHeight)
        }
        let buyerID = detailEntity.buyer?.uid ?? ""
        if buyerID == entity.from {
            headImgV.setImageWithUrl(path:detailEntity.buyer?.imageUrl ?? "", text:detailEntity.buyer?.otcNickName ?? "")
        }else {
            headImgV.setImageWithUrl(path:detailEntity.seller?.imageUrl ?? "", text:detailEntity.seller?.otcNickName ?? "")
        }
    }
    
    //Off site
    override func setCellWithOTC(_ entity : OTCServiceEntity,  detailEntity: EXOTCOrderDetailModel){
        super.setCellWithOTC(entity,detailEntity: detailEntity)
//        let userid = UserInfoEntity.sharedInstance().uid
//        let buyerID = detailEntity.buyer?.uid ?? ""
//        if buyerID == userid {
//            headImgV.setImageWithUrl(path:detailEntity.buyer?.imageUrl ?? "", text:detailEntity.buyer?.otcNickName ?? "")
//        }else {
//            headImgV.setImageWithUrl(path:detailEntity.seller?.imageUrl ?? "", text:detailEntity.seller?.otcNickName ?? "")
//        }
        headImgV.setImageWithUrl(path:"", text:"common_text_service".localized())

        //picture
        if entity.contentType == "2"{
//            timeLabel.snp.remakeConstraints { (make) in
//                make.left.equalTo(imgV)
//                make.height.equalTo(13)
//                make.top.equalTo(imgV.snp.bottom).offset(5)
//            }
        }else if entity.contentType == "1"{//characters
            let labelHeight = ceilf(Float(entity.cellHeight)) - Float(54)
            contentLabel.snp.updateConstraints { (make) in
                make.height.equalTo(labelHeight)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


