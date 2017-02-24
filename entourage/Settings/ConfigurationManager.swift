import Foundation

extension String {
  var userPreferences: String {
    // swiftlint:disable:next force_cast
    return UserDefaults.standard.string(forKey: self)!
  }
}

struct UserStorageKey {
  static let environment = "environment"
  static let APIHostURL = "ApiBaseUrl"
  static let APIKey = "ApiKey"
  static let amazonAccessKey = "AmazonAccessKey"
  static let amazonSecretKey = "AmazonSecretKey"
  static let amazonPictureFolder = "AmazonPictureFolder"
  static let flurryAPIKey = "FlurryAPIKey"
  static let nuanceHostAddress = "NuanceHostAddress"
  static let nuanceAppId = "NuanceAppId"
}

@objc class ConfigurationManager: NSObject {

  static let shared = ConfigurationManager()
  private var plist: NSDictionary?

  private override init() {
    self.plist = ConfigurationManager.plist(name: ConfigurationManager.plistFileName)
  }

  private static var plistFileName: String {
    #if BETA
      return "staging"
    #else
      return "prod"
    #endif
  }

  var environment: NSString {
    return ConfigurationManager.plistFileName as NSString
  }
  
  var amazonAccessKey: NSString {
    return configuration(forKey: UserStorageKey.amazonAccessKey)
  }

  var amazonSecretKey: NSString {
    return configuration(forKey: UserStorageKey.amazonSecretKey)
  }

  var amazonPictureFolder: NSString {
    return configuration(forKey: UserStorageKey.amazonPictureFolder)
  }

  var APIHostURL: NSString {
    return configuration(forKey: UserStorageKey.APIHostURL)
  }

  var APIKey: NSString {
    return configuration(forKey: UserStorageKey.APIKey)
  }

  var flurryAPIKey: NSString {
    return configuration(forKey: UserStorageKey.flurryAPIKey)
  }

  var nuanceHostAddress: NSString {
    return configuration(forKey: UserStorageKey.nuanceHostAddress)
  }

  var nuanceAppId: NSString {
    return configuration(forKey: UserStorageKey.nuanceAppId)
  }

  private func configuration(forKey: String) -> NSString {
    return plist![forKey] as! NSString
  }

  private static func plist(name: String) -> NSDictionary? {
    guard let plistFile = Bundle.main.path(forResource: name, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: plistFile) else {
      return nil
    }
    return plist
  }
}
