//
//  StoryBoardLoadable.swift
//  Chainup
//
//  Created by liuxuan on 2020/1/11.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import Foundation


public protocol StoryBoardLoadable {
    
}

extension StoryBoardLoadable {
    public static func instanceFromStoryboard(name:String) -> Self {
        //identifier 为类名，在stoyboard里配置
        let identifier = String(describing:self)
        return UIStoryboard.init(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier) as! Self
    }
}


