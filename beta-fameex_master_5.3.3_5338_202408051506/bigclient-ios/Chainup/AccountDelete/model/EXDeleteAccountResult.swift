//
//  EXDeleteAccountResult.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import HandyJSON
struct EXDeleteAccountOpenResult:HandyJSON{
    var deleteAccount = "0"
}
struct EXDeleteAccountResult:HandyJSON {

    var verifyGeneralOrder: Int = 0
    var verifyOutboundTransaction: Int = 0
    var verifyContract: Int = 0
    var verifyAssets: Int = 0
    var verifyLeverOrder: Int = 0
    
    func getResult()-> [Bool] {
        
        var restult = [Bool]()
        restult.append(self.verifyGeneralOrder > 0) //Spot
        if EXAppConfigManager.sharedInstance.didOpenLever(){
            restult.append(self.verifyLeverOrder > 0) //lever
        }
        if EXAppConfigManager.sharedInstance.didOpenContract(){
            restult.append(self.verifyContract > 0) //contract
        }
        if EXAppConfigManager.sharedInstance.didOpenFiat(){
            restult.append(self.verifyOutboundTransaction > 0) //Orders or advertisements
        }
        restult.append(self.verifyAssets > 0) //asset
        return restult
    }

}
/*
VerifyGeneralOrder cancellation status Verify if there are unresolved orders in the spot order '0' failed '1' succeeded
VerifyLeverOrder deregistration status verification for unresolved orders in lever order '0' failed '1' succeeded
VerifyContract cancellation status verification: Whether the locked account in the contract transaction still contains the amount of "0" failed and "1" succeeded
VerifyOutboundTransaction deregistration status Verify if there are orders or advertisements in progress for legal currency transactions "0" failed "1" succeeded
VerifyAssets deregistration status verification account total assets greater than a certain value "0" failed "1" succeeded

 */

