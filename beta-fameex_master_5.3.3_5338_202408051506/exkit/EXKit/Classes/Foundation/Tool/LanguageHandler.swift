//
//  LanguageTools.swift
//  AppProject
//
//  Created by zewu wang on2020/8/6.
//  Copyright ©2020年 zewu wang. All rights reserved.
//

import UIKit

let UserLanguage = "UserLanguage"
let AppleLanguages = "AppleLanguages"
let AppUserSelectLanguage = "k_AppUserSelectLanguage"
let firstUsedConfigDefLan = "configDefLanguage"

//这个类只管理语言bundle,其余还由原来的languagetools处理

@objcMembers public class LanguageHandler: NSObject {
    public static var priviatePhoneLanguage: String {
        var lan = LanguageHandler.phoneLanguage
        if lan == "zh_TC" { //chinese Traditonal
            lan = "el_GR"
        }
        return lan
    }
    public static var phoneLanguage:String { EXLanguage.current }
        
    public var bundle : Bundle? { EXLanguage.currentResource.local?.bundle }
    
    public static var shareInstance : LanguageHandler {
        struct Static {
            static let instance : LanguageHandler = LanguageHandler()
        }
        return Static.instance
    }
}

public struct EXLanguage {
    /// Language identifier, see `Resource.BuiltIn.languages`
    public static var current:String { currentResource.language }
    /// Version of current resource if exists, nil otherwise
    public static var currentVersion: String? { currentResource.version }
    /// Version of language resource if exists, nil otherwise
    public static func version(of language:String) -> String? { Resource.object(for: language)?.version }
    /// - Parameters:
    ///   - language:  The language to be used to load localizations as current.
    ///   - localizations: If localizations is valid, the resource of language  will be updated and false will be returned if updating was failed.
    /// - Returns: True for success, false otherwise  failed.
    @discardableResult
    public static func updateCurrentLanguage(to language:String, with localizations:[String:String]? = nil, version:String? = nil) -> Bool {
        if let localizations = localizations {
            guard updateLocalizations(of: language, localizations: localizations, version:version) else { return false }
        }
        guard let resource = Resource.object(for: language) else { return false }
        let changed = language != current
        self.currentResource = resource
        if changed { resource.save() }
        currentLocalizationsDidChangeBlock?(changed, true)
        NotificationCenter.default.post(name: currentLocalizationsDidChangeNotification, object: nil)
        if changed { NotificationCenter.default.post(name: currentLanguageDidChangeNotification, object: nil) }
        return true
    }
    /// Reload resources of current language
    public static func reload() {
        updateCurrentLanguage(to: current)
    }
    /// Reset  to default language  named [en_US]
    public static func reset() {
        updateCurrentLanguage(to: Resource.default.language)
    }
    ///
    static func localizedString(for key:String) -> String { currentResource.localizedString(for: key) }
    /// triggered when the language changed
    public static let currentLanguageDidChangeNotification: NSNotification.Name = .init("EX.Notification.currentLanguageDidChange")
    /// triggered when the localizations changed
    public static let currentLocalizationsDidChangeNotification: NSNotification.Name = .init("EX.Notification.currentLocalizationsDidChange")
    ///
    fileprivate static var currentResource: Resource = .initial
    ///
    @discardableResult
    public static func updateLocalizations(of language:String, localizations:[String:String], version:String? = nil) -> Bool {
        guard !language.isEmpty else { return false }
        do {
            try Resource.update(language: language, localizations: localizations, version: version)
            return true
        } catch let error {
            EXLogger.debug(scene:loggerScene, message: "Failed to update localizations of \(language), error:\(error)")
            return false
        }
    }
}

public extension EXLanguage {
    /// the two block is used for relaunch the app,
    private static var currentLocalizationsDidChangeBlock:((Bool,Bool)->Void)?
    /// Using the block to observer language changes.
    /// - Parameter block: The block will be invoked  before 
    /// `currentLocalizationsDidChangeNotification` and `currentLanguageDidChangeNotification`
    /// either the language did changed or the resource did changed or both.
    static func observerLanguageChanging(block: @escaping (_ languageDidChange:Bool, _ resoureDidChange:Bool) -> Void) {
        guard currentLocalizationsDidChangeBlock == nil else {
#if DEBUG
            fatalError("This function can be called only once.")
#else
            return
#endif
        }
        currentLocalizationsDidChangeBlock = block
    }
}

public extension EXLanguage {
    static let loggerScene:EXLogger.Scene = "EXLanguage"
}

private extension EXLanguage {
    struct Resource {
        let language:String
        let remote: Remote?
        let local: BuiltIn?
        ///
        private init?(language: String?) {
            guard let language = language, !language.isEmpty else { return nil }
            let remote = Remote.object(for: language)
            let local  = BuiltIn.object(for: language)
            guard remote != nil || local != nil else { return nil }
            ///
            self.language = language
            self.local = local
            self.remote = remote
        }
        ///
        private static var resources:[String:Self] = [:]
        ///
        static func object(for language:String) -> Self? {
            if let obj = resources[language] { return obj }
            let resource = Self.init(language: language)
            resources[language] = resource
            return resource
        }
        ///
        var version: String? { remote?.version }
        /// en_US
        static var `default`: Resource { object(for: BuiltIn.default.language)!}
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
        ///
        private var fixedLocalizations:NSMutableDictionary = .init()
        ///
        func localizedString(for key:String) -> String {
            if let value = fixedLocalizations[key] as? String { return value }
            let value = fixedValue(of: _localizedString(for: key), for: key)
            fixedLocalizations[key] = value
            return value
        }
        ///
        private func _localizedString(for key:String) -> String? {
            if let value = remote?.localizedString(for: key) ?? local?.localizedString(for: key) { return value }
            let isDefault = language == Self.default.language
            /// Use the local value of default language [en_US]
            if !isDefault { return Self.default._localizedString(for: key) }
            return nil
        }
        ///
        private func fixedValue(of value:String?, for key:String) -> String {
            guard var value = value else { return "" }
            if value.contains("%s") { value = value.replacingOccurrences(of: "%s", with: "%@") }
            if value.contains("$s") {
                do {
                    let regex = try NSRegularExpression(pattern: #"%(\d+\$)?s"#)
                    for result in regex.matches(in: value, range: NSRange(location: 0, length: value.count)).reversed() {
                        guard let range = Range(result.range, in: value) else { continue }
                        let substring = value[range]
                        let replacement = substring.replacingOccurrences(of: "s", with: "@")
                        value.replaceSubrange(range, with: replacement)
                    }
                    return value
                } catch {
                    EXLogger.debug(scene:loggerScene, message: "Fix localized value [\(value)] of key [\(key)] failed, error:\(error)")
                    return value
                }
            }
            return value
        }
        ///
        fileprivate static func update(language:String, localizations:[String:String]?, version:String? = nil) throws {
            do {
                try Remote.update(language: language, localizations: localizations, version: version)
                resources[language] = nil
            } catch {
                throw error
            }
        }
    }
}

private extension EXLanguage.Resource {
    ///
    private static let kSelectedLanguageKey = UserLanguage
    ///
    static let initial: Self = {
        /// Using selected  language as default if exists.
        var language = UserDefaults.standard.string(forKey: kSelectedLanguageKey)
        if LanguageTools.shareInstance.isPrivate {
            if language == "zh_TC" { language = "el_GR" }
        }
        if let resource = Self(language: language) { return resource }
        /// Otherwise use system language as default. The format of the system language is`language-script_region`,  e.g. zh-Hans_HK
        let localLanguages = BuiltIn.languages
        for systemLanguage in Bundle.main.preferredLocalizations {
            if let language = localLanguages.first(where: { systemLanguage.hasPrefix($0.lproj) })?.language {
                if let resoure = object(for: language) {
                    resoure.save()
                    return resoure
                }
            }
        }
        Self.default.save()
        return .default
    }()
    ///
    func save() {
        UserDefaults.standard.setValue(language, forKey: Self.kSelectedLanguageKey)
    }
}

private extension EXLanguage.Resource {
    struct Remote {
        let language:String
        let version:String?
        private let localizations: [String:String]
        private init?(language: String?) {
            guard let language = language, !language.isEmpty else { return nil }
            guard let localizations = Self.localizations(of: language), !localizations.isEmpty else { return nil }
            self.language = language
            self.localizations = localizations
            self.version = Self.version(from: localizations)
        }
        ///
        static func object(for language:String) -> Remote? {
            return Remote.init(language: language)
        }
        ///
        fileprivate func localizedString(for key:String) -> String? {
            localizations[key]
        }
        ///
        private static func localizations(of language:String) -> [String:String]? {
            if let value = migrateLocalizationsIfNeeded(of: language) { return value }
            do {
                let data = try Data(contentsOf: path(of: language))
                return try JSONSerialization.jsonObject(with: data) as? [String:String]
            } catch let error {
                EXLogger.debug(scene:EXLanguage.loggerScene, message: "Serialize json file of localizations of \(language) failed, error:\(error)")
            }
            return nil
        }
        ///
        private static func migrateLocalizationsIfNeeded(of language:String) -> [String:String]? {
            guard !FileManager.default.fileExists(atPath: path(of: language).absoluteString) else { return nil }
            guard let localizations = UserDefaults.standard.dictionary(forKey:"dl_\(language)") as? [String : String], !localizations.isEmpty else { return nil }
            do {
                try update(language: language, localizations: localizations)
                UserDefaults.standard.removeObject(forKey: "dl_\(language)")
            } catch let error {
                EXLogger.debug(scene:EXLanguage.loggerScene, message: "Migrate localizations of \(language) failed, error:\(error)")
            }
            return localizations
        }
        ///
        private static let cacheDirectory:URL =  {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("EXLanguage/common")
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            return directory
        }()
        /// for read and write
        private static func path(of language:String) -> URL {
            cacheDirectory.appendingPathComponent(language).appendingPathExtension("json")
        }
        ///
        fileprivate static func update(language: String, localizations:[String:String]?, version:String? = nil) throws {
            guard let localizations = localizations, !localizations.isEmpty else {
                throw NSError(domain: CocoaError.errorDomain,
                              code: CocoaError.Code.coderValueNotFound.rawValue,
                              userInfo: [NSLocalizedDescriptionKey:"Invalid localizations, because it is empty."])
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: merging(localizations:localizations, with: version))
                try data.write(to: path(of: language), options: .atomic)
            } catch let error {
                throw error
            }
        }
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
        ///
        static let versionKey = "ex.language.localizations.remote.version"
        ///
        private static func merging(localizations:[String:String], with version:String?) -> [String:String] {
            guard let version = version else { return localizations }
            return localizations.merging([versionKey:version], uniquingKeysWith: { lhs,_ in lhs })
        }
        ///
        private static func version(from localizations:[String:String]) -> String? {
            return localizations[versionKey]
        }
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
    }
}

private extension EXLanguage.Resource {
    class BuiltIn {
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
        let language:String  /// server identifier
        let lproj:String /// local identifier, name of the resource
        private init(identifier: String, lproj: String) {
            self.language = identifier
            self.lproj = lproj
        }
        ///
        class func object(for language:String) -> BuiltIn? {
            BuiltIn.languages.first(where: { $0.language == language })
        }
        ///
        func localizedString(for key:String) -> String? {
            localizations[key] ?? bundle?.localizedString(forKey: key, value: nil, table: nil)
        }
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
        ///
        static var languages: [BuiltIn] { LanguageTools.shareInstance.isPrivate ? privatizations : defaults }
        ///
        static let `default` = BuiltIn(identifier: "en_US", lproj: "en")
        ///
        private static let defaults: [BuiltIn] = [
            BuiltIn(identifier: "zh_CN", lproj: "zh-Hans"),
            BuiltIn(identifier: "zh_TC", lproj: "zh-Hant"),
            BuiltIn(identifier: "el_GR", lproj: "zh-Hant"),
            BuiltIn(identifier: "ko_KR", lproj: "ko-KR"),
            BuiltIn(identifier: "vi_VN", lproj: "vi"),
            BuiltIn(identifier: "ja_JP", lproj: "ja"),
            `default`,
        ]
        ///
        private static let privatizations: [BuiltIn] = [
            BuiltIn(identifier: "zh_CN", lproj: "zh-Hans"),
            BuiltIn(identifier: "el_GR", lproj: "zh-Hant"),
            BuiltIn(identifier: "ko_KR", lproj: "ko-KR"),
            BuiltIn(identifier: "vi_VN", lproj: "vi"),
            BuiltIn(identifier: "ja_JP", lproj: "ja"),
            BuiltIn(identifier: "th_TH", lproj: "th-TH"),
            BuiltIn(identifier: "id_ID", lproj: "id-ID"),
            `default`,
        ]
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
        ///
        fileprivate lazy var bundle: Bundle? = {
            guard let directory = Bundle.main.path(forResource: lproj, ofType: "lproj") else { return nil }
            return Bundle(path: directory)
        }()
        ///
        private lazy var localizations: [String:String] = {
            if let path = bundle?.path(forResource: "Localizable", ofType: "strings"),
               let result = NSDictionary(contentsOfFile: path) as? [String:String] {
                return result
            }
            return [:]
        }()
        /** --------------------------------------------------------------------------------------------------------------------------------------------------------------  **/
    }
}
