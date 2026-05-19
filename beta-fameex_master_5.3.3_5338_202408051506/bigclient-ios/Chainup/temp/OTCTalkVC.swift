//
//  OTCTalkVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import EXKit

enum OTCTalkType {
    case user//user
    case service//Customer service
}

class OTCTalkVC: NavCustomVC,EXNavigationPresenter {
    
    //Ws Link
    lazy var  wsSharedInstance : XWebSocketManager = {
        let ws = XWebSocketManager()
        ws.key = "dealSharedInstance"
        ws.webSocketDelegate = self
        return ws
    }()
    
    var timer : Timer?
    
    var uid = ""//The other party's uid
    
    var type = OTCTalkType.user
    
    var id = "0"
    
    var vm = OTCTalkVM()
    
    var complainId = ""//Question ID
    
    var fromService:Bool = false

    var detailEntity = EXOTCOrderDetailModel() {
        didSet {
            if detailEntity.seller?.uid == UserInfoEntity.sharedInstance().uid{
                self.uid = detailEntity.buyer?.uid ?? ""
            }else{
                self.uid = detailEntity.seller?.uid ?? ""
            }
        }
    }
//    lazy var talkPromptView : OTCTalkPromptView = {
//        let view = OTCTalkPromptView()
//        view.extUseAutoLayout()
//        return view
//    }()
    
    lazy var talkDetailsView : OTCTalkDetailsView = {
        let view = OTCTalkDetailsView()
        view.extUseAutoLayout()
        return view
    }()
    
    func configNavi() {
        self.lastVC = true
        if self.type == .service {
            let switchBtn = UIButton.init(type: .custom)
            switchBtn.setTitle("noun_otc_merchant".localized(), for: .normal)
            switchBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            switchBtn.addTarget(self, action: #selector(rightItemAction), for: .touchUpInside)
            self.navCustomView.addSubview(switchBtn)
            switchBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalTo(navCustomView.popBtn)
            }
        }else {
            if fromService {
                let switchBtn = UIButton.init(type: .custom)
                switchBtn.setTitle("common_text_service".localized(), for: .normal)
                switchBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
                switchBtn.addTarget(self, action: #selector(rightItemAction), for: .touchUpInside)
                self.navCustomView.addSubview(switchBtn)
                switchBtn.snp.makeConstraints { (make) in
                    make.right.equalToSuperview().offset(-15)
                    make.centerY.equalTo(navCustomView.popBtn)
                }
            }
        }
    }
    
    @objc func rightItemAction(){
        if self.type == .service {
            let vc = OTCTalkVC()
            vc.type = .user
            vc.fromService = true
            vc.detailEntity = self.detailEntity
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            if fromService {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        contentView.addSubViews([talkDetailsView])
    
        talkDetailsView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        talkDetailsView.detailEntity = detailEntity
        talkDetailsView.type = self.type

        
        talkDetailsView.talkInputView.clickSendBtnBlock = {[weak self](str) in
            guard let mySelf = self else{return}
            mySelf.sendMessage(str, msgtype: "1")
        }
        
        talkDetailsView.talkInputView.clickImgBtnBlock = {[weak self]()in
            guard let mySelf = self else{return}
            mySelf.alerSheet()
        }
        
        if type == .service{
            getHistoryTalkRecord()
            timer = Timer.init(timeInterval: 60, repeats: true, block: {[weak self] (timer) in
                guard let mySelf = self else{return}
                mySelf.getHistoryTalkRecord()
            })
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        }else if type == .user{
            //Establishing a Link
            wsRequestData()
            getHistoryTalkRecord()
            talkDetailsView.talkInputView.imgBtn.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         IQKeyboardManager.shared.enable = true
    }
    
    //send message
    func sendMessage(_ str : String , msgtype : String){
        if type == .service{
            
            if str.count > 500{
                EXAlert.showFail(msg: "otc_more_500".localized())
                return
            }
            
            let entity = OTCServiceEntity()
            entity.ctime = "\(Date().timeIntervalSince1970)"
            entity.replayContent = str
            entity.contentType = msgtype
            entity.userType = "2"
            entity.setHeight()
//            talkDetailsView.serviceTableViewRowDatas.append(entity)
//            talkDetailsView.tableView.reloadData()
            if msgtype == "1"{
                talkDetailsView.talkInputView.textField.text = ""
            }
            self.replyCreate(entity)
        }else{
            if str.count > 300{
                EXAlert.showFail(msg: "otc_more_300".localized())
                return
            }
            let entity = OTCTalkEntity()
            entity.time = DateTools.strToTimeString("\(DateTools.getNowTimeInterval())")
            entity.content = str
            entity.to = uid
            entity.from = UserInfoEntity.sharedInstance().uid
            entity.setHeight()
//            talkDetailsView.tableViewRowDatas.append(entity)
//            talkDetailsView.tableView.reloadData()
            if msgtype == "1"{
                talkDetailsView.talkInputView.textField.text = ""
            }
            sendStr(str)
        }
    }
    
    //Additional questions
    func replyCreate(_ entity : OTCServiceEntity){
        let param = ["rqId" : complainId , "rqReplyContent" : entity.replayContent , "contentType" : entity.contentType]
        vm.replyCreate(param).asObservable().subscribe(onNext: {[weak self] (dict) in
            guard let mySelf = self else{return}
            mySelf.getHistoryTalkRecord()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }
    
    //Get history Chat log
    func getHistoryTalkRecord(){
        if type == .service{
            let param : [String : Any] = ["id":complainId]
            vm.getServiceHistoryRecord(param).asObservable().subscribe(onNext: {[weak self] (dict) in
                guard let mySelf = self else{return}
                if let data = dict["data"] as? [String : Any]{
                    if let reReplyList = data["rqReplyList"] as? [[String : Any]]{
                        var array : [OTCServiceEntity] = []
                        for dict in reReplyList{
                            let entity = OTCServiceEntity()
                            entity.setEntityWithDict(dict)
                            if entity.replayContent != ""{//Display content not empty
                                array.append(entity)
                            }
                        }
                        mySelf.talkDetailsView.serviceTableViewRowDatas = array
                        mySelf.talkDetailsView.tableView.reloadData()
                        if mySelf.talkDetailsView.serviceTableViewRowDatas.count > 0{
                            mySelf.talkDetailsView.tableView.scrollToRow(at: IndexPath.init(row: mySelf.talkDetailsView.serviceTableViewRowDatas.count - 1, section: 0), at: .bottom, animated: true)

                        }
                    }
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }else{
            let param : [String : Any] = ["fromId":UserInfoEntity.sharedInstance().uid , "toId" : uid , "orderId" : detailEntity.sequence , "uaTime" : DateTools.strToTimeString("\(DateTools.getNowTimeInterval())")]
            vm.getsUserHistoryRecord(param).asObservable().subscribe(onNext: { [weak self](dict) in
                guard let mySelf = self else{return}
                if let data = dict["data"] as? [[String : Any]]{
                    var array : [OTCTalkEntity] = []
                    for dict in data{
                        let entity = OTCTalkEntity()
                        entity.setUserTalkEntity(dict)
                        if entity.content != ""{//Display content not empty
                            array.append(entity)
                        }
                    }
                    mySelf.talkDetailsView.tableViewRowDatas = array
                    mySelf.talkDetailsView.tableView.reloadData()
                    if mySelf.talkDetailsView.tableViewRowDatas.count > 0{
                        mySelf.talkDetailsView.tableView.scrollToRow(at: IndexPath.init(row: mySelf.talkDetailsView.tableViewRowDatas.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
        }
    }
    
    
    
    override func setNavCustomV() {
        if type == .user{
            if detailEntity.seller?.uid == UserInfoEntity.sharedInstance().uid{
                self.setTitle(detailEntity.buyer?.otcNickName ?? "")
            }else{
                self.setTitle(detailEntity.seller?.otcNickName ?? "")
            }
        }else if type == .service{
            self.setTitle(LanguageTools.getString(key: "common_text_service"))
        }
        self.navtype = .listtitle
    }
    
    deinit {
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OTCTalkVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func alerSheet(){
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let alertAction2 = UIAlertAction.init(title: LanguageTools.getString(key: "noun_camera_takephoto"), style: UIAlertAction.Style.default, handler: {[weak self] (param) in
            guard let mySelf = self else{return}
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                picker.delegate = mySelf
                let sourche = UIImagePickerController.SourceType.camera
                picker.sourceType = sourche
                //                picker.allowsEditing = true
                mySelf.presentF(picker, animated: true, completion: nil)
            }else {
                EXCameraAlert.popAuthAlert()
            }
        })
        let alertAction1 = UIAlertAction.init(title: LanguageTools.getString(key: "noun_camera_takeAlbum"), style: UIAlertAction.Style.default, handler: {[weak self](param) in
            guard let mySelf = self else{return}
            if #available(iOS 14, *) {
                
                EXImagePHPicker.shared.selectImageFromAlbumSuccess { (image) in
                    mySelf.uploadImage(image: image)
                }
                
            } else {
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
                    let picker = UIImagePickerController()
                    picker.delegate = mySelf
                    let sourche = UIImagePickerController.SourceType.savedPhotosAlbum
                    picker.sourceType = sourche
                    //                picker.allowsEditing = true
                    mySelf.presentF(picker, animated: true, completion: nil)
                }else {
                    EXCameraAlert.popAuthAlert(album: true)
                }
            }

        })
        let alertAction3 = UIAlertAction.init(title: LanguageTools.getString(key: "common_text_btnCancel"), style: UIAlertAction.Style.cancel, handler: { (param) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        alertController.addAction(alertAction3)
        self.presentF(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else {
            EXAlert.showFail(msg: "otc_get_photo_error".localized())
            return }
        uploadImage(image: img)
    }
    
    func uploadImage(image:UIImage) {
        //Compress photos taken by iPhone directly
        self.dismiss(animated: true) {
            let data = image.compressImage()
            let param : [String : Any] = ["imageData" : data.base64EncodedString()]
            UploadFileData.sharedInstance.uploadImg(param).subscribe(onNext: {[weak self] (dict) in
                guard let mySelf = self else{return}
                guard let data = dict["data"] as? [String : Any] else{return}
                guard let filename = data["filename"] as? String else{
                    EXAlert.showFail(msg: "otc_picture_fail".localized())
                    return
                }
                guard let base_image_url = data["base_image_url"] as? String else{
                    EXAlert.showFail(msg: "otc_picture_fail".localized())
                    return
                }
                mySelf.sendMessage(base_image_url + filename, msgtype: "2")
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//Ws Chat
extension OTCTalkVC : DSWebSocketDelegate{
    
    //Establishing a Link
    func wsRequestData(){
//        wss://stagingws2.chaindown.com/otc-chat/chatServer/
//        wsSharedInstance.connectSever(NetDefine.wss_host_url)
        let base64 = strToBase64(UserInfoEntity.sharedInstance().uid + uid)
//        let url = NetDefine.wss_host_url2 + base64
        print("url = \(EXNetworkDoctor.sharedManager.getTalkWs())")
        let url = EXNetworkDoctor.sharedManager.getTalkWs() + base64
        wsSharedInstance.connectSever(url)
    }
    
    func strToBase64(_ text : String) -> String{
        let data = text.data(using: String.Encoding.utf8)
        let base64Str = data?.base64EncodedString()
        if let s = base64Str{
            return s
        }
        return "0"
    }
    
    //break link
    func disconnectws(){
        wsSharedInstance.disconnect()
    }
    
    func websocketDidConnect(socket: XWebSocketManager) {
//        print("Did Connect WS。= \(socket.url)")
    }
    
    func websocketDidReceiveMessage(socket: XWebSocketManager, text: String) {
        let dict = dealContent(text)
//        print("dict = > \(dict)")
        if let message = dict["message"] as? [String : Any]{
            let entity = OTCTalkEntity()
            entity.setEntityWithDict(dict)
            if entity.content != ""{
                talkDetailsView.tableViewRowDatas.append(entity)
                talkDetailsView.tableView.reloadData()
            }
            
            if let from = message["from"] as? String, from == UserInfoEntity.sharedInstance().uid{
                if let chatId = dict["chatId"] as? String , talkDetailsView.tableViewRowDatas.count > 0{
                    talkDetailsView.tableViewRowDatas.last?.chatId = chatId
                }
            }
        }
        if self.talkDetailsView.tableViewRowDatas.count > 0{
            self.talkDetailsView.tableView.scrollToRow(at: IndexPath.init(row: self.talkDetailsView.tableViewRowDatas.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    //send data
    func sendStr(_ str : String){
        var chatId = ""
        if let lastChatId = talkDetailsView.tableViewRowDatas.last?.chatId{
            chatId = lastChatId
        }
        let jsonStr = JSONSerialization.jsonDataFromDictToString(["type" : "message" ,
                                                                  "chatId" : chatId,
                                                                  "message" :
                                                                    ["from" : UserInfoEntity.sharedInstance().uid ,
                                                                     "to" : uid ,
                                                                     "content" : str ,
                                                                     "time" : "\(Double(Date().timeIntervalSince1970 * 1000))"  ,
                                                                     "orderId" : detailEntity.sequence]])
//        print("jsonStr = \(jsonStr)")
        wsSharedInstance.sendBrandStr(string: jsonStr)
        
    }
    
    //Parsing content as a JSON string
    func dealContent(_ contentName : String) -> [String : AnyObject]{
        if let data = contentName.data(using: String.Encoding.utf8){
            do{
                let dic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                return dic as! [String : AnyObject]
            }catch let _ {
//                NSLog("\(error)")
            }
        }
        return ["" : "" as AnyObject]
    }
    
    
}


