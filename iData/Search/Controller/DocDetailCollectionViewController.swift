//
//  DocDetailCollectionViewController.swift
//  iData
//
//  Created by iosdevlog on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

class DocDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    static let viewControllerIdentifier = String(describing: DocDetailCollectionViewController.self)
    static let viewControllerSegue = String(describing: DocDetailCollectionViewController.self) + kSeguePrefix
    
    var paperItem: PaperItem!
    var docData: DocDataClass!
    var dUrl: DURL?
    
    let titles = [
        "title",
        "author",
        "journal",
        "orgniz",
        "kws",
        "fund",
        "abstract",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeBackground(view: collectionView!, image: #imageLiteral(resourceName: "paper"))
        
        self.fetchDocDetail()
        self.fetchDURL()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleString = title(indexPath)
        let attributedString = html2AttributedString(string: titleString)
        
        guard titleString != nil else {
            return CGSize(width: 0, height: 0)
        }
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let padding: CGFloat = 10.0
        
        let boundingRect = attributedString.boundingRect(with: CGSize(width: collectionView.bounds.width - 3*padding, height: 0), options: options, context: nil)
        
        return CGSize(width: boundingRect.size.width + padding, height: boundingRect.size.height + padding)
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
                self?.docData = docDetailData
                self?.collectionView?.reloadData()
            } else {
                print(response.error.debugDescription)
            }
        }
    }
    
    func fetchDURL() {
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "filename": paperItem?.filename as Any,
                "filename_en": paperItem?.filenameEn as Any,
                "title": paperItem?.title as Any,
                "author": paperItem?.author as Any,
                "tablename": paperItem?.tablename as Any
        ]
        Alamofire.request(kDUrl, method: .get, parameters: parameters).responseDURL { [weak self] response in
            if let dUrl = response.result.value {
                self?.dUrl = dUrl
                if let isPdf = dUrl.data?.isPDF {
                    self?.title = isPdf ? "is not Pdf" : "is Pdf"
                }
                self?.collectionView?.reloadData()
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == titles.count - 1 {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        
        return CGSize(width: 0, height: 0)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            let docDetailHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: DocDetailHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! DocDetailHeaderCollectionReusableView
            docDetailHeaderCollectionReusableView.titleLabel.text = titles[indexPath.section]
            reusableview = docDetailHeaderCollectionReusableView
        } else if kind == UICollectionElementKindSectionFooter {
            let docDetailFooterCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                                        withReuseIdentifier: DocDetailFooterCollectionReusableView.reuseIdentifier, for: indexPath) as! DocDetailFooterCollectionReusableView
            
            docDetailFooterCollectionReusableView.viewOnlineButton.layer.masksToBounds = true
            docDetailFooterCollectionReusableView.downloadButton.layer.masksToBounds = true
            docDetailFooterCollectionReusableView.viewOnlineButton.layer.cornerRadius = 10
            docDetailFooterCollectionReusableView.downloadButton.layer.cornerRadius = 10
            docDetailFooterCollectionReusableView.viewOnlineButton.layer.borderWidth = 1
            docDetailFooterCollectionReusableView.downloadButton.layer.borderWidth = 1
            docDetailFooterCollectionReusableView.viewOnlineButton.layer.borderColor = UIColor.black.cgColor
            docDetailFooterCollectionReusableView.downloadButton.layer.borderColor = UIColor.black.cgColor
            
            docDetailFooterCollectionReusableView.viewOnlineBlock = {
                var previewURL = self.dUrl?.data?.previewURL
                if (previewURL == nil) || previewURL!.isEmpty {
                    previewURL = self.dUrl?.data?.url
                }
                
                if let previewURL = previewURL {
                    if let url = URL(string: previewURL) {
                        let safariVC = SFSafariViewController.init(url: url)
                        safariVC.delegate = self
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }
            }
            
            docDetailFooterCollectionReusableView.downloadBlock = {
                
                var durl = self.dUrl?.data?.durl
                if (durl == nil) || durl!.isEmpty {
                    durl = self.dUrl?.data?.url
                }
                
                if let durl = durl,  let url = URL(string: durl) {
                    let safariVC = SFSafariViewController.init(url: url)
                    safariVC.delegate = self
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
            
            reusableview = docDetailFooterCollectionReusableView
        }
        
        return reusableview
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItemsInSection = 0
        guard docData != nil else {
            return numberOfItemsInSection
        }
        
        switch section {
        case 0:
            numberOfItemsInSection = 1
            break
        case 1:
            numberOfItemsInSection = docData.author?.count ?? 1
            break
        case 2:
            numberOfItemsInSection = docData.orgniz?.count ?? 1
            break
        case 3:
            numberOfItemsInSection = 4   // journal
            break
        case 4:
            numberOfItemsInSection = docData.kws?.count ?? 1
            break
        case 5:
            numberOfItemsInSection = docData.fund?.count ?? 1
            break
        case 6:
            numberOfItemsInSection = 1 // abstract
            break
        default:
            break
        }
        
        return numberOfItemsInSection
    }

    fileprivate func title(_ indexPath: IndexPath) -> String? {
        var titleString: String? = "None"
        
        switch indexPath.section {
        case 0:
            titleString = docData.title
            break
        case 1:
            titleString = docData.author?[indexPath.item].name
            break
        case 2:
            titleString = docData.orgniz?[indexPath.item].name
            break
        case 3:
            if let journal = docData.journal {
                switch indexPath.item {
                case 0:
                    titleString = journal.name
                    break
                case 1:
                    titleString = journal.titleEnglish
                    break
                case 2:
                    titleString = journal.otherinfo
                    break
                case 3:
                    titleString = journal.issue?.name
                    break
                default:
                    break
                }
            }
            break
        case 4:
            titleString = docData.kws?[indexPath.item]
            break
        case 5:
            titleString = docData.fund?[indexPath.item].name
            break
        case 6:
            titleString = docData.abstract
            break
        default:
            break
        }
        
        if titleString == nil {
            titleString = "None"
        }
        
        return titleString
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocDetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DocDetailCollectionViewCell
        let titleString = title(indexPath)
        
        cell.titleLabel.attributedText =  html2AttributedString(string: titleString)
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
    
        return cell
    }

}

extension DocDetailCollectionViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
        }
    }
}
