//
//  OTPfpMenuViewController.swift
//  pfp
//
//  Created by Veronica on 24/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation
import SVProgressHUD

enum menuItemIndexType: NSInteger {
    case addHours = 0
    case contactTeam
    case makeDonnation
    case howTo
    case ethicalChart
    case about
    case logout
}

final class OTPfpMenuViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var tableView = UITableView(frame: .zero, style: .grouped)
    var headerView = OTMenuHeaderView()
    private var menuItems = [OTMenuItem]()
    var currentUser = UserDefaults.standard.currentUser
    
    //MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.loadUser()
        OTAppConfiguration.updateAppearanceForMainTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Private Functions
    
    private func setupUI() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tableView.rowHeight = UITableView.automaticDimension;
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = .white
        tableView.register(OTItemTableViewCell.self, forCellReuseIdentifier: "ItemCellIdentifier")
        tableView.register(OTLogoutViewCell.self, forCellReuseIdentifier: "LogoutItemCellIdentifier")
        
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
    }
    
    private func loadUser() {
        SVProgressHUD.show()
        let authService:OTAuthService = OTAuthService()
        authService.getDetailsForUser(self.currentUser?.uuid, success: { (user:OTUser?) in
            SVProgressHUD.dismiss()
            self.currentUser = user
            self.customizeHeader()
            self.createMenuItems()
            self.tableView.reloadData()
        }) { (error:Error?) in
            SVProgressHUD.dismiss()
            self.customizeHeader()
            self.createMenuItems()
            self.tableView.reloadData()
        }
    }
    
    private func customizeHeader() {
        let editText:String = "Modifier mon profil"
        let normalAttributedText = NSAttributedString(string: editText, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue,
             .foregroundColor: ApplicationTheme.shared().backgroundThemeColor,
             .font:UIFont.SFUIText(size: 14, type: UIFont.SFUITextFontType.regular)])
        let selectedAttributedText = NSAttributedString(string: editText, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue,
             .foregroundColor: ApplicationTheme.shared().titleLabelColor,
             .font:UIFont.SFUIText(size: 14, type: UIFont.SFUITextFontType.regular)])
        headerView.editLabel.setAttributedTitle(normalAttributedText, for: UIControl.State.normal)
        headerView.editLabel.setAttributedTitle(selectedAttributedText, for: UIControl.State.highlighted)
        headerView.editLabel.setAttributedTitle(selectedAttributedText, for: UIControl.State.selected)
        headerView.editLabel.addTarget(self, action: #selector(editProfile), for: UIControl.Event.touchUpInside)
        
        headerView.nameLabel.text = currentUser?.displayName
        
        headerView.profileBtn.setupAsProfilePicture(fromUrl: currentUser?.avatarURL, withPlaceholder: "user")
        headerView.profileBtn.addTarget(self, action: #selector(loadProfile), for: UIControl.Event.touchUpInside)
    }
    
    private func createMenuItems() {
        
        menuItems = [OTMenuItem]()
        let addHoursItem = OTMenuItem(title: String.localized("pfp_menu_add_visitor_hours"),
                                     iconName:"menu-heart")
        addHoursItem?.tag = menuItemIndexType.addHours.rawValue
        
        let contactItem = OTMenuItem(title: String.localized("pfp_menu_contact"),
                                     iconName:"question_chat")
        contactItem?.tag = menuItemIndexType.contactTeam.rawValue
        
        let howIsUsedItem = OTMenuItem(title: String.localized("pfp_menu_how_to"),
                                       iconName: "menu_phone")
        howIsUsedItem?.tag = menuItemIndexType.howTo.rawValue
        
        let chartTitle:String = self.currentUser?.hasSignedEthicsChart() == true ? String.localized("menu_read_chart") : String.localized("menu_sign_chart");
        let ethicalChartItem = OTMenuItem(title: chartTitle,
                                          iconName: "ethicalChart")
        ethicalChartItem?.tag = menuItemIndexType.ethicalChart.rawValue
        
        let aboutItem = OTMenuItem(title: String.localized("aboutTitle"),
                                   iconName:"contact")
        aboutItem?.tag = menuItemIndexType.about.rawValue
        
        let donnationItem = OTMenuItem(title: String.localized("menu_donnation"),
                                       iconName:"star")
        donnationItem?.tag = menuItemIndexType.makeDonnation.rawValue
        
        let logoutItem = OTMenuItem(title: String.localized("menu_disconnect_title"),
                                    iconName: "")
        logoutItem?.tag = menuItemIndexType.logout.rawValue
        
        if self.currentUser?.privateCircles()?.count ?? 0 > 0 {
            menuItems.append(addHoursItem!)
        }
        menuItems.append(contactItem!)
        menuItems.append(donnationItem!)
        menuItems.append(howIsUsedItem!)
        menuItems.append(ethicalChartItem!)
        menuItems.append(aboutItem!)
        menuItems.append(logoutItem!)
    }
    
    private func loadAbout () {
        let vc = PFPAboutViewController.init(nibName: "PFPAboutView", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loadProfile () {
        let vc: OTUserViewController = UIStoryboard.userProfile().instantiateViewController(withIdentifier: "UserProfile") as! OTUserViewController
        vc.hidesBottomBarWhenPushed = true
        vc.userId = self.currentUser?.sid
        let profileNavController:UINavigationController = UINavigationController.init(rootViewController: vc)
        self.present(profileNavController, animated: true, completion: nil)
    }
    
    @objc private func editProfile () {
        let vc: OTUserEditViewController = UIStoryboard.editUserProfile().instantiateViewController(withIdentifier: "OTUserEditViewController") as! OTUserEditViewController
        vc.hidesBottomBarWhenPushed = true
        let editProfileNavController:UINavigationController = UINavigationController.init(rootViewController: vc)
        self.present(editProfileNavController, animated: true, completion: nil)
    }
    
    private func loadUserCircles () {
        let storyboard:UIStoryboard = UIStoryboard.init(name: "PfpUserVoisinage", bundle: nil)
        let vc:UIViewController = storyboard.instantiateViewController(withIdentifier: "PfpUserVoisinageViewController")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func contactPFP() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "", message: "Email not available", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            return
        }
        
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        composeViewController.setToRecipients(["voisin-age@petitsfreresdespauvres.fr"])
        composeViewController.setSubject("")
        composeViewController.setMessageBody("", isHTML: false)
        
        OTAppConfiguration.configureMailControllerAppearance(composeViewController)
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    //MARK:- MFMailComposerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OTPfpMenuViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            headerView.editLabel.isHidden = OTAppConfiguration.supportsProfileEditing() == false
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 180
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let menuItem: OTMenuItem = menuItems[indexPath.section]
        switch menuItem.tag {
        case menuItemIndexType.contactTeam.rawValue:
            self.contactPFP()
            break
        case menuItemIndexType.about.rawValue:
            self.loadAbout()
            break
        case menuItemIndexType.ethicalChart.rawValue:
            let url = URL(string: CHARTE_LINK_FORMAT_PFP + UserDefaults.standard.currentUser.sid.stringValue)
            OTSafariService.launchInAppBrowser(with: url, viewController: self.navigationController)
            break
        case menuItemIndexType.howTo.rawValue:
            let url = OTSafariService.redirectUrl(withIdentifier: "faq")
            OTSafariService.launchInAppBrowser(with: url, viewController: self.navigationController)
            break
        case menuItemIndexType.makeDonnation.rawValue:
            OTSafariService.launchFeedbackForm(in: self.navigationController)
            break
        case menuItemIndexType.addHours.rawValue:
            self.loadUserCircles()
            break
        default:
            NotificationCenter.default.post(name: Notification.Name("loginFailureNotification"),
                                            object: self)
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension OTPfpMenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem: OTMenuItem = menuItems[indexPath.section]
        if menuItem.tag != menuItemIndexType.logout.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier") as! OTItemTableViewCell
            let icon:UIImage = UIImage(named: menuItem.iconName)!
            cell.view.iconImageView.image = icon.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.view.iconImageView.tintColor = UIColor.pfpBlue()
            cell.view.iconImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.view.itemLabel.text = menuItem.title
            cell.backgroundColor = UIColor.pfpTableBackground()
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutItemCellIdentifier") as! OTLogoutViewCell
            cell.logoutButton.setTitle(menuItem.title.uppercased(), for: .normal)
            return cell
        }
    }
}
