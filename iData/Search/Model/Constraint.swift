//
//  Constraint.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire

let kSeguePrefix = "Segue"
let kBaseUrl = "https://api.cn-ki.net/openapi/"
let kSearchUrl = kBaseUrl + "search"
let kDocDetailUrl = kBaseUrl + "doc_detail"
let kDUrl = kBaseUrl + "get_durl"

let app_id = "iOSDevLog"
let access_token = "C3RoqraAz6nTJBhF"

func html2AttributedString(string: String?) -> NSAttributedString {
    if string == nil {
        return NSAttributedString()
    }
    return try! NSAttributedString(
        data: string!.data(using: .unicode, allowLossyConversion: true)!,
        options:[.documentType: NSAttributedString.DocumentType.html,
                 .characterEncoding: String.Encoding.utf8.rawValue],
        documentAttributes: nil)
}

func changeBackground(view: UIView, image: UIImage) {
    UIGraphicsBeginImageContext(view.bounds.size)
    image.draw(in: view.bounds)
    let newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    view.backgroundColor = UIColor(patternImage: newImage!)
}

func showLoadingHUD(contentView: UIView) {
    let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
    hud.label.text = NSLocalizedString("Loading...", comment: "Loading...")
}

func hideLoadingHUD(contentView: UIView) {
    MBProgressHUD.hide(for: contentView, animated: true)
}

extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}
extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}

func toast(contentView: UIView, message: String) {
    let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
    hud.label.text = message
    hud.mode = .text
    DispatchQueue.main.asyncAfter(deadline: 2) {
        MBProgressHUD.hide(for: contentView, animated: true)
    }
}

func cancelRequest() {
    Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
        sessionDataTask.forEach { $0.cancel() }
        uploadData.forEach { $0.cancel() }
        downloadData.forEach { $0.cancel() }
    }
}
