//
//  EXArrayExtension.swift
//  Chainup
//
//  Created by liuxuan on 2021/1/29.
//  Copyright © 2021 Chainup. All rights reserved.
//

import Foundation

public extension Array {
    
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    // 防止数组越界
    subscript(index: Int, safe: Bool) -> Element? {
        if safe {
            if self.count > index {
                return self[index]
            }
            else {
                return nil
            }
        }
        else {
            return self[index]
        }
    }
}
