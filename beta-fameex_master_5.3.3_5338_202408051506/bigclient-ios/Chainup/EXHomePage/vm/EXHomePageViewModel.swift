//
//  EXHomePageViewModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation

enum EXHomePageCellTypes {
    case banner
    case recommend
    case notice
    case tool
    case gap
    case subbanner
    case account
    case ranking
    case japanAccount
    case bgGap//Placeholder block with the same background color
    case nodata
}

struct EXHomePageViewModel {
    
    let homePageModel:EXHomeIndexViewModel
    
    init(homepageModel:EXHomeIndexModel) {
        let model = EXHomeIndexViewModel()
        model.viewModelWith(homepageModel)
        self.homePageModel = model
    }
    
    func getRowDataTypes() ->[EXHomePageCellTypes]{
        var rowTypes:[EXHomePageCellTypes] = []
        //Universal version, Chinese SaaS version
        if EXHomeViewModel.status() == .one {
            rowTypes.append(.banner)
            if EXHomeViewModel.homepageStyle() == .momo {
                if homePageModel.noticeInfoList.count > 0 {
                    rowTypes.append(.notice)
                }
                if homePageModel.header_symbol.count > 0 {
                    rowTypes.append(.recommend)
                    rowTypes.append(.gap)
                }else {
                    rowTypes.append(.gap)
                }
                if homePageModel.cmsAppDataList.count > 0 {
                    rowTypes.append(.tool)
                }
            }else if EXHomeViewModel.homepageStyle() == .bitsg {
                if homePageModel.noticeInfoList.count > 0 {
                    rowTypes.append(.notice)
                }
                if homePageModel.cmsAppDataList.count > 0 {
                    rowTypes.append(.tool)
                }
                if homePageModel.header_symbol.count > 0 {
                    rowTypes.append(.gap)
                    rowTypes.append(.recommend)
                    rowTypes.append(.gap)
                }else {
                    rowTypes.append(.gap)
                }
            }else {
                
                if homePageModel.noticeInfoList.count > 0 {
                    rowTypes.append(.notice)
                }else {
                    rowTypes.append(.gap)
                }

                if homePageModel.cmsAppDataList.count > 0 {
                    rowTypes.append(.tool)
                }
                
                if homePageModel.cmsAppDataListOther.count > 0 {
                    rowTypes.append(.subbanner)
                }

                if homePageModel.header_symbol.count > 0 {
                    rowTypes.append(.recommend)
                }else {
//                    rowTypes.append(.gap)
                }
            }
            rowTypes.append(.ranking)
        }else if EXHomeViewModel.status() == .two {
            //International version sorting, no account module
            rowTypes.append(.banner)
            if homePageModel.noticeInfoList.count > 0 {
                rowTypes.append(.notice)
            }

            if homePageModel.header_symbol.count > 0 {
                rowTypes.append(.recommend)
                rowTypes.append(.gap)
            }
            if homePageModel.cmsAppDataList.count > 0 {
                rowTypes.append(.tool)
            }
            rowTypes.append(.gap)
            rowTypes.append(.ranking)
        }else if EXHomeViewModel.status() == .three {
            rowTypes.append(.japanAccount)
            if homePageModel.noticeInfoList.count > 0 {
                rowTypes.append(.notice)
            }
            rowTypes.append(.subbanner)
            rowTypes.append(.gap)
            rowTypes.append(.ranking)
        }else if EXHomeViewModel.isContractStatus() {
            rowTypes.append(.banner)
            //co_header
            if homePageModel.header_symbol.count > 0 {
                rowTypes.append(.recommend)
                rowTypes.append(.gap)
            }else {
                rowTypes.append(.gap)
            }
            
            if homePageModel.noticeInfoList.count > 0 {
                rowTypes.append(.notice)
            }
            
            if homePageModel.cmsAppDataList.count > 0 {
                rowTypes.append(.tool)
            }
            
            if homePageModel.cmsAppDataListOther.count > 0 {
                rowTypes.append(.subbanner)
            }
            rowTypes.append(.gap)
            rowTypes.append(.account)
            rowTypes.append(.gap)
            rowTypes.append(.ranking)
        }
        //There are two sub banners, but only one is configured in the background, hidden
        if homePageModel.subBannerType == .doubleColoum && homePageModel.cmsAppDataListOther.count != 2 {
            if rowTypes.contains(.subbanner){
                if let index = rowTypes.firstIndex(of: .subbanner){
                    rowTypes.remove(at: index)
                }
            }
        }
        return rowTypes
    }
}


