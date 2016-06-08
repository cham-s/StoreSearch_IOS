//
//  UIImageView+DownloadImage.swift
//  StoreSearch_IOS
//
//  Created by Chamsidine ATTOUMANI on 6/8/16.
//  Copyright © 2016 StellarTech Media. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadingImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(url) { [weak self] url, response, error in
            if error == nil , let url = url,
                data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                }
            }
            
        }
        downloadTask.resume()
        return downloadTask
    }
}
