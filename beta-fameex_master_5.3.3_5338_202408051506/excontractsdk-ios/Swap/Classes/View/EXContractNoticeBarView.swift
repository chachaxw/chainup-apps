//
//  EXContractNoticeBarView.swift
//  Swap
//
//  Created by cwd on 2023/6/28.
//

import UIKit
import EXKit
public class EXContractNoticeBarView: EXCOCustomBaseView {
    
    private static let leftRight:CGFloat = 16
    private static let topBottom:CGFloat = 12
    private static let imageWH:CGFloat = 16
    private static let closeBtnWH:CGFloat = 16
    public var closeBlock: EXComVoidBlock?
    var viewHeight: CGFloat = 0
    
    public var notice: EXContractNotice? {
        didSet{
            guard notice != nil else{
                return
            }
            
            if let content = notice?.content {
                let titleMaxWidth = Device_W - EXContractNoticeBarView.leftRight * 2 - EXContractNoticeBarView.imageWH - 8 - EXContractNoticeBarView.closeBtnWH - 12
                var height = content.getLabelHeight(withText: content, font: UIFont.Ex.regular(12), width: titleMaxWidth,numberOfLines: 4,lineHeight: 18)
                var mutileLine = height > 18 ? true : false //多行需要偏移 English: Multiple lines need to be offset
                if mutileLine {
                    let att = content.attributedText(withText: content, font: UIFont.Ex.regular(12),textColor: UIColor.Ex.text1,lineHeight: 18,isNeedOffset: mutileLine)
                    tipLabel.attributedText = att
                    self.offetImage()
                }else{
                    tipLabel.text = content
                }
            }
            viewHeight = EXContractNoticeBarView.getViewHeight(content: notice?.content ?? "")
        }
    }

   class func getViewHeight(content: String) -> CGFloat {
        let titleMaxWidth = Device_W - EXContractNoticeBarView.leftRight * 2 - EXContractNoticeBarView.imageWH - 8 - EXContractNoticeBarView.closeBtnWH - 12
       var height = content.getLabelHeight(withText: content, font: UIFont.Ex.regular(12), width: titleMaxWidth,numberOfLines: 4,lineHeight: 18)
        if height < EXContractNoticeBarView.imageWH {
            height = EXContractNoticeBarView.imageWH
        }
        height += EXContractNoticeBarView.topBottom * 2
        return height
    }
    
    public override func setSubView() {
        configSubView()
    }
    
    func configSubView(){
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickJump))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.Ex.warning2
        self.addSubview(imageIV)
        self.addSubview(tipLabel)
        self.addSubview(closeBtn)
        imageIV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(EXContractNoticeBarView.leftRight)
            make.width.height.equalTo(EXContractNoticeBarView.imageWH)
            make.top.equalToSuperview().offset(EXContractNoticeBarView.topBottom)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(imageIV.snp.right).offset(8)
            make.top.equalToSuperview().offset(EXContractNoticeBarView.topBottom)
            make.bottom.equalToSuperview().offset(-EXContractNoticeBarView.topBottom)
        }
        closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-EXContractNoticeBarView.leftRight)
            make.top.equalToSuperview().offset(EXContractNoticeBarView.topBottom)
            make.width.height.equalTo(EXContractNoticeBarView.closeBtnWH)
            make.left.equalTo(tipLabel.snp.right).offset(12)
        }
    }
    
    func offetImage(){
        let offset: CGFloat  = EXContractNoticeBarView.topBottom + 1
        imageIV.snp_updateConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
        closeBtn.snp_updateConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
    }
    
    //MARK: action
    @objc func closebtn(){
        self.closeBlock?()
    }
    @objc func clickJump(){
        goToWeb()
    }
    
    //MARK: lazy
    lazy var imageIV : UIImageView = {
        let arrowImmg = UIImageView()
//        arrowImmg.image = EXKitBundle.image(named: "public_prompt")
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "personal_notice")
        return arrowImmg
    }()
    lazy var tipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 12, weight: .regular), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.left)
        label.numberOfLines = 4 //最大4行 English: Up to 4 rows
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
  
    
    //确认 English: confirm
    lazy var closeBtn: RepeatButton = {
        let btn = RepeatButton(type: .custom)
        btn.addTarget(self, action: #selector(closebtn), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "personal_qrcode_delete"), for: .normal)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "personal_qrcode_delete"), for: .highlighted)
        btn.setEnlargeEdgeWithTop(10, left: 20, bottom: 20, right: 20)
        return btn
    }()
}

extension EXContractNoticeBarView{
    
    func goToWeb(){
        let web = EXSWebVC()
        web.customTitle = ""
        let configUrl = self.notice?.url ?? ""
        if configUrl.count > 0 && configUrl.hasPrefix("http") {
            web.loadUrl(configUrl)
            self.yy_viewController?.navigationController?.pushViewController(web, animated: true)
        }
    }
    
}

