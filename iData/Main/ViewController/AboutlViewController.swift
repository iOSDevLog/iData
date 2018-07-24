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
        HelpItem(helpName: "iData 官方网站", helpValue: "https://www.cn-ki.net 点击查看。", helpUrl: "https://www.cn-ki.net"),
        HelpItem(helpName: "iData for iOS 开发网站", helpValue: "https://github.com/iOSDevLog/iData 点击查看。", helpUrl: "https://github.com/iOSDevLog/iData"),
        HelpItem(helpName: "iData 简介", helpValue: "iData 是第三方交流学术成果的公益互联网项目，旨在促进知识的传播和最新学术科技的共享，所有信息均来自公开、透明的互联网查询网站，iData 重新对这些信息进行整合和优化，从而高效地输出有用信息，提高人与知识的连接效率。iData 从创建之初便提供免费的学术文献浏览和下载。\n\n 点击查看更多。", helpUrl: "https://www.cn-ki.net"),
        HelpItem(helpName: "iData for iOS 简介", helpValue: "iData 的 iOS 客户端，由 iosdevlog 开发，点击去 App Store 查看。", helpUrl: nil),
        HelpItem(helpName: "下载限制", helpValue: "iData for iOS 目前下载数量没有什么限制。但如果大批量高速调用系统可能会有一定的频率限制。\n在获取最新的文献或者不常使用的文献的时候，下载 和 预览 地址可能为空，这是因为系统需要对当前请求的文献进行同步，同步结束后再次请求便会有值，时间耗时一般在几秒到60秒不等。\n如果下载 和 预览 地址为空，则会打开在线网址。下载 和 预览 有效期为60秒，有效期为24小时。", helpUrl: nil),
        HelpItem(helpName: "可以下载哪些文献", helpValue: "SCDB(综合),CJFQ(期刊),CDMD(博硕),CIPD(会议),CCND(报纸)。\n中文期刊、硕博、会议、报纸全库都可以下载，以及部分的年鉴内容(年鉴需要通过cnki镜像下载)，如果您发现有不能下载的文献，请发邮件至 idata@cn-ki.net 反馈咨询。", helpUrl: nil),
        HelpItem(helpName: "如何捐助", helpValue: "点击查看更多。", helpUrl: "https://github.com/iOSDevLog/iData"),
        HelpItem(helpName: "评分", helpValue: "如果觉得对你有帮助，欢迎点击好评。", helpUrl: nil),
        HelpItem(helpName: "联系 iData", helpValue: "任何建议请发邮件至 idata@cn-ki.net 。个别文献可能会出现数据错误，表现为 pdf 文件打开提示出错，需要向我们反馈以便进行人工处理才能解决。网站打不开，权限有问题，下载不了，无法预览等问题，请加QQ1030457845 注明 iData 用户。", helpUrl: "https://www.cn-ki.net"),
        HelpItem(helpName: "联系 iData for iOS", helpValue: "点击显示二维码，扫描添加微信，或者任何建议请发邮件至 iosdevlog@iosdevlog.com，或者在 https://github.com/iOSDevLog/iData/issues 上提出。", helpUrl: nil),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as! String
        let bundleVersion = infoDictionary["CFBundleVersion"] as! String
        
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
        
        let helpItem = helps[indexPath.row]
        
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
        let urlPath = "itms-apps://itunes.apple.com/us/app/id" + iTunesItemIdentifier
        if let appStoreUrl = URL(string: urlPath) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appStoreUrl, options: [:]) { (success) in
                    print("Open iTunes")
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
            toast(contentView: self.view, message: "Thanks")
        }
    }
}

extension AboutlViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
        }
    }
}
