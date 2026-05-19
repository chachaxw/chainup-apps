
extension Bundle {
    static func exs_localBundle() -> Bundle? {
        if let bundlePath = EXSTools.getLocalBundlePath(),let localBundle = Bundle(path: bundlePath) {
            return localBundle
        }
        return nil
    }
}
