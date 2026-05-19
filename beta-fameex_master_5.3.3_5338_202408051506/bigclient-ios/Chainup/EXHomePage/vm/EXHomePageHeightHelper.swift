//
//  EXHomePageHeightHelper.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXHomePageHeightHelper: NSObject {
    static let rankingH:CGFloat = 56.0
    static let rankingMenu:CGFloat = 44.0
    static let rankingHeader:CGFloat = 22.0

    static let bannerH = ceil((SCREEN_WIDTH - 32) * 0.384839)
    static let subbannerH = ceil((SCREEN_WIDTH - 32) * 0.20408)
    static let doublebannerH = ceil((SCREEN_WIDTH - 32 - 11)/2 * 0.5301)

    static func getHeightByCellTypes(_ type:EXHomePageCellTypes,model:EXHomeIndexViewModel) -> CGFloat {
        
        if type == .banner {
            return bannerH + 4 //Up and Down 2
        }else if type == .notice {
            return 44
        }else if type == .account {
            if XUserDefault.isOffLine() {
                return 116 //SAAS not logged in height
            }else {
                return 150 //SAAS logged in height
                //                return ceil(SCREEN_WIDTH * 0.624) //It may be the height of other types of homepage
            }
        }else if type == .gap {
            return 12
        }else if type == .bgGap {
            return 10
        }else if type == .subbanner {
            if model.subBannerType == .singleColoum {
                return subbannerH + 24
            }else {
                return doublebannerH + 24
            }
        }else if type == .recommend {//market
            if EXHomeViewModel.homepageStyle() == .momo{
                return 117
            }else{
                return 86
            }
        }else if type == .tool { //Functional Area
            //In the international version, there are only 3 modules
            if EXHomeViewModel.status() == .two {
                return 102
            }else {
                return EXHomeSudokuCell.getHeightBySudokuItems(count: model.cmsAppDataList.count,style: model.kingkongType)
            }
        }else if type == .japanAccount {
            return  bannerH + 4
        }
        return CGFloat.leastNonzeroMagnitude
    }
}


