//
//  YDMenuDataSource.swift
//  YDMenu
//
//  Created by ZJXN on 2023/3/8.
//  Copyright © 2023年 YDZhao. All rights reserved.
//

import Foundation

protocol YDMenuDataSource: class {
    
    // required
    ///每个column有多少行 English: /How many lines are there in each column
    func menu(_ menu: YDMenu, numberOfRowsInColumn column: Int) -> Int

    ///每个column中每行的title English: /The title of each row in each column
    func menu(_ menu: YDMenu, titleForRowAtIndexPath indexPath: YDMenu.Index) -> String
    
    // optional
    /// 有多少个column，默认为1列 English: /How many columns are there, default to 1 column
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int
    
    
    // MARK: - 一级菜单 English: MARK: - First level menu
    /// 第column列，每行的image English: /Column, image for each row
    func menu(_ menu: YDMenu, imageNameForRowAtIndexPath: YDMenu.Index) -> String?
    
    /// detail text
    func menu(_ menu: YDMenu, detailTextForRowAtIndexPath indexPath: YDMenu.Index) -> String?
    
    /// 某列的某行item的数量，如果有，则说明有二级菜单，反之亦然 English: /The number of items in a certain column or row, if any, indicates the presence of a secondary menu, and vice versa
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int
    
    
    // MARK: - 二级菜单 English: MARK: - Secondary menu
    /// 二级菜单的标题 English: /Title of the secondary menu
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String

    /// 二级菜单的image English: /Image of the secondary menu
    func menu(_ menu: YDMenu, imageNameForItemsInRowAtIndexPath: YDMenu.Index) -> String?

    /// 二级菜单的detail text English: /Detail text of the secondary menu
    func menu(_ menu: YDMenu, detailTextForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String?
}

extension YDMenuDataSource {
    
    /// 有多少个column，默认为1列 English: /How many columns are there, default to 1 column
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int {
        return 1
    }
    
    
    // MARK: - 一级菜单 English: MARK: - First level menu
    /// 第column列，每行的image English: /Column, image for each row
    func menu(_ menu: YDMenu, imageNameForRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// detail text
    func menu(_ menu: YDMenu, detailTextForRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// 某列的某行item的数量，如果有，则说明有二级菜单，反之亦然 English: /The number of items in a certain column or row, if any, indicates the presence of a secondary menu, and vice versa
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int {
        return 0
    }
    

    // MARK: - 二级菜单 English: MARK: - Secondary menu
    /// 二级菜单的标题 English: /Title of the secondary menu
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String {
        return ""
    }
    
    /// 二级菜单的image English: /Image of the secondary menu
    func menu(_ menu: YDMenu, imageNameForItemsInRowAtIndexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// 二级菜单的detail text English: /Detail text of the secondary menu
    func menu(_ menu: YDMenu, detailTextForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        return nil
    }
}



