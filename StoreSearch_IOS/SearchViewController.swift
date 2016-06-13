//
//  ViewController.swift
//  StoreSearch_IOS
//
//  Created by cham-s on 05/06/16.
//  Copyright © 2016 StellarTech Media. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    // MARK - Instance variables
    var landscapeViewController: LandscapeViewController?
    let search = Search()
    
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
        tableview.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if case .Results(let list) = search.state {
                let detailViewController = segue.destinationViewController as! DetailViewController
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searResult = searchResult
                
            }
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
                                                  withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection,
                                              withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass {
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinator(coordinator)
        }
    }

    // MARK - Custom Methods
    
    func performStoreRequestWithUrl(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
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
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        precondition(landscapeViewController == nil)
        
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as?
        LandscapeViewController
        
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.bounds = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }, completion: { _ in
                controller.didMoveToParentViewController(self)
            })
        }
    }
    
    func hideLandscapeViewWithCoordinator (coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMoveToParentViewController(nil)
            
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 0
            }, completion: {_ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
            
        }
    }
    
    // MARK - Actionsk
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performsSearch()
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
        performsSearch()
    }
    func performsSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearchForText(searchBar.text!,
                                        category: category, completion: {
                                            sucess in
                                            self.landscapeViewController?.searchResultReceived()
                                            if !sucess {
                                                self.showNetWorkError()
                                            }
                                            self.tableview.reloadData()
            })
            tableview.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NotSearchedYet, .Loading, .NoResults:
            return nil
        case .Results:
            return indexPath
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch search.state {
        case .NotSearchedYet:
            fatalError("Should never get here")
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TabbleViewIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .NoResults:
            return tableview.dequeueReusableCellWithIdentifier(TabbleViewIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier( TabbleViewIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configureForSearchResult(searchResult)
            return cell
        }
    }
}