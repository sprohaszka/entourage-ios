//
//  ApplicationTheme.swift
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class ApplicationTheme: NSObject {
    
    private static var sharedInstance: ApplicationTheme = {
        let sharedInstance = ApplicationTheme()
        return sharedInstance
    }()
    
    @objc class func shared() -> ApplicationTheme {
        return sharedInstance
    }
    
    @objc var primaryNavigationBarTintColor: UIColor = UIColor.white
    @objc var secondaryNavigationBarTintColor: UIColor = UIColor.appOrange()
    @objc var backgroundThemeColor: UIColor = UIColor.appOrange()
    
    @objc class func applicationLogo () -> UIImage {
        if OTAppConfiguration.sharedInstance().environmentConfiguration.applicationType == .voisinAge {
            return UIImage.init(named: "pfp-logo")!
        }
        return UIImage.init(named: "entourageLogo")!
    }
}