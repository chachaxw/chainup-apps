//
//  EXAppMailVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXAppMailVC: NavCustomVC , EXFilterViewDelegate , EXEmptyDataSetable{
    
    var filterData = [String:String]()

    var typeList : [EXMessageTypesEntity] = []
    
    var type = "0"
    
    let dropView = EXFilterView()
    
    lazy var mainView : EXAppMailView = {
        let view = EXAppMailView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        dropView.defaultExpand = true
        getData()
        self.exEmptyDataSet(mainView.tableView)
    }
    
    func getData(){
        appApi.rx.request(AppAPIEndPoint.getAppMail(messageType: type, pageSize: "100", page: "1"))
            .MJObjectMap(EXAppMailAllEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.typeList = entity.typeList
                mySelf.mainView.tableViewRowDatas = entity.userMessageList
                for e in mySelf.mainView.tableViewRowDatas{
                    for dentity in mySelf.typeList{
                        if e.messageType == dentity.tid{
                            e.messageTitle = dentity.title
                            break
                        }
                    }
                }
                self?.mainView.tableView.reloadData()
                self?.messageUpdateStatus()
            }) { (error) in
        }.disposed(by: disposeBag)
    }
    
    //Clear information
    func messageUpdateStatus(){
//        var unreadMessage = self.mainView.tableViewRowDatas.filter { item in
//            return item.status == "2"
//        }
//        if unreadMessage.count == 0 {
//            return
//        }
//
//        var ids = unreadMessage.reduce("", { $0 + "," + $1.id })
//
//        print("ids= >\(ids)")
//        ids.remove(at: ids.startIndex)
//        print("ids= >\(ids)")
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.messageUpdateStatus(id: "0")).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: { (model) in
        }, onFailure: nil).disposed(by: disposeBag)
    }
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "personal_text_message"))
        self.xscrollView = mainView.tableView
        let btn = UIButton()
        btn.setImage(UIImage.themeImageNamed(imageName: "public_filter"), for: .normal)
        btn.extSetAddTarget(self, #selector(clickBtn))
      
        self.navCustomView.addSubview(btn)
//        let btn2 = UIButton()
//        btn2.setImage(UIImage.themeImageNamed(imageName: "public_filter"), for: UIControl.State.normal)
//        btn2.extSetAddTarget(self, #selector(clickBtn2))
//        self.navCustomView.addSubview(btn2)
        btn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.width.equalTo(14)
            make.height.equalTo(17)
            make.right.equalToSuperview().offset(-18)
           
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            btn.setEnlargeEdgeWithTop(10, left: 50, bottom: 10, right: 20)
        }
//        btn2.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self.navCustomView.popBtn)
//            make.width.equalTo(14)
//            make.height.equalTo(17)
//            make.right.equalToSuperview().offset(-40)
//        }
        self.lastVC = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropView.dismissFilter()
        
    }
    
    //Click to filter
    func clickBtn(){
        if dropView.isShow == true{
            return
        }
        dropView.delegate = self
        dropView.show(inView: self.view, position: CGPoint(x: 0, y: NAV_SCREEN_HEIGHT))
        dropView.filterParams = self.filterData
        dropView.reloadData()
    }
    
    func clickBtn2(){
        let alert = EXCommonAlert()
        let message = "personal_Center_text25".localized()
        alert.configAlert(tipImage: nil,
                          title: message,
                          message: nil,
                          cancelBtnTitle:LanguageTools.getString(key: "common_text_btnCancel"),
                          sureBtnTitle:  LanguageTools.getString(key: "common_text_btnConfirm"),
                          btnLayoutStyle: .horizontal, alertCallBack: { type in
            if type == .sure{
                
            }
        })
        EXAlert.showAlert(alertView: alert)
    }
    func filterConfirm(params: [String : String]) {
        self.filterData = params
        if let type = params["type"]{
            self.type = type
            getData()
        }
    }
    
    func filterDataSource() -> [EXFilterDataModel] {
        var titlearr : [String] = []
        var tidarr : [String] = []
        for entity in self.typeList{
            titlearr.append(entity.title)
            tidarr.append(entity.tid)
        }
        let items = EXFilterItem.getItem(titles: titlearr, valueKeys: tidarr)
        //fold
        let foldModel
            = EXFilterDataModel.getFoldModel(key: "type", title: "filter_fold_messageType".localized(), contents: items)
        return [foldModel]
    }
    
}

