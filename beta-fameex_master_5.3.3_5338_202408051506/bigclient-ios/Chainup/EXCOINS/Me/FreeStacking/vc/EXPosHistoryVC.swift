//
//  EXPostHistoryViC.swift
//  Chainup
//
//  Created by lcus on 2023/9/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//History

import UIKit
import RxSwift
import EXKit
class EXPosHistoryVC: UIViewController,StoryBoardLoadable,NavigationPlugin,EXEmptyDataSetable{

    
    let disposBag = DisposeBag()
    @IBOutlet weak var top: NSLayoutConstraint!
    
    var postInfoType:String = "3"
    let pageSize:Int = 20
    var currentPage = 1
    var toutulCount:Int = 0
    var isLoadMore:Bool = false
    var dataSouceProtocol:[EXPosHistoryItem] = []
    var dataSoucePostion:[EXPosPositionHistoryItem] = []
    var currentTypeModel:EXPosHistoryBase?
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        return nav
    }()
    
    func largeTitleValueChanged(height: CGFloat) {
        self.top.constant = height
    }
    var filterData = [String:String]()

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = .singleLine
        self.tableView.register(cellType: EXHistoryCell.self)
        self.tableView.rowHeight = 155
        self.tableView.separatorColor = UIColor.ThemeNav.bg
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.tableView.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self] in
            guard let self else { return }
            self.currentPage = 1
            self.refresh()
             
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let self else{return}
            self.currentPage += 1
            self.loadMore()
            
        })
        self.tableView.mj_footer.isHidden = true
        
        self.configNavigation()
        
        loadData(baseCoin: "", strTime: "", entTime: "")
        // Do any additional setup after loading the view.
        self.exEmptyDataSet(self.tableView)
    }
    
    func refresh() {
        self.loadData(baseCoin: self.filterData["baseCoin"] ?? "", strTime: self.filterData["strTime"] ?? "", entTime: self.filterData["entTime"] ?? "")
        
    }
    
    func loadMore()   {
        self.loadData(baseCoin: self.filterData["baseCoin"] ?? "", strTime: self.filterData["strTime"] ?? "", entTime: self.filterData["entTime"] ?? "")
        
//        if(currentPage * pageSize) < toutulCount {
//           currentPage += 1
//           isLoadMore = true
//            
//         self.loadData(baseCoin: self.filterData["baseCoin"] ?? "", strTime: self.filterData["strTime"] ?? "", entTime: self.filterData["entTime"] ?? "")
//            
//        }else{
//            
//            self.tableView.mj_footer.endRefreshingWithNoMoreData()
//        }
//        
        
    }
    
   
    func loadData(baseCoin:String,strTime:String,entTime:String)  {
        
         let enityType = postInfoType == "3" ? EXPosHistoryEnity.self : EXPosHistoryPositonEnity.self
        
        appApi.rx.request(.freeStaking_myPos(page: String(currentPage), pageSize:String(pageSize), projectType: self.postInfoType, baseCoin: baseCoin, strTime: strTime, entTime: entTime)).MJObjectMap(enityType).subscribe(onSuccess: { [weak self] enity in
            guard let self else { return }
            self.tableView.mj_footer.isHidden = false
            if self.postInfoType == "3" {
                let history = enity as! EXPosHistoryEnity
                self.currentTypeModel = history
                if history.posList.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                if self.currentPage == 1 {
                    self.dataSouceProtocol = history.posList
                } else {
                    self.dataSouceProtocol.append(contentsOf: history.posList)
                }
            }else {
                let postiTion = enity as! EXPosHistoryPositonEnity
                self.currentTypeModel = postiTion
                if postiTion.posList.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                if self.currentPage == 1 {
                    self.dataSoucePostion = postiTion.posList
                } else {
                    self.dataSoucePostion.append(contentsOf: postiTion.posList)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, onDisposed: { [weak self] in
            guard let self else { return }
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing()
            }
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
            }
        }).disposed(by: disposBag)
    }
    
    
    func filterRequest(){
        
        currentPage = 1
        self.tableView.mj_footer.resetNoMoreData()
        if let type = self.filterData["projectType"]{
            
            self.postInfoType = type
            self.loadData(baseCoin: self.filterData["baseCoin"] ?? "", strTime: self.filterData["strTime"] ?? "", entTime: self.filterData["entTime"] ?? "")
        }
       
      
    }
    
    
    func configNavigation() {
        
        self.navigation.setTitle(title: EXPosDetailServer.sharedInstance.tipMine)
        self.navigation.navtype = .list
        self.navigation.configRightItems(["public_filter"])
        self.navigation.rightItemCallback = {[weak self] tag in
        
            self?.dropFitter()
        }
    }
    
    func dropFitter() {
        
        if self.currentTypeModel == nil { return }
        let dropView = EXFilterView()
        dropView.delegate = self
        dropView.show(inView: self.view, position: CGPoint(x: 0, y: 54))
        dropView.filterParams = self.filterData
        dropView.reloadData()
        
    }

}

extension EXPosHistoryVC:EXFilterViewDelegate{
    func filterDataSource() -> [EXFilterDataModel] {

        
        let tipsLock = currentTypeModel?.tipLock ?? LanguageTools.getString(key: "pos_string_posLock")
        let tipsNormal = currentTypeModel?.tipNormal ?? LanguageTools.getString(key: "pos_string_postionLock")
        
        let items = EXFilterItem.getItem(titles: [tipsLock,tipsNormal], valueKeys: ["3","1"])
        let foldModel
            = EXFilterDataModel.getFoldModel(key: "projectType", title: currentTypeModel?.tipStatus ?? "", contents: items)
        let inputModel = EXFilterDataModel.getInputModel(key: "baseCoin", title: LanguageTools.getString(key: "pos_string_coinName"), placeHolder: "filter_input_coinsymbol".localized(), unit:"cny")
         let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "strTime", endDateKey: "entTime", title: "charge_text_date".localized())
        
        return [foldModel,inputModel,dateModel]
    }

    func filterConfirm(params: [String : String]) {
        self.filterData = params
        self.filterRequest()
    }
    
}


extension EXPosHistoryVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.postInfoType  == "3" ? dataSouceProtocol.count:dataSoucePostion.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:EXHistoryCell = tableView.dequeueReusableCell(for: indexPath,cellType: EXHistoryCell.self) 
//        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! EXHistoryCell
        if self.postInfoType == "3" {
            
            let indexItem = self.dataSouceProtocol[indexPath.row]
            cell.setProtocolCellData(enity: indexItem)
        }else {
            let indexItem = self.dataSoucePostion[indexPath.row]
            cell.setPostionCellData(enity: indexItem)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.postInfoType == "3" {
            
             let indexItem = self.dataSouceProtocol[indexPath.row]
            
            let incomes = indexItem.userGainList
            let vc = EXPosIncomeVC.instanceFromStoryboard(name: "FreeStacking")
            vc.dataSouce = incomes
            vc.baseCoin = indexItem.baseCoin
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}

