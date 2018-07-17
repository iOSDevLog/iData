//
//  DocDetailCollectionViewController.swift
//  iData
//
//  Created by iosdevlog on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import Alamofire

class DocDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    static let viewControllerIdentifier = String(describing: DocDetailCollectionViewController.self)
    static let viewControllerSegue = String(describing: DocDetailCollectionViewController.self) + kSeguePrefix
    
    var paperItem: PaperItem!
    var docData: DocDataClass!
    
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
        
//        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.estimatedItemSize = CGSize(width: 240, height: 50)
//        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize
        
        self.fetchDocDetail()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleString = title(indexPath)
        let attributedString = html2AttributedString(string: titleString)
        
        guard titleString != nil else {
            return CGSize(width: 0, height: 0)
        }
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let padding: CGFloat = 10.0
        
        let boundingRect = attributedString.boundingRect(with: CGSize(width: collectionView.bounds.width - 2*padding, height: 0), options: options, context: nil)
        
        return boundingRect.size
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
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles.count
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
            numberOfItemsInSection = (docData?.title != nil ? 1 : 0)
            break
        case 1:
            numberOfItemsInSection = docData.author?.count ?? 0
            break
        case 2:
            numberOfItemsInSection = docData.orgniz?.count ?? 0
            break
        case 3:
            numberOfItemsInSection = 4   // journal
            break
        case 4:
            numberOfItemsInSection = docData.kws?.count ?? 0
            break
        case 5:
            numberOfItemsInSection = docData.fund?.count ?? 0
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
        var titleString: String? = nil
        
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
        
        return titleString
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocDetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DocDetailCollectionViewCell
        let titleString = title(indexPath)
        
        cell.titleLabel.attributedText =  html2AttributedString(string: titleString)
    
        return cell
    }

}
