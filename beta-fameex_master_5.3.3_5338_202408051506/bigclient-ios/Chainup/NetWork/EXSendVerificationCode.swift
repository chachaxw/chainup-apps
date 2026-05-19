//
//  EXSendVerificationCode.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
/**
 1. 设置资金密码 短信邮箱6
 2. 修改资金密码 短信邮箱7
 3. 忘了密码后新设密码 短信邮箱6
 4. 点击忘了密码 短信邮箱35
 5. 解绑资金密码 短信邮箱36
 6.提币白名单开关验证 短信邮箱37
 7. 添加地址 短信邮箱11
 8. 删除地址 短信邮箱12
 9. C2C出售(仅短信) 短信38
 10.商户放币订单验证(仅短信) 短信39
 11. 提现 短信邮箱10
 12. 站内直转 短信邮箱34
 
 
 1. Set fund password SMS email 6
 2. Change fund password via SMS email 7
 3. After forgetting the password, set a new password via SMS email. 6
 4. Click on Forgot Password SMS Email 35
 5. Unbind fund password, SMS email 36
 6. Verify SMS email address for coin withdrawal whitelist switch 37
 7. Add address SMS email 11
 8. Delete Address SMS Email 12
 9. C2C sales (SMS only) SMS 38
 10. Merchant coin order verification (SMS only) SMS 39
 11. Withdrawal SMS email 10
 12. On site direct to SMS email 34
 
 
 */
class EXSendVerificationCode: NSObject {
    static let changepassword = "5"//Change login password verification code
    static let moblieforget = "24"//Forgot verification code on phone
    static let emailforget = "3"//Email forgot verification code
    static let regist = "1"//Register an account
    static let moblielogin = "25"//Mobile login verification code
    static let emaillogin = "4"//Email login verification code
    static let changeotcpw = "6"//Set fund password verification code
    static let closegoogleAndmoblie = "27"//Turn off Google and mobile authentication
    static let updateemailwithemail = "15"//Bind Email New and Old Email Verification
    static let updateemailwithphone = "4"//Binding email and mobile phone verification
    static let updatephonewithphone = "3"//Binding mobile phone verification
    static let blindphone = "2"//Binding mobile phone verification
    static let addNewAddress = "11"//Add coin address
//    static let updateNewAddress = "12"//Modify Currency Address
    static let withDraw = "13"//Add coin address
    static let otcAddPayment = "28"//OTC Add Payment Method
    static let b2cwithDraw = "32"//Withdrawal of legal currency
    static let b2caddbank = "30"//Adding Bank Cards to Legal Currency
    static let b2ceditbank = "31"//Legal currency modification bank card
    static let internalTransfer = "34"//Direct transfer within the station
    static let accountdeletephone = "301"//
    static let accountdeleteEmail = "30"//mailbox
    static let Withdrawal = "10"
    static let coinReleaseConfirm = "39"
    static let c2cSell = "38"
    static let deleteAddress = "12"
    static let whiteListOpen = "37"
    static let whiteListClose = "40"
    static let modifyFundPwd = "7"
    static let forgetFundPwd = "35"
    static let unbindFundPwd = "36"

}

class EXMailVerificationCode: NSObject {
    static let registerByEmail = "1"//Email registration
    static let bindEmail = "2"//Bind email
    static let findPwd = "3"//Retrieve password
    static let emailLogin = "4"//Email login
    static let relogin = "9"//Secondary login
    static let addCoinAddr = "13"//Add charging address
    static let modifyEmail = "15"//Modify email
    static let loginRemind = "16"//Login reminder
    static let withDraw = "17"//Withdrawal
    static let internalTransfer = "19"//Direct transfer within the station
//    static let internalTransfer = "34"//Direct transfer within the station
    static let Withdrawal = "10"
    static let deleteAddress = "12"
    static let addNewAddress = "11"//Add coin address
    static let whiteListOpen = "37"
    static let changeotcpw = "6"//Set fund password verification code
    static let modifyFundPwd = "7"
    static let forgetFundPwd = "35"
    static let unbindFundPwd = "36"


}

