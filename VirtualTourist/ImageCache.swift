//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)

        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {
            }
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    // MARK: - Delete images
    
    func deleteImageWithIdentifier( identifier: String ) {
        let path = pathForIdentifier(identifier)
        
        inMemoryCache.removeObjectForKey(path)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
        }
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(imagePath: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
        
        // The image path that we got from Flickr contains URL string. We need to parse this to regular string so that 
        // we can save it as a file
        let urlComponents = NSURLComponents(string: imagePath)
        let urlPath = urlComponents!.percentEncodedPath
        let identifier = urlPath!.stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}