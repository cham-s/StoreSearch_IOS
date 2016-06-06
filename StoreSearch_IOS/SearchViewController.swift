//
//  ViewController.swift
//  StoreSearch_IOS
//
//  Created by cham-s on 05/06/16.
//  Copyright © 2016 StellarTech Media. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    var hasSearch = false
    var searchResults = [SearchResult]()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        let cellNib = UINib(nibName: TabbleViewIdentifiers.searchResultCell, bundle: nil)
        let cellNotNib = UINib(nibName: TabbleViewIdentifiers.nothingFoundCell, bundle: nil)
        tableview.registerNib(cellNib, forCellReuseIdentifier: TabbleViewIdentifiers.searchResultCell)
        tableview.registerNib(cellNotNib, forCellReuseIdentifier: TabbleViewIdentifiers.nothingFoundCell)
        tableview.rowHeight = 80
        tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK - Custom Methods
    
    // MARK - Custom Struct
    struct TabbleViewIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchResults = [SearchResult]()
        if searchBar.text! != "Justin" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
            
        }
        hasSearch = true
        tableview.reloadData()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return (searchResults.count == 0 ? nil : indexPath)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearch {
            return 0
        }
        return (searchResults.count == 0 ? 1 : searchResults.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchResults.count == 0 {
            return tableview.dequeueReusableCellWithIdentifier(TabbleViewIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier( TabbleViewIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            cell.artistNameLabel!.text = searchResult.artistName
            return cell
        }
    }
}

