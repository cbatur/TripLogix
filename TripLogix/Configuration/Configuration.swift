
import Foundation

enum Configuration {
    
    static let accessToken = "35433@!D65HW66$$bTT2854SSpw!A"
    static let isMock: Bool = false
    static let facebookLoginDisabled: Bool = true
    static let googleLoginDisabled: Bool = true
    
    
    enum TripLogix {
        static let baseUrlTemp = "https://palamana.com/TripLogix/"
        static let baseURL = "https://triplogix.app/api/"
        static let baseAdminURL = "https://triplogix.app/admin/php_hooks/"
    }

    enum openAI {
        static let baseUrl = "https://api.openai.com/v1/"
        static let keyHex = "56a8913384b58750a548f8636d13060170249d393fecfe40c039e19b589d7e37"
        static let ivHex = "0adb5939d04f75262d5006d3c5d80e7f"
        static let encryptedBase64 = "53MRYmA5dFF/zlrptbKdlULfEgbo2oJvI84MW+fbIPngPlw8rQw1Wh0GddStM9ud2PG5iQ1IoifkyeqWUm+e7g=="
    }
    
    enum AvionEdge {
        static let keyHex = "07add357ad093ca49427d5d921b54a285d06dccdfadf037c6f68c6161ee00eda"
        static let ivHex = "580f515623c9ca31553b37b1012f7197"
        static let encryptedBase64 = "hOmzigNnj3CtjR6ilKN1rg=="
    }
    
    enum SkyScrapper {
        static let apiHost = "sky-scanner3.p.rapidapi.com"
        static let keyHex = "cdc0634f6e5a9eeb3ef63593b349aa7692051c9b8f5554d9df2248f54cd56b8e"
        static let ivHex = "e625c3f91e54630046f650be28f036e2"
        static let encryptedBase64 = "YXk01C/L8vmD+J2BhAoymirGB97+qYSTd3i4+Lq4nwQTpcM1fzJ54+Ka8xFTAvovPW4JVFBjvCQUJyU8J1jDlg=="
    }
    
    enum GooglePlaces {
        static let baseUrl = "https://maps.googleapis.com/maps/api/"
        static let newBaseUrl = "https://places.googleapis.com/v1/"
        static let keyHex = "8fe0ccdfc3977c5f5a0f39b137d65571a8d3049509f7ac70a05bd05ac2afb100"
        static let ivHex = "65c833266ac46d87a95986126daeffdf"
        static let encryptedBase64 = "LZyOnAOj81/9h6wDQL9QRZgqDPt/4S36UKGQthKdorWYHAHhbnILqNRn6ak12yeM"
    }
    
    enum Links {
        static let agreementsTitle = "Terms and Agreements"
        static let privacyTitle = "Privacy Policy"
        static let rateThisAppTitle = "Rate This App"
    }
}
