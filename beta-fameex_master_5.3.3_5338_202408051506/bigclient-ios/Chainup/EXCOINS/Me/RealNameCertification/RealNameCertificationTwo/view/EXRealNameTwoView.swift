//
//  EXRealNameTwoView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXRealNameTwoView: UIView , EXOldImagePickerDelegate {
    
    lazy var pickerController:EXOldImagePicker = {
        let pickC = EXOldImagePicker.init()
        pickC.delegate = self
        return pickC
    }()
    let uploader:EXImageUploader = EXImageUploader.init()
    
    var realNameTwoEntity = EXRealNameTwoEntity()
    
    var entity = UploadFileTokenEntity()
    
    var realBtnEntity = EXRealBtnEntity()
    
    var tableViewNameDatas : [String] = [LanguageTools.getString(key: "common_action_uploadFrontView"),LanguageTools.getString(key: "common_action_uploadBackView"),LanguageTools.getString(key: "personal_Center_text24")]
    
    var tableViewRowDatas : [EXRealBtnEntity] = []
    
    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style:UITableView.Style.grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXRealNameTwoTC.classForCoder()], ["EXRealNameTwoTC"])
        tableView.estimatedSectionFooterHeight = 150
        return tableView
    }()
    
    lazy var tableFooterView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
//        btn.isEnabled = false
        btn.extSetCornerRadius(4)
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        btn.isEnabled = false
        btn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.clickNextBtn()
            }).disposed(by: self.disposeBag)
        return btn
    }()
    
    lazy var warningLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.Ex.text3
        label.text = LanguageTools.getString(key: "common_tip_uploadImgRequire") + ":"
        return label
    }()
    
    lazy var warningInfoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableFooterView.addSubViews([warningLabel,warningInfoLabel,nextBtn])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        warningLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        warningInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(warningLabel.snp.bottom).offset(5)
            make.left.right.equalTo(warningLabel)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(warningInfoLabel.snp_bottom).offset(31)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
        }
        setDatas()
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let mySelf = self else { return }
                mySelf.realBtnEntity.imgUrl = imgUrl
                mySelf.tableView.reloadData()
                mySelf.tableView.isUserInteractionEnabled = true
                DispatchQueue.main.async { [weak self] in
                    self?.btnEnble()
//                    XHUDManager.sharedInstance.hideLoading(delay: 0.1)
                    self?.hideLoading1()
                    
                }
            }).disposed(by: self.disposeBag)
        uploader.rx_img.skip(1)
            .subscribe(onNext: { [weak self] img in
                guard let mySelf = self else { return }
                mySelf.realBtnEntity.image = img
                mySelf.tableView.reloadData()
            }).disposed(by: self.disposeBag)
        
    }
    
    func setDatas(){
        for str in tableViewNameDatas{
            let entity = EXRealBtnEntity()
            entity.title = str
            switch str{
            case LanguageTools.getString(key: "common_action_uploadFrontView"):
                entity.placeholderImg = "personal_positiveupload"
            case LanguageTools.getString(key: "common_action_uploadBackView"):
                entity.placeholderImg = "personal_uploadreverse"
            case LanguageTools.getString(key: "personal_Center_text24"):
                entity.placeholderImg = "personal_handhelddocuments"
            default:
                break
            }
            tableViewRowDatas.append(entity)
        }
        setWarningInfoLabel()
        tableView.reloadData()
    }
    
    func setWarningInfoLabel(){
        var att =  "personal_Center_text23".localized()
        let configText = EXRealNameModelManager.sharedInstance.model.language 
        if configText.isEmpty == false{
            att = att + "\n4." + configText
        }
        let paraph = NSMutableParagraphStyle()
        //Set row spacing to 6
        paraph.lineSpacing = 6
        //Style Attribute Collection
        let attributeText = NSMutableAttributedString().add(string: att, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular,NSAttributedString.Key.foregroundColor :  UIColor.Ex.text3 ,NSAttributedString.Key.paragraphStyle : paraph])
        warningInfoLabel.attributedText = attributeText
    }
    func btnEnble(){
        for entity in tableViewRowDatas{
            if entity.imgUrl == "" || entity.imgUrl == "0"{
                nextBtn.isEnabled = false
                return
            }
        }
        nextBtn.isEnabled = true
    }
    //Click on real name Next
    @objc func clickNextBtn(){
        for entity in tableViewRowDatas{
            if entity.imgUrl == "" || entity.imgUrl == "0"{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_pleaseUpload"))
                return
            }
        }
        appApi.rx.request(AppAPIEndPoint.authRealname(countryCode: realNameTwoEntity.countryCode, certificateType: realNameTwoEntity.certificateType, userName: realNameTwoEntity.userName, certificateNumber: realNameTwoEntity.certificateNumber, firstPhoto: tableViewRowDatas[0].imgUrl, secondPhoto: tableViewRowDatas[1].imgUrl, thirdPhoto: tableViewRowDatas[2].imgUrl, familyName: realNameTwoEntity.familyName, name: realNameTwoEntity.name,numberCode: realNameTwoEntity.numberCode)).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            UserInfoEntity.sharedInstance().authLevel = "0"
            UserInfoEntity.setTmpDict()
            self?.yy_viewController?.navigationController?.popViewController(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name.init("RealNameTwoNotification"), object: nil)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXRealNameTwoView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXRealNameTwoTC = tableView.dequeueReusableCell(withIdentifier: "EXRealNameTwoTC") as! EXRealNameTwoTC
        cell.setCell(entity)
        cell.tag = 1000 + indexPath.row
        cell.clickBtnBlock = {[weak self](tag) in
            guard let mySelf = self else{return}
            mySelf.realBtnEntity = mySelf.tableViewRowDatas[tag]
            mySelf.chooseImg()
        }
        cell.reUploadBtnBlock = { [weak self] (tag) in
            guard let mySelf = self else{return}
            mySelf.realBtnEntity = mySelf.tableViewRowDatas[tag]
            mySelf.chooseImg()
           // mySelf.uploadImage(image:mySelf.realBtnEntity.image!)
        }
        return cell
    }
    
}

extension EXRealNameTwoView : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func chooseImg(){
        
        let arr : [String] = [LanguageTools.getString(key: "noun_camera_takephoto"),LanguageTools.getString(key: "noun_camera_takeAlbum")]
        let sheet = EXOldActionSheetView()
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
                picker.modalPresentationStyle = .fullScreen
                self.yy_viewController?.present(picker, animated: true, completion: nil)
                },Fail: {
                    
            })
            
        }else if sheetIdx == 1 {
            
            if #available(iOS 14, *) {
                
                EXImagePHPicker.shared.selectImageFromAlbumSuccess { (image) in
                   
                    DispatchQueue.main.async {
                        print("EXImagePHPicker ---2" )
                        self.realBtnEntity.image = image
                        self.tableView.reloadData()
                    }
                    self.uploadImage(image: image)
                }
                
            } else {
                
                pickerController.selectImageFromAlbumSuccess({[weak self] (picker) in
                    guard let `self` = self else {return}
                    picker.modalPresentationStyle = .fullScreen
                    self.yy_viewController?.present(picker, animated: true, completion: nil)
                },Fail: {
                    
                })
            }
        }
    }
}

extension EXRealNameTwoView {
    
    func selectImageFinished(_ image: UIImage) {
        DispatchQueue.main.async {
            print("EXImagePHPicker ---2" )
            self.realBtnEntity.image = image
            self.tableView.reloadData()
        }
        uploadImage(image: image)
    }
    
    func uploadImage(image:UIImage){
        
        DispatchQueue.main.async { [weak self] in //During uploading, it is prohibited to click, otherwise the data will be garbled. If the first image is not uploaded yet, clicking on the second image will change the realBtnEntity to the second image, and the URL of the first image will be incorrect
            self?.tableView.isUserInteractionEnabled = false
//            XHUDManager.sharedInstance.loading()
            self?.showLoading1()
        }
        
       
        uploader.uploadImage(img: image , type : "1" , imgUrlType : "half")
        
    }
}



