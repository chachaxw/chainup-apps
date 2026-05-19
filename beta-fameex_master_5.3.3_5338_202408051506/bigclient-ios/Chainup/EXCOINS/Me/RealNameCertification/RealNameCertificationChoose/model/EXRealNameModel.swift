//
//  EXRealNameModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXRealNameModel: EXBaseModel {
    
    
    var openAuto = ""//--Enable automatic review 0 not enabled 1 enabled
    var language = ""//Copywriting. If it is not opened, the copy can be obtained. If it is opened, the field will not be returned
    var limitFlag = ""//--Has the platform or individual exceeded the usage frequency on that day, 0 not exceeded, 1 exceeded
    var limitMsg = ""//prompt
    var toKenUrl = ""//Wake up the third-party authentication process, if the above does not pass, the fields will not be returned;
    var toResultUrl = ""//Callback URL, if the above does not pass, the field will not be returned;
}

class EXRealNameWriteModel : EXBaseModel{
    var language = ""//Copywriting. If it is not opened, the copy can be obtained. If it is opened, the field will not be returned
}

class EXRealNameModelManager : NSObject{
    //MARK: Single Example
    public static var sharedInstance : EXRealNameModelManager{
        struct Static {
            static let instance : EXRealNameModelManager = EXRealNameModelManager()
        }
        return Static.instance
    }
    
    var model = EXRealNameModel()
    
}

class EXKYCConfigModel : EXBaseModel{
    var openSingPass = ""//Do you want to enable SingPass 0, close 1, and enable it
    var verfyTemplet = ""//Manual review of data template 1, streamlined 2, complete
    var h5_templet2_url = ""//Template 2
    var h5_singpass_url = ""//Singpass address
}

