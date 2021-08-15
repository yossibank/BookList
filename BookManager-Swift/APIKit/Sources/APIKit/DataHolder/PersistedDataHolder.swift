struct PersistedDataHolder {
    @UserDefaultsStorage(key: UserDefaultKey.onboardingFinished)
    static var onboardingFinished: Bool?

    @FileStorage(file: .someFile)
    static var someData: [BookResponse]?
}
