//
//  EXContractOpenMode.swift
//  Swap
//
//  Created by cwd on 2023/7/20.
//

import UIKit

enum EXContractOpenMode: CaseIterable{
    case cross
    case isolated
    var describe: String{
        switch self{
        case .cross:
            return "cp_contract_setting_text1".ex_localized()
        case .isolated:
            return "cp_contract_setting_text2".ex_localized()
        }
    }
}
