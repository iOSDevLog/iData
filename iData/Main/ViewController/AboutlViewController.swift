//
//  AboutlViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

class AboutlViewController: UIViewController {
    let iTunesItemIdentifier = ""

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var wechatImage: UIImageView!
    @IBOutlet weak var bunderVersionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let helps = [
        HelpItem(helpName: NSLocalizedString("helpName0", comment: "helpName0"), helpValue: NSLocalizedString("helpValue0", comment: "helpValue0"), helpUrl: "https://www.cn-ki.net"),
        HelpItem(helpName: NSLocalizedString("helpName1", comment: "helpName1"), helpValue: NSLocalizedString("helpValue1", comment: "helpValue1"), helpUrl: "https://github.com/iOSDevLog/iData"),
        HelpItem(helpName: NSLocalizedString("helpName2", comment: "helpName2"), helpValue: NSLocalizedString("helpValue2", comment: "helpValue2"), helpUrl: "https://user.cn-ki.net/usercenter/help"),
        HelpItem(helpName: NSLocalizedString("helpName3", comment: "helpName3"), helpValue: NSLocalizedString("helpValue3", comment: "helpValue3"), helpUrl: nil),
        HelpItem(helpName: NSLocalizedString("helpName4", comment: "helpName4"), helpValue: NSLocalizedString("helpValue4", comment: "helpValue4"), helpUrl: nil),
        HelpItem(helpName: NSLocalizedString("helpName5", comment: "helpName5"), helpValue: NSLocalizedString("helpValue5", comment: "helpValue5"), helpUrl: nil),
        HelpItem(helpName: NSLocalizedString("helpName6", comment: "helpName6"), helpValue: NSLocalizedString("helpValue6", comment: "helpValue6"), helpUrl: "https://github.com/iOSDevLog/iData"),
        HelpItem(helpName: NSLocalizedString("helpName7", comment: "helpName7"), helpValue: NSLocalizedString("helpValue7", comment: "helpValue7"), helpUrl: nil),
        HelpItem(helpName: NSLocalizedString("helpName8", comment: "helpName8"), helpValue: NSLocalizedString("helpValue8", comment: "helpValue8"), helpUrl: "https://www.cn-ki.net"),
        HelpItem(helpName: NSLocalizedString("helpName9", comment: "helpName9"), helpValue: NSLocalizedString("helpValue9", comment: "helpValue9"), helpUrl: nil),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as! String
        let bundleVersion = infoDictionary["CFBundleVersion"] as! String
        
        title = NSLocalizedString("About", comment: "About")
        versionLabel.text = version
        bunderVersionLabel.text = "(\(bundleVersion))"
    }
    
    @IBAction func wechatTaped(_ sender: Any) {
        self.wechatImage.isHidden = true
    }
}

extension AboutlViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return helps.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return helps[section].helpName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)
        
        cell.textLabel?.text = helps[indexPath.section].helpValue
        
        return cell
    }
}

extension AboutlViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let helpItem = helps[indexPath.section]
        
        switch indexPath.section {
        case 0:
            openUrl(urlPath: helpItem.helpUrl)
            break
        case 1:
            openUrl(urlPath: helpItem.helpUrl)
            break
        case 2:
            openUrl(urlPath: helpItem.helpUrl)
            break
        case 3:
            openAppStore()
            break
        case 4:
            break
        case 5:
            break
        case 6:
            openUrl(urlPath: helpItem.helpUrl)
            break
        case 7:
            showReview()
            break
        case 8:
            openUrl(urlPath: helpItem.helpUrl)
            break
        case 9:
            wechatImage.isHidden = !wechatImage.isHidden
            break
        default:
            break
        }
    }
    
    func openUrl(urlPath: String?) {
        if let urlPath = urlPath, let url = URL(string: urlPath) {
            let safariVC = SFSafariViewController.init(url: url)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    func openAppStore() {
        let urlPath = NSLocalizedString("iTunesItemIdentifier", comment: "iTunesItemIdentifier") + iTunesItemIdentifier
        if let appStoreUrl = URL(string: urlPath) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appStoreUrl, options: [:]) { (success) in
                    print(NSLocalizedString("Open iTunes", comment: "Open iTunes"))
                }
            } else {
                UIApplication.shared.openURL(appStoreUrl)
            }
        }
    }
    
    func showReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let storeProductViewContorller = SKStoreProductViewController.init()
            storeProductViewContorller.delegate = self
            storeProductViewContorller.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : iTunesItemIdentifier]) { (result, error) in
                if let error = error {
                    toast(contentView: self.view, message: error.localizedDescription)
                } else {
                    self.present(storeProductViewContorller, animated: true, completion: {
                    })
                }
            }
        }
    }
}

extension AboutlViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        self.dismiss(animated: true) {
            toast(contentView: self.view, message: NSLocalizedString("Thanks", comment: "Thanks"))
        }
    }
}

extension AboutlViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
        }
    }
}
