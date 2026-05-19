//
//  EXHelpEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHelpEntitySession: SuperEntity {
    var ID = ""
    var cmsArticleList:[EXHelpEntity] = []
    var articleTypeName = ""
    var expand: Bool = false
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        ID = dictContains("id")
        articleTypeName = dictContains("articleTypeName")
        if let array = dict["cmsArticleList"] as? [[String : Any]]{
                var arr : [EXHelpEntity] = []
                for dic in array{
                    let entity = EXHelpEntity()
                    entity.setEntityWithDict(dic)
                    arr.append(entity)
                }
                cmsArticleList = arr
        }
    }
}

class EXHelpEntity: SuperEntity {

    var ID = ""
    
    var fileName = ""
    
    var title = ""
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        ID = dictContains("ID")
        fileName = dictContains("fileName")
        title = dictContains("title")
    }
    
}
