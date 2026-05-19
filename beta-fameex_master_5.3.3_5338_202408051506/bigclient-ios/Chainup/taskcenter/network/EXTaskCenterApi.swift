//
//  EXTaskCenterApi.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Moya

enum EXTaskCenterApiEndpoint {
    case taskHome(signSuccessed: Bool)
    case taskList(task: TaskType)
    case collectTaskRewards(taskId: String,success: Bool?)
    case signDaily
    case unCollectTask //Number of unclaimed task rewards (small red dots)
    case rewardCenter
    case overviewOfUserRewards(page: Int,pageSize: Int)
    case userRewardRecords(page: Int,pageSize: Int)
    case userRewardUnWithdraw(page: Int,pageSize: Int)
    case userWithdrawRecords(page: Int,pageSize: Int)
    case withdrawInfo
    case doWithdraw

}


extension EXTaskCenterApiEndpoint : TargetType {
    
    var baseURL: URL {
        return URL.init(string: EXNetworkDoctor.sharedManager.getAppAPIHost())!
    }
    
    var path: String {
        switch self {
        case .taskHome:
            return "/task_center_index"
        case .taskList:
            return "/user_task_info_list"
        case .collectTaskRewards:
            return "/receive_reward"
        case .signDaily:
            return "/do_daily_sign_in"
        case .unCollectTask:
            return "/task_complete_count"
        case .rewardCenter:
            return "/reward_center_info"
        case .overviewOfUserRewards:
            return "/user_reward_overall"
        case .userRewardRecords:
            return "/user_reward_records"
        case .userRewardUnWithdraw:
            return "/user_reward_un_withdraw"
        case .userWithdrawRecords:
            return "/user_withdraw_records"
        case .withdrawInfo:
            return "/do_withdraw_reward_info"
        case .doWithdraw:
            return "/do_withdraw_reward"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case .taskList(let type):
            if type != .all{
                let typeParam =  "\(type.rawValue)"
                parameters["type"] = typeParam
            }
        case .collectTaskRewards(let taskid,_):
            parameters["taskId"] = taskid
        case .userWithdrawRecords(let page, let pageSize):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
        case .overviewOfUserRewards(let page, let pageSize):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
        case .userRewardRecords(let page, let pageSize):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
        case .userRewardUnWithdraw(let page, let pageSize):
            parameters["page"] = page
            parameters["pageSize"] = pageSize
        default:
            break
        }
        
        return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding: JSONEncoding.default)

    }
    
    var headers: [String : String]? {
        let header = NetManager.sharedInstance.getHeaderParams()
        return header
    }
}

let taskCeneterApi = NetWorkService(endpointClosure: taskCeneterApiEndpointClosure, requestClosure: requestClosure)

let taskCeneterApiEndpointClosure = { (target: EXTaskCenterApiEndpoint) -> Endpoint in
    let sampleResponseClosure = { return EndpointSampleResponse.networkResponse(200, target.sampleData) }
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let method = target.method
    return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: target.method, task: target.task, httpHeaderFields: target.headers)
}
