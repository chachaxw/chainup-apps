//
//  EXInvitationPosterView.swift
//  Chainup
//
//  Created by chainup on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

let EXInvitationPosterDetailViewRatioWidth = 163.5
let EXInvitationPosterDetailViewRatioHeight = 298.0
let EXInvitationPosterDetailViewRatio = EXInvitationPosterDetailViewRatioHeight / EXInvitationPosterDetailViewRatioWidth
let EXInvitationPosterDetailViewHeight = (Double(SCREEN_WIDTH) - 48.0) / 2.0 * EXInvitationPosterDetailViewRatio
class EXInvitationPosterView: UIView {
    
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(text: "invitation_share_poster".localized(), font: .Ex.medium(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var cancelButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueTextColor
        v.setTitle("common_text_btnCancel".localized(), for: .normal)
        v.setTitleColor(.Ex.text2, for: .normal)
        v.setEnlargeEdgeWithTop(6, left: 6, bottom: 6, right: 6)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        return v
    }()
    
    lazy var saveButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueColor
        v.setTitle("sl_str_save_image".localized(), for: .normal)
        return v
    }()
    
    lazy var posterContainerView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    
    
    
    var firstPosterView = EXInvitationPosterDetailView()
    var secondPosterView = EXInvitationPosterDetailView()
    
    var firstSelector = UIButton()
    var secondSelector = UIButton()
    var currentSelector = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func onCreate() {
        backgroundColor = .Ex.fill6
        
        let firstImageName = LanguageTools.isHan() ? "invitation_poster_first" : "invitation_poster_first_english"
        let secondImageName = LanguageTools.isHan() ? "invitation_poster_second" :"invitation_poster_second_english"
        
        firstPosterView = creatPosterDetailView(posterImage: UIImage(named: firstImageName)!)
        secondPosterView = creatPosterDetailView(posterImage: UIImage(named: secondImageName)!)
        
        firstSelector = creatSelector()
        secondSelector = creatSelector()
        
        ///
        addSubViews([contentView])
        contentView.addSubViews([titleLabel, cancelButton,
                                 posterContainerView,
                                 firstSelector, secondSelector,
                                 saveButton])
        posterContainerView.addSubViews([firstPosterView, secondPosterView])
        
        ///
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 8 + EXSafeAreaBottom, right: 16))
        }
        
        ///
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
        }
        
        posterContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        ///
        
        firstPosterView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalTo(EXInvitationPosterDetailViewHeight)
        }
        
        secondPosterView.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(firstPosterView.snp.trailing).offset(16)
            make.width.equalTo(firstPosterView)
            make.height.equalTo(firstPosterView)
        }
        
        ///
        secondSelector.snp.makeConstraints { (make) in
            make.centerX.equalTo(secondPosterView)
            make.top.equalTo(posterContainerView.snp.bottom).offset(8)
        }
        firstSelector.snp.makeConstraints { (make) in
            make.centerX.equalTo(firstPosterView)
            make.top.equalTo(secondSelector)
        }
        
        
        ///
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(firstSelector.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //
        clickChooseBtn(firstSelector)
    }
    
    
    func onBindViewModel()  {
        cancelButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
            EXAlert.dismiss()
        }).disposed(by: disposeBag)
        
        saveButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            
            let currentlyPoster = self.currentSelector == self.firstSelector ? self.firstPosterView : self.secondPosterView
            let screenShotView = EXInvitationPosterDetailView()
            screenShotView.updatePosterLayoutIfNeed(posterImage: currentlyPoster.posterImageView.image,
                                                    qrCodeImage: currentlyPoster.inviteCodeImageView.image,
                                                    account: currentlyPoster.userPhoneLabel.text,
                                                    tipNotes: currentlyPoster.tipLabel.text)
            screenShotView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH , height: SCREEN_WIDTH * 1.5)
            screenShotView.isHidden = true
            UIApplication.shared.keyWindow?.addSubview(screenShotView)
            screenShotView.snapShotArea(rect: screenShotView.frame) { (image) in
                screenShotView.removeFromSuperview()
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImg), nil)
            }
        }).disposed(by: disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    
    
    func creatPosterDetailView(posterImage:UIImage) -> EXInvitationPosterDetailView {
        
        let view = EXInvitationPosterDetailView()
        view.layer.cornerRadius = 6
        view.posterImageView.image = posterImage
        view.extSetShadowColor(UIColor.ThemeView.highlight, shadowOffset: CGSize(width: 0, height: 0), opacity: 0.08,shadowRadius:6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(posterDetailViewClick))
        
        view.addGestureRecognizer(tap)
        return view
    }
    
    @objc func posterDetailViewClick(gesture:UIGestureRecognizer) {
        
        let view = gesture.view
        if view == firstPosterView {
            clickChooseBtn(firstSelector)
        }
        if view == secondPosterView {
            clickChooseBtn(secondSelector)
        }
    }
    func creatSelector() -> UIButton {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetAddTarget(self, #selector(clickChooseBtn))
        
        btn.setImage(UIImage.themeImageNamed(imageName: "public_unselected_square"), for: UIControl.State.normal)
        let selectedImg = EXKitBundle.svgImage(named: "public_selected_square")
        btn.setImage(selectedImg, for: UIControl.State.selected)
        btn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        return btn
    }
    
    @objc func saveImg(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil{
            EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_saveImgFail"))
            return
        }
        EXAlert.dismissEnd(complete: {
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_saveImgSuccess"))
        },delay: 0)
    }
    
    @objc func clickChooseBtn(_ btn : UIButton){
        
        if btn != self.currentSelector {
            
            btn.isSelected = true
            self.currentSelector.isSelected = false
            self.currentSelector = btn
        }
    }
    
    func setPosterImageUrl(imageUrls:[URL?], inviteUrl: String?) {
        
        firstPosterView.updatePoster(inviteUrl: inviteUrl)
        secondPosterView.updatePoster(inviteUrl: inviteUrl)
        
        for (index,imageUrl) in imageUrls.enumerated() {
            
            if index == 0 {
                if imageUrl != nil {
                    
                    firstPosterView.posterImageView.yy_setImage(with: imageUrl)
                }
                
            }else if index == 1 {
                
                if imageUrl != nil {
                    
                    secondPosterView.posterImageView.yy_setImage(with: imageUrl)
                }
            }
        }
    }
}

