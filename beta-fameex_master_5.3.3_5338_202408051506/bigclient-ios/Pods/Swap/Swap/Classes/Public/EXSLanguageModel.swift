//
//  EXSLanguageModel.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/12/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXSLanguageModel: EXCOBaseModel  {
    var id: String = "" // 4,
    var type: String = "" // 2,
    public var langKey: String = "" // en_US,
    var langName: String = "" // English ,
    var fileName: String = "" //
    var status: String = "" // 1,
    public var nowFileAddress: String = "" // https://futures-admin.oss-cn-http://futures-admin.oss-cn-hangzhou.aliyuncs.com/upload/app/en_US.jsonvar ,
    var backupFileAddress: String = "" // https://futures-admin.oss-cn-http://futures-admin.oss-cn-hangzhou.aliyuncs.com/upload/app/en_US.jsonvar ,
    public var sort: String = "" // 2,
    var brokerId: String = "" // 1021,
    var ctime: String = "" // 2021-11-29T20:47:08var ,
    var mtime: String = "" // 2021-12-08T14:20:05var
    public var selected:Bool = false //选择语言使用 English: Choose language usage
}

