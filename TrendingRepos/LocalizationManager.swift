import Foundation

let languageMapping: [String: String] = [
    "English": "en",
    "Spanish": "es",
    "French": "fr",
    "German": "de",
    "Italian": "it",
    "Portuguese": "pt"
]

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {
        let currentLanguage = getCurrentLanguage()
        setLanguage(currentLanguage)
    }
    
    // MARK: - Language Handling
    
    func getCurrentLanguage() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? ""
        let locale = Locale(identifier: preferredLanguage)
        let languageCode = locale.language.languageCode?.identifier ?? ""
        Logger.shared.debug("Getting current language \(preferredLanguage)")
        
        return languageCode.isEmpty ? "English" : languageCode
    }
    
    func getLanguageCodeFor(language: String) -> String {
        Logger.shared.debug("Mapping user language to code")
        return languageMapping[language] ?? "en"
    }

    func setLanguage(_ language: String) {
        Logger.shared.info("Setting new user language \(language)")
        let languageCode = getLanguageCodeFor(language: language)
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Notify observers or reload the UI as needed
        NotificationCenter.default.post(name: Notification.Name("LanguageDidChangeNotification"), object: nil)
        
        // Store the selected language for future use (using UserDefaults or any other persistence mechanism)
        Logger.shared.debug("Setting userdefaults for language to \(languageCode)")
        UserDefaults.standard.set(languageCode, forKey: "SelectedLanguage")
    }
}
