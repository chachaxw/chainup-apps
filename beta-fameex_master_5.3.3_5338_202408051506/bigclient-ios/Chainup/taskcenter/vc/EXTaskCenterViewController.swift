//
//  EXTaskCenterViewController.swift
//  Chainup
//
//  Created by cwd on 2023/7/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTaskCenterViewController: NavCustomVC{
    
    let vm  = EXTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        vm.getTaskHomeAllInfo()
        subEvent()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logSuccess),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func subEvent(){
        vm.wsEventSubject.subscribe(onNext: { [weak self] event  in
            guard let `self` = self else { return }
            switch event{
            case .taskHome(let signSuccess):
                if signSuccess{ //
                    self.signSuccessAlert()
                }
                self.mainView.pagingView.mainTableView.mj_header.endRefreshing()
                self.mainView.reloadHeader()
            case .signDaily:
                self.vm.getTaskHomeInfo(signSuccessed: true) //sign Success to get NewData then pop alertview
            case .taskList:
                self.mainView.pagingView.mainTableView.mj_header.endRefreshing()
                self.mainView.reloadList()
            case .collectTaskRewards(_, let sussess):
                if let suc = sussess,suc == true {
                    self.collectSuccessAlert()
                }
                self.vm.getTaskListInfo()
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    func logSuccess(){
        self.vm.getTaskHomeAllInfo()
    }
    //MARK: lazy
    lazy var mainView: EXTaskCenterMainView = {
        let v = EXTaskCenterMainView(viewModel: self.vm)
        v.pagingHeader.signMainview.doSignCallBack = { [weak self]  in
            guard let `self` = self else { return }
            self.vm.doSignDaily()
        }
        return v
    }()
}
//
extension EXTaskCenterViewController{
    //
    func signSuccessAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = EXSignSuccessAlertView(frame: CGRect(x: 0, y: 0, width: Device_W, height: 314))
            alert.signItem = self.vm.taskHome?.signInInfo?.getSignShowList().last(where: { item in
                return item.hasSigned == true
            })
            EXAlert.showAlert(alertView: alert)
        }
    }
    
    func collectSuccessAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = EXSignSuccessAlertView(frame: CGRect(x: 0, y: 0, width: Device_W, height: 314))
            let item = EXSignShowInfo()
            item.successDes = "rewardCenter_text37".localized()
            item.amount = self.vm.collectionReward?.receiveAmount ?? "0"
            item.coin = self.vm.collectionReward?.rewardCoin ?? ""
            alert.signItem = item
            EXAlert.showAlert(alertView: alert)
        }
    }
}
//MARK: lazy
extension EXTaskCenterViewController{
    func configUI(){
        configNav()
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
    }
    func configNav(){
        navtype = .listtitle
        self.lastVC = false
        self.setTitle("menus_rewardCenter".localized())
        let rightBtn = UIButton()
        rightBtn.setTitle("myReward_text2".localized(), for: .normal)
        rightBtn.setTitle("myReward_text2".localized(), for: .highlighted)
        rightBtn.setTitleColor(UIColor.Ex.main1, for: .normal)
        rightBtn.titleLabel?.font = .Ex.medium(14)
        rightBtn.addTarget(self, action: #selector(gotoRewardCenter), for: .touchUpInside)
        self.navCustomView.setRightModule([rightBtn], rightSize :(80,19),alignPopBtn: true)
    }
    
    @objc func gotoRewardCenter(){
       let v = EXMyRewardsViewController()
        v.rewardCenterVm.taskHome = self.vm.taskHome
        self.navigationController?.pushViewController(v, animated: true)
    }
}
