//
//  DocDetailFotterCollectionReusableView.swift
//  iData
//
//  Created by iosdevlog on 2018/7/18.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import DownloadButton

class DocDetailFooterCollectionReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = String(describing: DocDetailFooterCollectionReusableView.self)
    
    var viewOnlineBlock: (() -> ())?
    var downloadBlock: (() -> ())?

    @IBOutlet weak var viewOnlineButton: UIButton!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    @IBAction func viewOnline(_ sender: Any) {
        viewOnlineBlock?()
    }
}
