//
//  HomeFunctionEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class HomeFunctionEntity: SuperEntity {

    var type = ""//0. webView 1. coinmap_ Market 2. Coinmap_ Trading Currency Pair Trading Page 3. Coinmap_ Details Coin Pair Details Page 4. otc_ Buy OTC - Purchase 5. OTC_ Sell Off the Counter - Sell 6. Order_ Record order record 7. account_ Transfer account transfer 8. otc_ Account assets - off exchange account 9. coin_ Account Asset Currency Account 10.safe_ Set Security Settings 11. safe_ Money Security Settings - Fund Password 12. personal_ Information Personal Data 13. personal_ Invitation Profile - Invitation Code 14. Collection_ Way payment method 15. real_ Name real name authentication
    
    var id = ""//
    
    var title = "测试测试测试测试测试"//
    
    var subhead = "测试测试测试测试测试测试测试测试测试测试测试"//
    
    var lang = ""//language
    
    var httpUrl = ""//HTTP link
    
    var imageUrl = ""//Image address
    
    var sort = 0//sort
    
    var nativeUrl = ""//Native routing
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        id = dictContains("id")
        type = dictContains("type")
        title = dictContains("title")
        subhead = dictContains("subhead")
        lang = dictContains("lang")
        httpUrl = dictContains("httpUrl")
        if let s = Int(dictContains("sort")){
            sort = s
        }
        imageUrl = dictContains("imageUrl")
        nativeUrl = dictContains("nativeUrl")
        
    }
    
}



