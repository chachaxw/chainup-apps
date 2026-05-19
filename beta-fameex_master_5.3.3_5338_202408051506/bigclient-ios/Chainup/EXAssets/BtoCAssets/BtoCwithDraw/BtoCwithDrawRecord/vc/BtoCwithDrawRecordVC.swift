//
//  BtoCwithDrawRecordVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class BtoCwithDrawRecordVC: NavCustomVC ,EXEmptyDataSetable , EXFilterViewDelegate{
        
    var type = "0"//0 recharge 1 withdrawal
    {
        didSet{
            mainView.type = self.type
        }
    }
    
    var symbol = ""//currency
    {
        didSet{
            mainView.symbol = self.symbol
        }
    }
    
    let dropView = EXFilterView()
    
    var filterData : [String : String] = [:]
    
    lazy var mainView : EXBtoCwithDrawRecordV = {
        let mainView = EXBtoCwithDrawRecordV()
        mainView.extUseAutoLayout()
        return mainView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.exEmptyDataSet(mainView.tableView)
        mainView.getData()
        setView()
    }
    
    func setView(){
        switch type {
        case "0":
            self.setTitle(symbol + "b2c_text_rechargeRecord".localized())
            self.mainView.headView.setRecordLabel("b2c_text_rechargeNum".localized())
        case "1":
            self.setTitle(symbol + "b2c_text_withdrawRecord".localized())
            self.mainView.headView.setRecordLabel("b2c_text_withdrawNum".localized())
        default:
            break
        }
    }
    
    override func setNavCustomV() {
        
        self.lastVC = true
        self.navtype = .list
        self.xscrollView = self.mainView.tableView
        
        let screenBtn = UIButton()
        screenBtn.extUseAutoLayout()
        screenBtn.setImage(UIImage.themeImageNamed(imageName: "public_filter"), for: .normal)
        self.navCustomView.addSubview(screenBtn)
        screenBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(17)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.right.equalToSuperview().offset(-15)
        }
        screenBtn.addTarget(self, action: #selector(clickScreenBtn), for: .touchUpInside)
    }
    
    @objc func clickScreenBtn(){
        if dropView.isShow == true{
            return
        }
        dropView.delegate = self
        dropView.show(inView: self.view, position: CGPoint(x: 0, y: NAV_SCREEN_HEIGHT))
        dropView.filterParams = self.filterData
        dropView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropView.dismissFilter()
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

extension BtoCwithDrawRecordVC{
    func filterDataSource() -> [EXFilterDataModel] {
        var models : [EXFilterDataModel] = []
        
        //date
        let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "startTime", endDateKey: "endTime", title: "charge_text_date".localized())
        models.append(dateModel)
        
        return models
    }
    
    func filterConfirm(params: [String : String]) {
        for key in params.keys{
            mainView.filterData[key] = params[key]
        }
        mainView.page = 1
        mainView.getData()
    }
    
    func cellModelForceSelect(_ idx: Int) -> Bool {
        return (idx == 1) ? true :false
    }
    
    func forceParamNotFill(_ emptyData: [String : String]) {
        print(emptyData)
        if let coin = emptyData["coin"]  , coin == ""{
            EXAlert.showFail(msg: LanguageTools.getString(key: "filter_input_coinsymbol"))
        }
    }
}

