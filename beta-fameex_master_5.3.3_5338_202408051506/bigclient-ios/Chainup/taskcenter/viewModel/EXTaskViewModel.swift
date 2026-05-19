//
//  EXTaskViewModel.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
enum TaskType: Int, CaseIterable{
    case all = 4
    case novice = 1 //xinshou
    case daily = 0
    var describe :String {
        switch self{
        case .novice:
            return "rewardCenter_text17".localized()
        case .daily:
            return "rewardCenter_text18".localized()
        case .all:
            return "rewardCenter_text16".localized()
        }
    }
}
enum RewardType: CaseIterable{
    case waitTowithDraw
    case rewadDetail
    case WithDrawRecoad
    var describe: String {
        switch self {
        case .waitTowithDraw:
            return "myReward_text11".localized()
        case .rewadDetail:
            return "myReward_text12".localized()
        case .WithDrawRecoad:
            return "myReward_text13".localized()
        }
    }
}
enum TaskStatus : Int{
    case unclaimed = 0 //
    case taskHasExpired = 1
    case claimed = 2
    case progress = 4 //(unclaimed and not expired),
    case rewardHasExpired = 5
}

enum TaskCategory: Int {// 0spot(xianhuo) 1lever，3contract，4digital currency deposits
    case spot = 0
    case lever = 1
    case contract = 3
    case digitalCurrencyDeposits = 4
}


enum RewardDistributionMethod: Int{
    case SystemAutomatic = 0
    case ManualCollection = 1
}


class EXTaskViewModel: EXViewModel {
    
    var pageSize: Int = 20
    let exs_disposeBag = DisposeBag()
    private(set) var wsEventSubject: PublishSubject<EXTaskCenterApiEndpoint> = PublishSubject()
    
    var taskHome: EXTaskHomeModel?
    var collectionRewardResult: EXCollectionRewardResultModel?
    var allTasklist: [EXTaskItemModel?]?
    var noviceTasklist: [EXTaskItemModel?]?
    var dailyTasklist: [EXTaskItemModel?]?
    
    var collectionReward: EXCollectionRewardResultModel?
    var signDaily: EXSignDailyResultModel?
    var unCollectTaskInfo: EXUnCollectTaskInfo?
    //reward center
    var rewardCenter: EXRewardModel?
    var userRewardTotal: EXUserRewardTotalModel?
    var userRewardRecoardData: EXUserRewardRecoardData?
    var userRewardUnWithdrawalData: EXUserUnWithdrawalData?
    var userRewardWithdrawalData: EXUserWithdrawalData?
    var withdrawalInfo: EXWithdrawRewardinfo?
    //reward footerRefresh
    var unWithdrawalPage = 0
    var withdrawalPage = 0
    var rewardRecoardPage = 0
    
}


//business to renderView
extension EXTaskViewModel{
    func getTaskHomeAllInfo(){
        self.getTaskHomeInfo()
        self.getTaskList(taskType: .all)
        self.getTaskList(taskType: .novice)
        self.getTaskList(taskType: .daily)
    }
    
    func getTaskListInfo(){
        self.getTaskList(taskType: .all)
        self.getTaskList(taskType: .novice)
        self.getTaskList(taskType: .daily)
    }
    
    
    func getRewardCenterHomeAllInfo(){
        self.unWithdrawalPage = 1
        self.withdrawalPage = 1
        self.rewardRecoardPage = 1
        self.getUserWithdrawInfo()
        self.getUserRewardUnWithdrawRecorad(page: 1, pageSize: pageSize)
        self.getUserRewardRecords(page: 1, pageSize: pageSize)
        self.getUserRewardWithdrawRecorad(page: 1, pageSize: pageSize)
    }
}


// rewardCener data business footer refresh
extension EXTaskViewModel{
    func getRewardCenterData(reward: RewardType) {
        if reward == .waitTowithDraw {
            self.unWithdrawalPage += 1
            self.getUserRewardUnWithdrawRecorad(page: self.unWithdrawalPage, pageSize: pageSize)
        }else if reward == .rewadDetail{
            self.rewardRecoardPage += 1
            self.getUserRewardRecords(page: self.rewardRecoardPage, pageSize: pageSize)
        }else if reward == .WithDrawRecoad{
            self.withdrawalPage += 1
            self.getUserRewardWithdrawRecorad(page: self.withdrawalPage, pageSize: pageSize)
        }
    }
}

//taskCenter
extension EXTaskViewModel{
    func getTaskHomeInfo(signSuccessed: Bool = false){
        taskCeneterApi.rx.request(.taskHome(signSuccessed: signSuccessed))
            .customObjectMap(EXTaskHomeModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.taskHome = model
                self.wsEventSubject.onNext(.taskHome(signSuccessed: signSuccessed)) //
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    func getTaskList(taskType: TaskType){
        taskCeneterApi.rx.request(.taskList(task: taskType))
            .customArrayMap(EXTaskItemModel.self)
            .subscribe(onSuccess: { [weak self] list in
                guard let `self` = self else { return }
                switch taskType{
                case .all:
                    self.allTasklist = list
                case .novice:
                    self.noviceTasklist = list
                case .daily:
                    self.dailyTasklist = list
                }
                self.wsEventSubject.onNext(.taskList(task: taskType)) //
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    func collectTaskRewards(taskid: String){
        taskCeneterApi.rx.request(.collectTaskRewards(taskId: taskid,success: nil))
            .customObjectMap(EXCollectionRewardResultModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.collectionReward = model
                if model.sussess == false {
                    EXAlert.showFail(msg: model.resultType)
                    self.wsEventSubject.onNext(.collectTaskRewards(taskId: taskid,success: false)) //x
                    return
                }
                self.wsEventSubject.onNext(.collectTaskRewards(taskId: taskid,success: true)) //x
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    func doSignDaily(){
        taskCeneterApi.rx.request(.signDaily)
            .customObjectMap(EXSignDailyResultModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.signDaily = model
                self.wsEventSubject.onNext(.signDaily)
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    func getUnCollectTaskInfo(completion: ((EXUnCollectTaskInfo) -> Void)? = nil){
        taskCeneterApi.rx.request(.unCollectTask)
            .customObjectMap(EXUnCollectTaskInfo.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                completion?(model)
                self.unCollectTaskInfo = model
                self.wsEventSubject.onNext(.unCollectTask)
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    
    
}
//reward center
extension EXTaskViewModel{
    func getUserWithdrawInfo(){
        taskCeneterApi.rx.request(.withdrawInfo)
            .customObjectMap(EXWithdrawRewardinfo.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.withdrawalInfo = model
                self.wsEventSubject.onNext(.withdrawInfo)
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    func getRewardCenterInfo(){
        taskCeneterApi.rx.request(.rewardCenter)
            .customObjectMap(EXRewardModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.rewardCenter = model
                self.wsEventSubject.onNext(.rewardCenter)
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    
    func getUserRewardInfo(page: Int,pageSize: Int){
        taskCeneterApi.rx.request(.overviewOfUserRewards(page: page, pageSize: pageSize))
            .customObjectMap(EXUserRewardTotalModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.userRewardTotal = model
                self.wsEventSubject.onNext(.overviewOfUserRewards(page: page, pageSize: pageSize))
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
    
    
    func getUserRewardRecords(page: Int,pageSize: Int){
        taskCeneterApi.rx.request(.userRewardRecords(page: page, pageSize: pageSize))
            .customObjectMap(EXUserRewardRecoardData.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.userRewardRecoardData = model
                self.wsEventSubject.onNext(.userRewardRecords(page: page, pageSize: pageSize))
            }, onFailure: { _ in
                self.wsEventSubject.onNext(.userRewardRecords(page: page, pageSize: pageSize))
            })
            .disposed(by: self.exs_disposeBag)
    }
    func getUserRewardUnWithdrawRecorad(page: Int,pageSize: Int){
        taskCeneterApi.rx.request(.userRewardUnWithdraw(page: page, pageSize: pageSize))
            .customObjectMap(EXUserUnWithdrawalData.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.userRewardUnWithdrawalData = model
                self.wsEventSubject.onNext(.userRewardUnWithdraw(page: page, pageSize: pageSize))
            }, onFailure: { _ in
                self.wsEventSubject.onNext(.userRewardUnWithdraw(page: page, pageSize: pageSize))
            })
            .disposed(by: self.exs_disposeBag)
    }
    func getUserRewardWithdrawRecorad(page: Int,pageSize: Int){
        taskCeneterApi.rx.request(.userWithdrawRecords(page: page, pageSize: pageSize))
            .customObjectMap(EXUserWithdrawalData.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.userRewardWithdrawalData = model
                self.wsEventSubject.onNext(.userWithdrawRecords(page: page, pageSize: pageSize))
            }, onFailure: { _ in
                self.wsEventSubject.onNext(.userRewardUnWithdraw(page: page, pageSize: pageSize))
            })
            .disposed(by: self.exs_disposeBag)
    }
    func doWithdrawRequset(){
        taskCeneterApi.rx.request(.doWithdraw)
            .customObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
//                self.withdrawalInfo = model
                self.wsEventSubject.onNext(.doWithdraw)
            }, onFailure: { _ in

            })
            .disposed(by: self.exs_disposeBag)
    }
}
