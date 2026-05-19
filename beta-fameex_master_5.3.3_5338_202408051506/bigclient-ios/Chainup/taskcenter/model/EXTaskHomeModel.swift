//
//  EXTaskHomeModel.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXTaskHomeModel: EXBaseHanyJsonModel {
    var rewardMainHeading: String = ""
    var rewardSubheading: String = ""
    var rewardButtonStr: String = ""
    var rewardReceiveType: Int = 1 //Reward distribution method: 0 System automatic 1 Manual collection
    var rewardReceiveTerm: Int = 1 //Manual collection validity period/day
    var signSwitch: Int = 0 //switch 0 off, 1 on
    var withdrawSwitch: Int  = 0//switch 0 off, 1 on
    var timeZone: String = ""
    var bannerImageUrl: String = ""
    var signInInfo: EXSignInInfo?
    var nightBannerImageH5Url: String = ""
    var bannerImageH5Url: String = ""
    
    func getTaskDescribe(taskType: TaskType) -> String {
        if let type = RewardDistributionMethod(rawValue: self.rewardReceiveType){
            
            if taskType == .novice{
                if type == .SystemAutomatic{
                    return "rewardCenter_text22".localized()
                }else{
                    return String(format: "rewardCenter_text23".localized(), "\(rewardReceiveTerm)")
                }
                
            }else if taskType == .daily{
                if type == .SystemAutomatic{
                    return "rewardCenter_text24".localized()
                }else{
                    return String(format: "rewardCenter_text25".localized(), EXAppConfigManager.sharedInstance.configVm.cfgModel.timeZone)
                }
            }
        }
        return ""
    }
}
//has signed info
class RewardDetail: EXBaseHanyJsonModel{
    var reward = ""
    var rewardCoin = ""
}

class EXSignShowInfo{
    var amount = ""
    var coin = ""
    var hasSigned = false
    var index = "0"
    var successDes = ""
}


class EXSignInInfo: EXBaseHanyJsonModel{
    var rewardCoin = ""
    var seriateSignInNum = "0" //Number of consecutive user registrations
    var isSignIn = ""
    var isKyc: Int = 0
    var isTwoCheck: Int = 0 //o you need dual verification? 0 No, 1 Yes
    var rewards = [""]
    var rewardDetails: [RewardDetail]?
    
    func getSignShowList() -> [EXSignShowInfo] {
        
        var showList = [EXSignShowInfo]()
        for (index,item) in rewards.enumerated(){
            let signShow = EXSignShowInfo()
            signShow.amount = item
            signShow.coin = rewardCoin
            signShow.index = "\(index + 1)"
            signShow.hasSigned = false
            showList.append(signShow)
        }
        
        guard let rewardDetails = rewardDetails else{
            return showList
        }
        
        for (index,item) in rewardDetails.enumerated(){
            let sign = showList[index]
            sign.amount = item.reward
            sign.coin = item.rewardCoin
            sign.hasSigned = true
        }
        return showList
    }
}



class EXTaskItemModel: EXBaseHanyJsonModel{
    var id: Int = 0
    var taskType: Int = 0 //Task Type 0 Daily 1 Novice 2 Advanced 3 Check In
    var taskCategory: Int = 0 //Function module 0 spot, 1 leverage, 3 contracts, 4 digital currency deposit (2 is ETF and not done yet)
    var taskCycles = "0" //Assessment cycle 0 single transaction, 1 single day
    var targetValue = ""
    var banner = ""
    var logo = ""
    var nightLogo = ""
    var targetCoin = ""//Task Indicator Currency/Unit
    var rewardAmount = ""
    var rewardCoin = ""
    var rewardType: Int = 0 //
    var finishedAmount = ""
    var remindTime = ""
    var status: Int = 0 //The user's current task status is 0 unclaimed, 1 task has expired, 2 claimed, 4 in progress (unclaimed and not expired), 5 reward has expired
    var period: Int = 0 //Cycle (novice task)
    var taskName = ""
    var taskInfo = ""
    var rewardTypeShow : String {
        if rewardType == 0 {
            return "rewardCenter_text26".localized()
        }
        return ""
    }
    
    var taskStatus :TaskStatus {
        return TaskStatus(rawValue: status) ?? .taskHasExpired
    }
     //用户当前任务状态 0 未领取，1任务已过期，2已领取，4进行中(未领取且未过期），5 奖励已过期    
    var actionBtnName: String {
        switch taskStatus {
        case .progress:
            return "rewardCenter_text31".localized() //gofinish
        case .unclaimed:
            return "rewardCenter_text32".localized() //go claimed
        case .rewardHasExpired:
            return "rewardCenter_text36".localized()
        case .taskHasExpired:
            return "rewardCenter_text35".localized()
        case .claimed:
            return "rewardCenter_text33".localized()
        default:
            return ""
        }
    }
    var btnIsEnble: Bool {
        switch taskStatus {
        case .progress:
            return true
        case .unclaimed:
            return true
        case .rewardHasExpired:
            return false
        case .taskHasExpired:
            return false
        case .claimed:
            return false
        default:
            return false
        }
        

    }
    var timeTitle: String {
        switch taskStatus {
        case .progress:
            return "rewardCenter_text27".localized() //expexied time
        case .unclaimed:
            return "rewardCenter_text28".localized() //
        case .rewardHasExpired:
            return "rewardCenter_text28".localized()
        case .taskHasExpired:
            return "rewardCenter_text27".localized()
        case .claimed:
            return "rewardCenter_text29".localized()
        default:
            return ""
        }
        
    }
}
//
class EXCollectionRewardResultModel: EXBaseHanyJsonModel{
    var receiveAmount = ""
    var rewardCoin = ""
    var resultType = ""
    var sussess: Bool {
        return resultType == "Success"
    }
}
class EXSignDailyResultModel: EXBaseHanyJsonModel{
   var rewards = [""]
}

class EXUnCollectTaskInfo: EXBaseHanyJsonModel{
   var count = 0
}


class EXRewardModel: EXBaseHanyJsonModel{
    var confSwitch: Int = 0 //Main switch, whether the reward center is displayed; 0 No, 1 Yes
    var suspendedShowPage = ""//Floating window display page, returning 0 means not displaying floating window comma separated 1. Home page 2. Asset page 3. Personal center page
    var suspendedImgUrl = ""
    var suspendedTitle = ""
    var suspendedSubTitle = ""
    var count = 0
}

//Overview of User Rewards
class EXUserRewardTotalModel: EXBaseHanyJsonModel{
    var coin = ""
    var rewardAmount = ""
    var withdrewAmount = "" //
    var unWithdrawAmount = "" //
    var unWithdrawUsdtAmount = ""
}
//User reward record list
class EXUserRewardRecoardData: EXBaseHanyJsonModel{
    var list: [EXUserRewardRecoardItem]?
}
class EXUserRewardRecoardItem: EXBaseHanyJsonModel{
    var id: Int = 0
    var coin = ""
    var taskType: Int = 0 //Task Type 0 Daily 1 Novice 2 Advanced 3 Check In
    var taskCategory: Int = 0 //Function module 0 spot, 1 leverage, 3 contracts, 4 digital currency deposit (2 is ETF and not done yet)
    var taskCycles = "" //Assessment cycle 0 single transaction, 1 single day
    var amount = "" //Reward quantity
    var usdtAmount = "" //Reward amount (equivalent to USDT)
    var rewardType: Int = 0 //Task reward type 0 Cash reward
    var receiveTime = "" //Reward distribution time
    var taskName = ""
}

//User's un_withdrawal records
class EXUserUnWithdrawalData: EXBaseHanyJsonModel{
    var unWithdrawList: [EXUnWithdrawalItem]?
    var usdtAmount = ""//Total undrawn converted USDT
}
class EXUnWithdrawalItem: EXBaseHanyJsonModel{
    var coin = ""
    var unWithdrawAmount = ""
    var usdtAmount = ""
}

//User's withdrawal records
class EXUserWithdrawalData: EXBaseHanyJsonModel{
    var list: [EXWithdrawalItem]?
}
class EXWithdrawalItem: EXBaseHanyJsonModel{
    var coin = ""
    var amount = ""
    var usdtAmount = "" //Withdrawal amount
    var withdrawTime = ""
}


//Withdrawal reward information
class EXWithdrawRewardinfo: EXBaseHanyJsonModel{
    var totalWithdrawnUsdt = ""//Accumulated withdrawal has been converted into USDT
    var withdrawPendingUsdt = ""//Cash to be withdrawn converted into USDT    非必须
    var leftWithdrawPendingUsdt = ""//Remaining cash withdrawable upon arrival (USDT)
    
}
