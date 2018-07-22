//
//  SearchTableViewCell.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import DownloadButton

class SearchTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchTableViewCell.self)

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var dataBaseLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var orgnizLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    
    fileprivate func rander(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rander(view: backView)
        rander(view: roundView)
    }
}
