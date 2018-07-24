//
//  DocDetailViewController.swift
//  iData
//
//  Created by iosdevlog on 2018/7/22.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import DownloadButton
import QuickLook
import MBProgressHUD

class DocDetailViewController: UIViewController {
    static let viewControllerIdentifier = String(describing: DocDetailViewController.self)
    static let viewControllerSegue = String(describing: DocDetailViewController.self) + kSeguePrefix
    
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    @IBOutlet weak var previewButton: PKDownloadButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewButton.startDownloadButton.cleanDefaultAppearance()
        self.previewButton.downloadedButton.cleanDefaultAppearance()
        self.previewButton.startDownloadButton.setTitle("Preview", for: .normal)
        self.previewButton.startDownloadButton.setTitleColor(UIColor.white, for: .normal)
        self.previewButton.downloadedButton.setTitle("Preview", for: .normal)
        self.previewButton.downloadedButton.setTitleColor(UIColor.white, for: .normal)
        self.previewButton.layer.masksToBounds = true
        self.previewButton.layer.cornerRadius = 10
        self.previewButton.layer.borderWidth = 1
        self.previewButton.layer.borderColor = UIColor.blue.cgColor
        
        self.downloadButton.startDownloadButton.cleanDefaultAppearance()
        self.downloadButton.downloadedButton.cleanDefaultAppearance()
        self.downloadButton.startDownloadButton.setTitle("Download", for: .normal)
        self.downloadButton.startDownloadButton.setTitleColor(UIColor.white, for: .normal)
        self.downloadButton.downloadedButton.setTitle("Open", for: .normal)
        self.downloadButton.downloadedButton.setTitleColor(UIColor.white, for: .normal)
        self.downloadButton.layer.masksToBounds = true
        self.downloadButton.layer.cornerRadius = 10
        self.downloadButton.layer.borderWidth = 1
        self.downloadButton.layer.borderColor = UIColor.blue.cgColor
        
        self.previewButton.delegate = self
        self.downloadButton.delegate = self
        self.fetchDocDetail()
    }
    
    func fetchDocDetail() {
        let parameters: Parameters = [
                "app_id": app_id,
                "access_token": access_token,
                "filename": paperItem!.filename!,
                "dbcode": paperItem!.dbcode!
        ]
        
        cancelRequest()
        
        showLoadingHUD(contentView: view)
        Alamofire.request(kDocDetailUrl, method: .get, parameters: parameters).responseDocDetail { [weak self] response in
            guard let strongSelf = self else { return }
            hideLoadingHUD(contentView: strongSelf.view)
            
            switch response.result {
            case.failure(let error):
                let error = error as NSError
                let isCancelled  = error.userInfo["NSLocalizedDescription"].debugDescription.contains("cancelled")
                
                if !isCancelled {
                    toast(contentView: strongSelf.view, message: "NetworkError")
                    print(response.error.debugDescription)
                }
                break
            case .success(let docDetail):
                if let docDetailData = docDetail.data {
                    strongSelf.docData = docDetailData
                    strongSelf.collectionView?.reloadData()
                } else {
                    toast(contentView: strongSelf.view, message: "NetworkError")
                    print(response.error.debugDescription)
                }
                break
            }
        }
        
        
    }
    
    fileprivate func setionTitle(_ indexPath: IndexPath) -> String? {
        var titleString: String? = "None"
        
        switch indexPath.section {
        case 0:
            titleString = docData.title
            break
        case 1:
            if let author = docData.author, author.count > indexPath.item  {
                titleString = author[indexPath.item].name
            }
            break
        case 2:
            if let orgniz = docData.orgniz, orgniz.count > indexPath.item  {
                titleString = orgniz[indexPath.item].name
            }
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
            if let kwd = docData.kws, kwd.count > indexPath.item {
                titleString = kwd[indexPath.item]
            }
            break
        case 5:
            if let fund = docData.fund, fund.count > indexPath.item  {
                titleString = fund[indexPath.item].name
            }
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
    
    func fetchDURL(downloadedButton: PKDownloadButton, shouldDownload: Bool) {
        let parameters: Parameters = [
                "app_id": app_id,
                "access_token": access_token,
                "filename": paperItem!.filename!,
                "filename_en": paperItem!.filenameEn!,
                "title": paperItem!.title!,
                "author": paperItem!.author!,
                "tablename": paperItem!.tablename!
        ]
        showLoadingHUD(contentView: self.view)
        Alamofire.request(kDUrl, method: .get, parameters: parameters).responseDURL { [weak self] response in
            guard let strongSelf = self else { return }
            hideLoadingHUD(contentView: strongSelf.view)
            if let dUrl = response.result.value {
                strongSelf.dUrl = dUrl
                if shouldDownload {
                    if let isPdf = dUrl.data?.isPDF {
                        downloadedButton.state = .downloading;
                        
                        strongSelf.startDownload(url: (dUrl.data?.durl)!, downloadedButton: downloadedButton)
                        if isPdf {
                            downloadedButton.downloadedButton.setImage(#imageLiteral(resourceName: "PDF"), for: .normal)
                        }
                    } else {
                        downloadedButton.state = .downloaded;
                        strongSelf.preview()
                    }
                } else {
                    downloadedButton.state = .downloaded;
                    strongSelf.preview()
                }
            }
        }
    }
    
    func preview() {
        var previewURL = self.dUrl?.data?.previewURL
        if (previewURL == nil) || previewURL!.isEmpty {
            previewURL = self.dUrl?.data?.url
        }
        
        if let previewURL = previewURL, let url = URL(string: previewURL) {
            let safariVC = SFSafariViewController.init(url: url)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func showPdf() {
        let previewController = QLPreviewController.init()
        previewController.dataSource = self
        previewController.delegate = self
        self.show(previewController, sender: nil)
    }
    
    func startDownload(url: String, downloadedButton: PKDownloadButton) {
        let destination: DownloadRequest.DownloadFileDestination = { [weak self] _, _ in
            let strongSelf = self
            return (strongSelf!.fileURL(), [.removePreviousFile, .createIntermediateDirectories])
        }
        
        cancelRequest()
        
        Alamofire.download(url, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
                downloadedButton.stopDownloadButton.progress = CGFloat(progress.fractionCompleted)
                if (progress.fractionCompleted == 1.0) {
                    downloadedButton.state = .downloaded;
                }
            }
            .responseData { [weak self]  response in
                guard let strongSelf = self else { return }
                
                switch response.result {
                case.failure(let error):
                    let error = error as NSError
                    let isCancelled  = error.userInfo["NSLocalizedDescription"].debugDescription.contains("cancelled")
                    
                    if !isCancelled {
                        downloadedButton.state = .startDownload
                        toast(contentView: strongSelf.view, message: "DownloadError")
                    }
                    break
                case .success:
                    strongSelf.showPdf()
                    break
                }
        }
    }
}

// MARK: UICollectionViewDataSource

extension DocDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItemsInSection = 0
        guard docData != nil else {
            return numberOfItemsInSection
        }
        
        switch section {
        case 0:
            numberOfItemsInSection = 1
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
        
        if numberOfItemsInSection == 0 {
            numberOfItemsInSection = 1
        }
        
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView = UICollectionReusableView.init()
        
        if kind == UICollectionElementKindSectionHeader {
            let docDetailHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                                        withReuseIdentifier: DocDetailHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! DocDetailHeaderCollectionReusableView
            docDetailHeaderCollectionReusableView.titleLabel.text = titles[indexPath.section]
            reusableview = docDetailHeaderCollectionReusableView
        } else if kind == UICollectionElementKindSectionFooter {
            reusableview = UICollectionReusableView.init()
        }
        
        return reusableview
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocDetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DocDetailCollectionViewCell
        let titleString = setionTitle(indexPath)
        
        cell.titleLabel.attributedText =  html2AttributedString(string: titleString)
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        
        return cell
    }

}

extension DocDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleString = setionTitle(indexPath)
        let attributedString = html2AttributedString(string: titleString)
        
        guard titleString != nil else {
            return CGSize(width: 0, height: 0)
        }
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let padding: CGFloat = 5
        
        let boundingRect = attributedString.boundingRect(with: CGSize(width: collectionView.bounds.width - 2*padding, height: 0), options: options, context: nil)
        
        return CGSize(width: boundingRect.size.width + 2*padding, height: boundingRect.size.height + 2*padding)
    }
}

extension DocDetailViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
        }
    }
}

extension DocDetailViewController: PKDownloadButtonDelegate {
    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch state {
        case .startDownload:
            downloadButton.state = .pending
            var shouldDownload = false
            if downloadButton == self.downloadButton {
                shouldDownload = true
            }
            self.fetchDURL(downloadedButton: downloadButton, shouldDownload: shouldDownload)
            break;
        case .pending:
            downloadButton.state = .startDownload;
            break;
        case .downloading:
            downloadButton.state = .startDownload;
            break;
        case .downloaded:
            if downloadButton == self.downloadButton {
                showPdf()
            } else {
                preview()
            }
            break;
        }
    }
}

extension DocDetailViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL() as QLPreviewItem
    }
    
    func fileURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = self.paperItem.title!.appending(".pdf")
        return documentsURL.appendingPathComponent(fileName)
    }
}
