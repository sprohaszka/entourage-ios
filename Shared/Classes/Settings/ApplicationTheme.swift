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
    
    @objc var primaryNavigationBarTintColor: UIColor = UIColor.appOrange()
    @objc var secondaryNavigationBarTintColor: UIColor = UIColor.white
    @objc var backgroundThemeColor: UIColor = UIColor.appOrange()
    @objc var addActionButtonColor: UIColor = UIColor.appOrange()
    @objc var tableViewBackgroundColor: UIColor = UIColor.groupTableViewBackground
    @objc var titleLabelColor: UIColor = UIColor.appGreyishBrown()
    @objc var subtitleLabelColor: UIColor = UIColor.appPaleGrey()
}
