//
//  EXWithdrawSuccessModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXWithdrawSuccessModel: EXBaseModel {
    /*
IsOpenUserCheck: If this field is true, it needs to be checked, and if it is false, it does not need to be checked
IsOpenCompanyCheck: If this field is true, it means face++, and if it is false, it means identity authentication
     */
    var isOpenUserCheck:String = ""
    var isOpenCompanyCheck:String = ""
    var withdrawId:String = ""
    var faceToken:String = ""//face++ token
    var faceAuthUrl:String = ""//face++ url
}

