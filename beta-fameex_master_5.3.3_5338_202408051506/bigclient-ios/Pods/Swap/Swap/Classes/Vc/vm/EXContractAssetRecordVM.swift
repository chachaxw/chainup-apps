//
//  EXAssetRecordVM.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXContractAssetRecordVM: NSObject {
    public var orderTypeArray:[EXSwapTransactionRecordType] {
        return ["","1","2","5","6","7","8","9","10","11","13"].map{(EXSwapTransactionRecordType.init(rawValue: $0) ?? .all)}
    }
}
