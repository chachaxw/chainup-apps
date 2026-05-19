//
//  CharacterExtension.swift
//  EXKit
//
//  Created by bradjohn on 2024/5/7.
//


public extension Character {
    var isChinese: Bool {
        return "\u{4E00}" <= self && self <= "\u{9FA5}"
    }
    
    var isAlphanumeric: Bool {
        return isLetter || isNumber
    }
}

