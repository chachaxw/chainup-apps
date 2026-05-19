//
//  EXContractAssetRecordsModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
public class EXContractAssetRecordModel: EXCOBaseModel {
    public  var ctime:String = ""
    public  var cTimestamp: String = ""
    public var type:String = ""
    public var amount:String = ""
//    var typeIntroduce:String {
//        return EXSwapTransactionRecordType.init(rawValue: type)?.introduce ?? ""
//    }
    public var contractName = ""
    var timeShow: String {
        return DateTools.strToTimeString(cTimestamp)
    }

}
public class EXContractAssetRecordsModel: EXCOBaseModel {
    public var transList:[EXContractAssetRecordModel] = []
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["transList":EXContractAssetRecordModel.self]
    }
    
}

