//
//  YDMenuDelegate.swift
//  YDMenu
//
//  Created by ZJXN on 2023/3/8.
//  Copyright © 2023年 YDZhao. All rights reserved.
//

import Foundation

protocol YDMenuDelegate: class {
    
    /// 点击 English: /Click
    func menu(_ menu: YDMenu, didSelectRowAtIndexPath indexPath: YDMenu.Index) -> Void
    func menu(_ menu: YDMenu, willSelectMenuAtMenu currentMenu: Int) -> Void

}


