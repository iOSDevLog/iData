//
//  DocDetailViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import Alamofire

class DocDetailViewController: UIViewController {
    static let viewControllerSegue = String(describing: DocDetailViewController.self) + kSeguePrefix
    var paperItem: PaperItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorStackView: UIStackView!
    @IBOutlet weak var orgnizStackView: UIStackView!
    @IBOutlet weak var journalNameLabel: UILabel!
    @IBOutlet weak var journalInfoLabel: UILabel!
    @IBOutlet weak var journalDateLabel: UILabel!
    @IBOutlet weak var kwsStackView: UIStackView!
    @IBOutlet weak var fundStackView: UIStackView!
    @IBOutlet weak var abstractLabel: UILabel!
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchDocDetail()
    }
    
    func fetchDocDetail() {
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "filename": paperItem!.filename!,
                "dbcode": paperItem!.dbcode!
        ]
        Alamofire.request(kDocDetailUrl, method: .get, parameters: parameters).responseDocDetail { [weak self] response in
            if let docDetail = response.result.value, let docDetailData = docDetail.data {
                print(docDetailData)
                self?.titleLabel.attributedText = html2AttributedString(string: docDetailData.title)
                if let author = docDetailData.author {
                    for item in author {
                        let label = UILabel()
                        label.numberOfLines = 0
                        label.attributedText = html2AttributedString(string: item.name)
                        self?.authorStackView.addArrangedSubview(label)
                    }
                }
                if let orgniz = docDetailData.orgniz {
                    for item in orgniz {
                        let label = UILabel()
                        label.numberOfLines = 0
                        label.attributedText = html2AttributedString(string: item.name)
                        self?.orgnizStackView.addArrangedSubview(label)
                    }
                }
                if let journal = docDetailData.journal {
                    self?.journalNameLabel.attributedText = html2AttributedString(string: journal.name)
                    self?.journalInfoLabel.attributedText = html2AttributedString(string: journal.otherinfo)
                    self?.journalDateLabel.attributedText = html2AttributedString(string: journal.issue!.name)
                }
                if let kws = docDetailData.kws {
                    for item in kws {
                        let label = UILabel()
                        label.numberOfLines = 0
                        label.attributedText = html2AttributedString(string: item)
                        self?.kwsStackView.addArrangedSubview(label)
                    }
                }
                if let fund = docDetailData.fund {
                    for item in fund {
                        let label = UILabel()
                        label.numberOfLines = 0
                        label.attributedText = html2AttributedString(string: item.name)
                        self?.fundStackView.addArrangedSubview(label)
                    }
                }
                self?.abstractLabel.attributedText = html2AttributedString(string: docDetailData.abstract)
            } else {
                print(response.error.debugDescription)
            }
        }
    }
}
