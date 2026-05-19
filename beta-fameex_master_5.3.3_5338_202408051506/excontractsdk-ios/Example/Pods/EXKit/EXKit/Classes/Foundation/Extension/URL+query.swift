//
//  URL+query.swift
//  Chainup
//
//  Created by liuxuan on 2021/3/12.
//  Copyright © 2021 Chainup. All rights reserved.
//

import Foundation

public extension URL {
    /// Dictionary of the URL's query parameters
    var queryMap: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        var items: [String: String] = [:]
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        return items
    }
}
