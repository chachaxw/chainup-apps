//
//  EXIDAuthenticModel.swift
//  Chainup
//
//  Created by cwd on 2023/11/3.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXIDAuthenticModel {
    var isNextLevel: Bool = false
    var isPassed: Bool = false
    var isCurrent: Bool = false
    var levelName = ""
    var sectionArr = [EXIDAuthenticType.right,EXIDAuthenticType.requirement]
//    var dataList = [EXIDAuthenticType: [EXIDAuthenticItemModel]]()
    var dataList = [EXIDAuthenticType: [EXIDAuthenticItemModel]]()
//    var authLevel = EXIDAuthenticLevel.NO
    class func getALLAuthLevelData(model:CommonAryModel) -> [EXIDAuthenticModel]{
        var arr = [EXIDAuthenticModel]()
        var currentLevel: Int = 0
        for (index,itemDic) in model.dictAry.enumerated() {
            if let dataItem = EXIDAuthenticLevelModel.mj_object(withKeyValues: itemDic) {
                let leveItem = getAuthLevelData(authlevel: dataItem)
                leveItem.isPassed = dataItem.isPassed
                if dataItem.isPassed {
                    currentLevel = index
                }
                if index == currentLevel + 1 {
                    leveItem.isNextLevel = true
                }
                arr.append(leveItem)
            }
        }
        return arr
    }
    class func getAuthLevelData(authlevel: EXIDAuthenticLevelModel) -> EXIDAuthenticModel{
        let model = EXIDAuthenticModel()
        model.isCurrent = authlevel.current == 1
        model.levelName = authlevel.showName
        
        
        var rightArr = [EXIDAuthenticItemModel]()
        let item = EXIDAuthenticItemModel()
        item.title =  "kyc_page_benefits_withdrawal".localized()
        item.content = authlevel.canWithdraw ? (String(authlevel.withdrawAmount).removeTrailingZeros() + " " + "kyc_page_benefits_amount".localized()) : "kyc_page_benefits_state_limit".localized()
        
        item.type = .right
        let item1 = EXIDAuthenticItemModel()
        item1.title =  "kyc_page_benefits_deposit".localized()
        item1.content = authlevel.canDeposit ? "kyc_page_benefits_state_nolimit".localized() : "kyc_page_benefits_state_limit".localized()
        item1.type = .right
        
        let item2 = EXIDAuthenticItemModel()
        item2.title =  "kyc_page_benefits_P2P".localized()//"c2c"
        item2.content = authlevel.canC2C ? "kyc_page_benefits_state_nolimit".localized() : "kyc_page_benefits_state_limit".localized()
        item2.type = .right
        rightArr = [item,item1,item2]

        var requirementArr = [EXIDAuthenticItemModel]()
        let requirementsArray: [String] = authlevel.requirementsReference.components(separatedBy: ",")
        if requirementsArray.isEmpty == false{
            for req in requirementsArray{
                let requirementsItem = EXIDAuthenticItemModel()
                requirementsItem.type = .requirement
                let content = KYCRequirement(rawValue: req) ?? .APPLICANT_DATA
                requirementsItem.title = content.showName
                requirementArr.append(requirementsItem)
            }
        }
        if authlevel.authConfigId > 0 { //
            let item6 = EXIDAuthenticItemModel()
            item6.btnTitle  = "kyc_page_button_verify".localized()
            item6.isBtn = true
            item6.type = .btn
            item6.kycType = authlevel.kycType
            item6.sumsubLevel = authlevel.sumsubLevel
            requirementArr.append(item6)
            var btnTitle = ""
           // 0 not certified 1 certified 2 under review
            
            item6.btnEnble =  (authlevel.current != 1 && authlevel.status==0)
            
            if authlevel.status == 0 {
               //to certifie
                btnTitle = "kyc_page_button_verify".localized()
            }else if authlevel.status == 1 {
                btnTitle = "kyc_page_button_verified".localized()
            }else if authlevel.status == 2 {
                btnTitle = "kyc_page_button_verifying".localized()
            }
            
            if authlevel.preLevelName.isEmpty == false{
                btnTitle =  "kyc_page_button_more".localized().formatWithArguments(arguments: [authlevel.preLevelName])
                item6.btnEnble = false
            }
            item6.btnTitle = btnTitle
            
        }
       
        let data = [
            EXIDAuthenticType.right: rightArr,
            EXIDAuthenticType.requirement: requirementArr
        ]
            
        model.dataList = data
        return model
    }
}

enum EXIDKYCTYPE: String{
    case PLATFORM
    case SUMSUB
}

enum KYCRIGHT{
    case c2c
    case deposit
    case withdraw
    case licai
}
class EXIDAuthenticLevelModel : EXBaseModel{
    var current: Int = 0 //
    var canKyc = false
    var showName: String = ""
    var sumsubLevel: String = "" //sumsub level name
    var authConfigId: Int = 0 //
    var authConfigName: String = ""//PLATFORM ，SUMSUB sumsub
    var requirementsReference: String = ""
    var depositStatus:Int = 0 // 0 forbiden， 1 allow
    var c2cStatus:Int = 0 //
    var withdrawAmount: Double = 0//
    var status: Int = 0 //0 not certified 1 certified 2 under review
    var preLevelName: String = ""
    
    var kycType: EXIDKYCTYPE {
        return EXIDKYCTYPE(rawValue: authConfigName) ?? .PLATFORM
    }
    
    var canDeposit: Bool {
        return depositStatus == 1
    }
    var canC2C: Bool {
        return c2cStatus == 1
    }
    var canWithdraw: Bool {
        return withdrawAmount > 0.0
    }
    var isPassed: Bool{
        return self.authConfigId > 0 && status == 1
    }
}
enum EXIDAuthenticType{
    case right
    case requirement
    case btn
    var destionTitle: String{
        switch self{
        case .right:
            return "kyc_page_benefits".localized()
        case .requirement:
            return "kyc_page_require".localized()
        default:
            return ""
        }
    }
}


class EXIDAuthenticItemModel{
    var type = EXIDAuthenticType.right
    var title = ""
    var content = ""
    var isBtn = false
    var btnEnble = false
    var btnTitle = ""
    var kycType = EXIDKYCTYPE.PLATFORM
    var sumsubLevel: String = "" //sumsub level name

}



enum KYCRequirement: String{
    case APPLICANT_DATA
    case IDENTITY_DOCUMENT
    case SELFIE
    case TWO_SELFIE
    case PROOF_OF_RESIDENCE
    case TWO_PROOF_OF_RESIDENCE
    case QUESTIONNAIRE
    case PHONE_VERIFICATION
    case EMAIL_VERIFICATION
    case FACE_RECOGNITION
    case REGISTRATION_SUCCESSFUL
    var showName: String {
        switch self {
        case .APPLICANT_DATA:
            return "kyc_page_require_basicinfo".localized()
        case .IDENTITY_DOCUMENT:
            return "kyc_page_require_identity".localized()
        case .SELFIE:
            return "kyc_page_require_selfie".localized()
        case .TWO_SELFIE:
            return "kyc_page_require_selfie2".localized()
        case .PROOF_OF_RESIDENCE:
            return "kyc_page_require_address".localized()
        case .TWO_PROOF_OF_RESIDENCE:
            return "kyc_page_require_address2".localized()
        case .QUESTIONNAIRE:
            return "kyc_page_require_questionnaires".localized()
        case .PHONE_VERIFICATION:
            return "kyc_page_require_phone".localized()
        case .EMAIL_VERIFICATION:
            return "kyc_page_require_email".localized()
        case .FACE_RECOGNITION:
            return "kyc_page_require_facial".localized()
        case .REGISTRATION_SUCCESSFUL:
            return "kyc_page_require_unverified".localized()
        }
    }
}


