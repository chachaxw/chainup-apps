//
//  EXTransferEnums.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXTransferFlow {
    case exchangeToOther
    case otcToExchange
    case contractToExchagne
    case leverageToExchagne//lever
}

enum EXTransferAccountKey:String {
    case accountKeyExchange = "1" //Trading account
    case accountKeyOTC = "2" //Off exchange account
}

