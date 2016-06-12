//
//  Search.swift
//  StoreSearch_IOS
//
//  Created by cham-s on 12/06/16.
//  Copyright © 2016 StellarTech Media. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void



class Search {
    var searchResults = [SearchResult]()
    private(set) var state: State = .NotSearchedYet
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Category, completion: SearchComplete) {
        if !text.isEmpty {

            dataTask?.cancel()
            
            state = .Loading
            
            searchResults = [SearchResult]()

            let url = urlWithSearchText(text,
                                        category: category)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                
                var success = false
                self.state = .NotSearchedYet
                if let error = error where error.code == -999 {
                    return
                }
                if let httpResponse = response as? NSHTTPURLResponse
                    where httpResponse.statusCode == 200 {
                    if let data = data, dictionary = self.parseJson(data) {
                        var searchResults = self.parseDictionary(dictionary)
                        if searchResults.isEmpty {
                            self.state = .NoResults
                        } else {
                            searchResults.sortInPlace(<)
                            self.state = .Results(searchResults)
                        }
                        success = true
                    }
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    func urlWithSearchText(searchText: String, category: Category) -> NSURL {
        
        let entityName = category.entityName
        let escapedSearchText =
            searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@",
                               escapedSearchText,
                               entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func parseJson(data: NSData) -> [String: AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parseDictionary(diactionary: [String: AnyObject]) -> [SearchResult] {
        guard let array = diactionary["results"] as? [AnyObject] else {
            return []
        }
        var searchResults = [SearchResult]()
        for result in array {
            if let result = result as? [String: AnyObject] {
                var searchResult: SearchResult?
                if let wrapperType = result["wrapperType"] as? String {
                    // TODO : check why parsing is wrong
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
    
    enum Category: Int {
        case All = 0
        case Music = 1
        case Software = 2
        case EBooks = 3
        
        var entityName: String {
            switch self {
            case .All: return ""
            case .Music: return "musicTrack"
            case .Software: return "software"
            case .EBooks: return "ebook"
            }
        }
    }
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([SearchResult])
    }
}

