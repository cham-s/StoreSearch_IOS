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
    var isLoading = false
    
    // MARK - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        let cellNib = UINib(nibName: TabbleViewIdentifiers.searchResultCell, bundle: nil)
        let cellNotNib = UINib(nibName: TabbleViewIdentifiers.nothingFoundCell, bundle: nil)
        let cellLoadNib = UINib(nibName: TabbleViewIdentifiers.loadingCell, bundle: nil)

        tableview.registerNib(cellNib, forCellReuseIdentifier: TabbleViewIdentifiers.searchResultCell)
        tableview.registerNib(cellNotNib, forCellReuseIdentifier: TabbleViewIdentifiers.nothingFoundCell)
        tableview.registerNib(cellLoadNib, forCellReuseIdentifier: TabbleViewIdentifiers.loadingCell)
        tableview.rowHeight = 80
        tableview.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK - Custom Methods
    
    func urlWithSearchText(searchText: String) -> NSURL {
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func performStoreRequestWithUrl(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    func parseJson(jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func showNetWorkError() {
        let alert = UIAlertController(title: "Whoops...",
                                      message: "There was an error reading from the Itunes store Please try again",
                                      preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(diactionary: [String: AnyObject]) -> [SearchResult] {
        guard let array = diactionary["results"] as? [AnyObject] else {
            print("Expected result array")
            return []
        }
        var searchResults = [SearchResult]()
        for result in array {
            if let result = result as? [String: AnyObject] {
                var searchResult: SearchResult?
                if let wrapperType = result["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parseTrack(result)
                    case "audiobook":
                        searchResult = parseAudioBook(result)
                    case "software":
                        searchResult = parseSoftware(result)
                    default:
                        break
                    }
                } else if let kind = result["kind"] as? String where kind == "ebook"{
                    searchResult = parseEBook(result)
                }
                if let res = searchResult {
                    searchResults.append(res)
                }
            }
        }
        return searchResults
    }
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult =  SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult =  SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult =  SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult =  SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        return searchResult
    }
    
    func kindOfDisplay(kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "sofware": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default:
            return kind
        }
    }
    // MARK - Custom Struct
    struct TabbleViewIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
}






// MARK - Extensions

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableview.reloadData()
            hasSearch = true
            searchResults = [SearchResult]()
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            dispatch_async(queue) {
                let url = self.urlWithSearchText(searchBar.text!)
                if let jsonString = self.performStoreRequestWithUrl(url),
                    let dictionary = self.parseJson(jsonString) {
                    
                    self.searchResults = self.parseDictionary(dictionary)
                    self.searchResults.sortInPlace(<)
                    print("Done!")
                    return
                }
                print("Error!")
            }
        }
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
        return (searchResults.count == 0 || isLoading ? nil : indexPath)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        if !hasSearch {
            return 0
        }
        return (searchResults.count == 0 ? 1 : searchResults.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TabbleViewIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        
        if searchResults.count == 0 {
            return tableview.dequeueReusableCellWithIdentifier(TabbleViewIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier( TabbleViewIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel!.text = "Unkown"
            } else {
                cell.artistNameLabel!.text = String(format: "%@ (%@)", searchResult.artistName, kindOfDisplay(searchResult.kind))
            }
            return cell
        }
    }
}