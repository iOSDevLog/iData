//
//  Constraint.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit

let kSeguePrefix = "Segue"
let kBaseUrl = "https://api.cn-ki.net/openapi/"
let kSearchUrl = kBaseUrl + "search"
let kDocDetailUrl = kBaseUrl + "doc_detail"
let kDUrl = kBaseUrl + "get_durl"

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
