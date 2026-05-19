//
//  EXBtoCrechargeV.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBtoCrechargeV: UIView, EXOldImagePickerDelegate {
    
    lazy var pickerController:EXOldImagePicker = {
        let pickC = EXOldImagePicker.init()
        pickC.delegate = self
        return pickC
    }()
    
    let uploader:EXImageUploader = EXImageUploader.init()
    
    var entity = B2CCoinMapItem()
    
    var model = EXBtoCrechargeModel()
    
    var bankModel = EXCompanyBankInfoModel()
    
    lazy var footView : BtoCAnnouncementsView = {
        let view = BtoCAnnouncementsView()
        view.isHidden = true
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()

    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBtoCrechargeTC.classForCoder()], ["EXBtoCrechargeTC"])
        tableView.estimatedSectionFooterHeight = 0.1
        return tableView
    }()
    
    lazy var confirmBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.setTitle("b2c_text_recharge".localized(), for: UIControl.State.normal)
        btn.extSetCornerRadius(1.5)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickConfirmBtn))
        btn.isEnabled = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([tableView,confirmBtn])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top).offset(-7)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
        }
        
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let mySelf = self else { return }
                mySelf.model.imgUrl = imgUrl
                mySelf.tableView.reloadData()
            }).disposed(by: self.disposeBag)
//        uploader.rx_img.skip(1)
//            .subscribe(onNext: { [weak self] img in
//                guard let mySelf = self else { return }
//                mySelf.tableView.reloadData()
//            }).disposed(by: self.disposeBag)
    }
    
    func getFiltBlance(){
        appApi.rx.request(.b2cBalance(symbol: entity.symbol))
            .MJObjectMap(EXB2CAccountListModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                if model.allCoinMap.count > 0{
                    self?.entity = model.allCoinMap[0]
                }
                if model.withdrawTip != ""{
                    self?.footView.isHidden = false
                    self?.footView.setView(model.depositTip)
                }else{
                    self?.footView.isHidden = true
                }
                self?.setData()
            }) { (error) in
                
            }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(){
        model.coinSymbol = entity.symbol
        model.depositMin = entity.depositMin
        tableView.reloadData()
    }
    
    //Click on the recharge button
    @objc func clickConfirmBtn(){
        
        if bankModel.isTransferVoucher == "1"{
            if model.imgUrl == ""{
                EXAlert.showFail(msg: "b2c_text_addTransferCredentials".localized())
                return
            }
        }
        
        if (entity.depositMin as NSString).isBig(model.amount){
            EXAlert.showFail(msg: "b2c_text_singleNoLessthan".localized() + entity.depositMin + " " + model.coinSymbol)
            return
        }
        
        let confirmV : EXBtoCrechargeConfirmV = {
            let view = EXBtoCrechargeConfirmV()
            view.extUseAutoLayout()
            view.clickBtnBlock = {[weak self] in
                self?.confirmChargeMoney()
            }
            return view
        }()
        
        confirmV.setView(model.amount + model.coinSymbol, payCredentials: model.imgUrl)
        self.yy_viewController?.view.addSubview(confirmV)
        confirmV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func getData(){
        getBankData()
        getFiltBlance()
    }
    
    func getBankData(){
        bankModel = EXCompanyBankInfoModel()
        appApi.rx.request(AppAPIEndPoint.getCompanyBankInfo(symbol: entity.symbol)).MJObjectMap(EXCompanyBankInfoModel.self).subscribe(onSuccess: {[weak self] (model) in
            self?.bankModel = model
            self?.setData()
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    //Confirm coin charging
    func confirmChargeMoney(){
        appApi.rx.request(AppAPIEndPoint.fiatDeposit(symbol: entity.symbol, transferVoucher: model.imgUrl, amount: model.amount)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXAlert.showSuccess(msg: "b2c_text_rechargeSuccess".localized())
            self?.yy_viewController?.navigationController?.popViewController(animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
}

extension EXBtoCrechargeV : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 486
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXBtoCrechargeTC") as! EXBtoCrechargeTC
        cell.setCell(model)
        cell.setChargeAccount(bankModel)
        cell.setWithEntity(entity)
        cell.clickBtoCCellBlock = {[weak self] in
            let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            searchVc.subsetCoinAccountType = .b2c
            searchVc.b2cOnEntityCallback = {[weak self] model in
                self?.entity = model
                self?.getData()
            }
            searchVc.sourceType = .sourceForDeposit
            searchVc.needPush = true
            self?.yy_viewController?.navigationController?.pushViewController(searchVc, animated: true)
        }
        cell.clickImgVBtnBlock = {[weak self] in
            self?.chooseImg()
        }
        cell.rechargeTextField.textfieldValueChangeBlock = {[weak self]str in
            self?.model.amount = str
            if str == ""{
                self?.confirmBtn.isEnabled = false
            }else{
                self?.confirmBtn.isEnabled = true
            }
        }
        cell.clickCheckBlock = {[weak self] in
            self?.model.imgUrl = ""
            self?.tableView.reloadData()
        }
        return cell
    }
    
}

extension EXBtoCrechargeV : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func chooseImg(){
        
        let arr : [String] = [LanguageTools.getString(key: "noun_camera_takephoto"),LanguageTools.getString(key: "noun_camera_takeAlbum")]
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.handlePhoto(idx)
        }
        sheet.configButtonTitles(buttons: arr)
        EXAlert.showSheet(sheetView: sheet)
        
    }
    
    func handlePhoto(_ sheetIdx : Int){
        if sheetIdx == 0 {
            pickerController.selectImageFromCameraSuccess({[weak self] (picker) in
                guard let `self` = self else {return}
                self.yy_viewController?.present(picker, animated: true, completion: nil)
            },Fail: {
                
            })
        }else if sheetIdx == 1 {
            if #available(iOS 14, *) {
                
                EXImagePHPicker.shared.selectImageFromAlbumSuccess { (image) in
                    self.uploadImage(image)
                }
                
            } else {
                
                pickerController.selectImageFromAlbumSuccess({[weak self] (picker) in
                    guard let `self` = self else {return}
                    self.yy_viewController?.present(picker, animated: true, completion: nil)
                },Fail: {
                    
                })
            }
        }
    }
}


extension EXBtoCrechargeV {
    
    func selectImageFinished(_ image: UIImage) {
        
        uploadImage(image)
    }
    
    func uploadImage(_ image: UIImage) {
        
        uploader.uploadImage(img: image , type : "2")
    }
}

