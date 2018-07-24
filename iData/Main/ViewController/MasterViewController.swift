//
//  MasterViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import QuickLook

class MasterViewController: UITableViewController {

    var aboutViewController: AboutlViewController? = nil

    var searchController: UISearchController!
    
    var contents = [URL]()
    var currentContent: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            aboutViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? AboutlViewController
        }
        
        // Setup the Search Controller
        let searchStoryboard = UIStoryboard.init(name: "Search", bundle: nil)
        let searchResultsController = searchStoryboard.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchResultsController.searchController = searchController
        searchController.searchResultsUpdater = searchResultsController
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = NSLocalizedString("Search Papers", comment: "Search Papers")
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("SCDB", comment: "SCDB"), NSLocalizedString("CJFQ", comment: "CJFQ"), NSLocalizedString("CDMD", comment: "CDMD"), NSLocalizedString("CIPD", comment: "CIPD"), NSLocalizedString("CCND", comment: "CCND")]
        searchController.searchBar.delegate = searchResultsController
        
        self.tableView.tableFooterView = UIView()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(documentDirectoryDidChange(_:)), name: .documentDirectoryDidChange, object: nil)
        
        refreshData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        refreshData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let content = contents[indexPath.row]
        cell.textLabel!.text = content.lastPathComponent
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let content = contents[indexPath.row]
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: content.path) {
                try? fileManager.removeItem(at: content)
                NotificationCenter.default.post(name: .documentDirectoryDidChange, object: nil)
                contents.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        currentContent = contents[indexPath.row]
        
        let controller =  QLPreviewController.init()
        controller.dataSource = self
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        let navigationController = UINavigationController(rootViewController: controller)
        self.showDetailViewController(navigationController, sender: nil)
    }
    
    private func refreshData() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        contents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        tableView.reloadData()
    }
    
    @objc func documentDirectoryDidChange(_ notification: Notification) {
        refreshData()
    }
}

extension MasterViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return currentContent as QLPreviewItem
    }
}
