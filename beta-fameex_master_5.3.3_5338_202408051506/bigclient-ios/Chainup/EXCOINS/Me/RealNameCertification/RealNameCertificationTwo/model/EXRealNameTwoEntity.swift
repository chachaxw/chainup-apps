//
//  EXRealNameTwoEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXRealNameTwoEntity: NSObject {

    var userName = ""//name
    
    var familyName = ""//surname
    
    var name = ""//name
    
    var certificateType = ""//Document type 1 ID card 2 passport
    
    var countryCode = ""//Region Code
    
    var certificateNumber = ""//ID number
    
    var firstPhoto = ""//First sheet
    
    var secondPhoto = ""//Second sheet
    
    var thirdPhoto = ""//Third sheet
    
    var numberCode = ""//Country Code
    
}

class EXRealBtnEntity : NSObject{
    
    var title = ""
    
    var imgUrl = "" //If the upload fails, it will be '', so it will be given a 0 by default as a placeholder to distinguish it from the failure. After the upload is successful, there will be a URL,
    
    var placeholderImg = ""
    
    var image : UIImage?
    
}

