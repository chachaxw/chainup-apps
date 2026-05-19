//
//  EXPrsHomeProjectEntity.swift
//  Chainup
//
//  Created by lcus on 2023/10/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit



class EXPosHomeProjectEntity: EXBaseModel {
    var id: Int = 0
    var name:String = ""
    var shortName: String = ""
    var labelType: Int = 0
    var lockDay: Int = 0
    var gainRate: Double = 0.0
    var title: String = ""
    var logo: String = ""
    var progress: String = ""
    var baseCoin: String = ""
    var projectType: Int = 0
    var configTypes: String = ""
    var status: Int = 0
}
