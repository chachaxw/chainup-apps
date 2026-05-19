//
//  EXOTCOrderAppealVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXOTCOrderAppealVc: BaseVC,StoryBoardLoadable,NavigationPlugin,EXNavigationPresenter {

    @IBOutlet var baseScroll: UIScrollView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var orderInfoCard: EXOTCOrderInfoCard!
    @IBOutlet var reasonView: EXAppealReasonView!
    @IBOutlet var photoView: EXAppealPhotoView!
    @IBOutlet var reasonHeight: NSLayoutConstraint!
    @IBOutlet var photoHeight: NSLayoutConstraint!
    @IBOutlet var btnFooter: EXSingleBtnFooter!
    
    let pickerController:EXOldImagePicker = EXOldImagePicker.init()
    let uploader:EXImageUploader = EXImageUploader.init()

    var orderDetailModel :EXOTCOrderDetailModel = EXOTCOrderDetailModel() {
        didSet {
            sequence = orderDetailModel.sequence
        }
    }
    var orderVm :EXOTCVm = EXOTCVm()
    
    var reasonDesc :String = ""
    var reasonType :OTCAppealReasonType = .none
    let otcAppealType:String = "7"
    var sequence = ""
    var selectedImg:UIImage?
    var imgUrl:String?
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: baseScroll, presenter: self)
        return nav
    }()
    
    func handleNavigation(){
        self.navigation.setTitle(title: "otc_text_appeal".localized())
        self.navigation.isLastNavigationStyle = true 
        self.navigation.setdefaultType(type: .list)
    }
    
    func configAppealSubviews() {
        photoHeight.constant = photoView.getHeight()
        self.handleReasonHeight(height:reasonView.getHeight(expand: false))
        reasonView.expandCallback = {[weak self] expand in
            guard let `self` = self else {return}
            self.handleReasonHeight(height: self.reasonView.getHeight(expand: expand))
        }
        reasonView.textHeightCallback = {[weak self] textheight in
            guard let `self` = self else {return}
            self.handleReasonHeight(height:self.reasonView.getHeight(expand: true, textHeight: textheight))
        }
        
        reasonView.reasonDescCallback = {[weak self] text,idx in
            self?.updateTypeAndDesc(idx, text)
            
        }
        reasonView.customReasonCallback = {[weak self] reason in
            guard let `self` = self else {return}
            self.reasonDesc = reason
        }
        
        photoView.photoImg.tapBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.handleUploadAction()
            }).disposed(by: self.disposeBag)
    }
    
    func updateTypeAndDesc(_ typeIdx:Int,_ desc:String) {
        self.reasonDesc = desc
        if let isBuyer = self.orderDetailModel.isBuyer() {
            if isBuyer {
                if typeIdx == 0 {
                    reasonType = OTCAppealReasonType.sellerWontDeliver
                }else if typeIdx == 1 {
                    reasonType = OTCAppealReasonType.payMoreError
                }else {
                    self.reasonDesc = ""
                    reasonType = OTCAppealReasonType.otherReason
                }
            }else {
                if typeIdx == 0 {
                    reasonType = OTCAppealReasonType.buyerNoPay
                }else if typeIdx == 1 {
                    reasonType = OTCAppealReasonType.payeeLessError
                }else {
                    self.reasonDesc = ""
                    reasonType = OTCAppealReasonType.otherReason
                }
            }
        }
        
    }
    
    func handleUploadAction() {
        let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: ["noun_camera_takephoto".localized(),"noun_camera_takeAlbum".localized()])
        sheet.actionIdxCallback = {[weak self] tag in
            self?.handlePhoto(tag)
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func handlePhoto(_ sheetIdx:Int) {
        pickerController.delegate = self
        if sheetIdx == 0 {
            pickerController.selectImageFromCameraSuccess({[weak self] (picker) in
                guard let `self` = self else {return}
                self.presentF(picker, animated: true, completion: nil)
                },Fail: {
                    
            })
        }else if sheetIdx == 1 {
            pickerController.selectImageFromAlbumSuccess({[weak self] (picker) in
                guard let `self` = self else {return}
                self.presentF(picker, animated: true, completion: nil)
                },Fail: {
                    
            })
        }
    }
    
    
    func handleReasonHeight(height:CGFloat) {
        reasonHeight.constant = height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        baseScroll.adjustBehaviorDisable()
        self.configAppealSubviews()
        self.handleNavigation()
        self.baseScroll.alwaysBounceVertical = true
        self.btnFooter.footerBtn.setTitle("kyc_action_submit".localized(), for: .normal)
        btnFooter.footerBtn.addTarget(self, action: #selector(handleCommit), for: .touchUpInside)
//        btnFooter.footerBtn.rx.tap.asObservable()
//            .throttle(.seconds(1), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] _ in
//                guard let `self` = self else { return }
//                self.handleCommit()
//            }).disposed(by: self.disposeBag)
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let `self` = self else { return }
                self.imgUrl = imgUrl
                if let currentimg = self.selectedImg {
                    self.photoView.setImg(icon: currentimg)
                }
                self.photoView.setImgUrl(iconUrl: imgUrl)
        }).disposed(by: self.disposeBag)
        
        self.handleAppealInfo()
    }
    
    func handleAppealInfo() {
        if let isBuyer = self.orderDetailModel.isBuyer() {
            var reasons:[String] = []
            if isBuyer {
                reasons = ["appeal_action_reasonNotReceiveCoin".localized(),"appeal_action_reasonOverPaid".localized(),"appeal_action_reasonOther".localized()]
            }else {
                reasons = ["appeal_action_reasonNotPaid".localized(),"appeal_action_reasonLessPaid".localized(),"appeal_action_reasonOther".localized()]

            }
            let model = OTCOrderInfoModel.getModel(title: "otc_text_orderId".localized(), value: orderDetailModel.sequence)
            
            var name = ""
            if let isBuyer = orderDetailModel.isBuyer() {
                if isBuyer {
                    name = orderDetailModel.seller?.otcNickName ?? ""
                }else {
                    name = orderDetailModel.buyer?.otcNickName ?? ""
                }
            }
            let model2 = OTCOrderInfoModel.getModel(title: "otcSafeAlert_action_nickname".localized(), value:name)
            let model3 = OTCOrderInfoModel.getModel(title: "appeal_text_amount".localized() + "(\(orderDetailModel.paycoin))", value: orderDetailModel.totalPrice.formatCurrencyMoney(orderDetailModel.paycoin,format:.fiatFormat))
            orderInfoCard.updateInfos(models: [model,model2,model3],title: "appeal_text_orderInfo".localized())
            reasonView.bindReason(reasons:reasons,title: "appeal_text_reason".localized())
            reasonView.setDefaultReason(0)
            orderInfoCard.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(EXOTCOrderInfoCard.fullHeightWithModels(models: [model,model2,model3]))
            }
        }
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
    func canCommitAppeal() -> Bool {
        var canCommit = true
        var errorMsg = ""
        if reasonType == .none {
            errorMsg = reasonType.rawValue.localized()
            canCommit = false
        }
        if reasonDesc.isEmpty {
            errorMsg = "otc_tip_pleaseInputAppealReason".localized()
            canCommit = false
        }
        
        if !errorMsg.isEmpty {
            EXAlert.showFail(msg:errorMsg)
        }
        return canCommit

    }
    
    @objc func handleCommit() {
        if canCommitAppeal() {
            let alert = EXNormalAlert()
            alert.configAlert(title: "common_text_tip".localized(), message: "otc_tip_appealconfirm".localized())
            alert.alertCallback = {[weak self] tag in
                if tag == 0 {
                    self?.confirmCommit()
                }
            }
            EXAlert.showAlert(alertView: alert)
        }
    }
    
    func confirmCommit() {
        appApi.rx.request(.createProblem(rqType: otcAppealType, rqDescribe: reasonDesc, imageDataStr: self.imgUrl, rqUnreleased: nil, rqUnpaid: nil))
            .MJObjectMap(EXOTCAppealModel.self)
            .subscribe{[weak self] event in
                guard let myself = self else {return}
                switch event {
                case .success(let model):
                    myself.updateOrderStatus(model.complainId)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func updateOrderStatus(_ complainId:String) {
        otcApi.rx
            .request(.otcComplainOrder(sequence: self.sequence, complainId: complainId))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                guard let myself = self else {return}
                switch event {
                case .success(_):
                    myself.handleSuccess()
                    break
                case .failure(_):
                    
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func handleSuccess() {
        EXAlert.showSuccess(msg: "otc_tip_appealSuccess".localized())
        self.navigationController?.popViewController(animated: true)
    }
}

extension EXOTCOrderAppealVc : EXOldImagePickerDelegate {
    
    func selectImageFinished(_ image: UIImage) {
        self.selectedImg = image
        uploader.uploadImage(img: image)
    }
    
}
