//
//  DocDetailHeaderCollectionReusableView.swift
//  iData
//
//  Created by iosdevlog on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit

class DocDetailHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: DocDetailHeaderCollectionReusableView.self)
    
    @IBOutlet weak var titleLabel: UILabel!
        
}
