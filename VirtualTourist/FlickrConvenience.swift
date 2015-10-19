//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Steven on 14/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    /**
    Get photos from the given latitude and longitude
    
    :param: lat
    :param: lon
    :param: completionHandler
    */
    func getPhotos(lat: Double, lon: Double, completionHandler: ( results: AnyObject!, errorString: String? ) -> Void ) {
        
        // Construct the bounding box parameters from latitude and longitude
        let parameters = [
            "bbox": FlickrClient.createBBoxStringFromLatitude(lat, andLongitude: lon)
        ]
        
        taskForGETMethod(parameters, completionHandler: { (results, error) -> Void in
            
            if let error = error {
                completionHandler(results: nil, errorString: "FlickrClient: getPhotos Request Failed")
            } else {
                
                if let photosDictionary = results.valueForKey("photos") as? [String:AnyObject] {
                    
                    // Here, we want to randomize the page and make another request. First,
                    // we find out the totalPages available, then pick one page at random
                    // and make the request again.
                    if let totalPages = photosDictionary["pages"] as? Int {
                        
                        // Flickr API will only return up to 4000 images (21 per page * 190 page max)
                        let pageLimit = min(totalPages, 190)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        self.getPhotosForPage(randomPage, parameters: parameters, completionHandler: { (results, error) -> Void in
                            
                            completionHandler(results: results, errorString: nil)
                            
                        })
                        
                    } else {
                        completionHandler(results: nil, errorString: "FlickrClient: getPhotos can't find key 'pages'")
                    }
                    
                } else {
                    completionHandler(results: nil, errorString: "FlickrClient: getPhotos can't find key 'photos'")
                }
            
            }
            
        })
        
    }
    
    /**
    Get photos for the specified page
    
    :param: page
    :param: parameters
    :param: completionHandler
    */
    func getPhotosForPage(page: Int, parameters: [String: AnyObject], completionHandler: ( results: AnyObject!, errorString: String? ) -> Void ) {
        
        var newParameters = parameters
        newParameters["page"] = page
        
        taskForGETMethod(newParameters, completionHandler: { (results, error) -> Void in
            
            if let error = error {
                completionHandler(results: nil, errorString: "FlickrClient: getPhotosForPage Request Failed")
            } else {
                
                if let resultDictionary = results.valueForKey("photos") as? [String:AnyObject] {
                    
                    // Validation - no photo found
                    var totalPhotosVal = 0
                    if let totalPhotos = resultDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        completionHandler(results: resultDictionary, errorString: nil)
                    } else {
                        completionHandler(results: nil, errorString: "FlickrClient: getPhotosForPage no photos found")
                    }
                    
                } else {
                    completionHandler(results: nil, errorString: "FlickrClient: getPhotosForPage can't find key 'photos'")
                }
            
            }
            
        })
        
    }
    
    /**
    Get image data from URL
    
    :param: url
    :param: completion
    
    :returns: NSURLSessionTask
    */
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) -> NSURLSessionTask {
        let task = session.dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }
        
        task.resume()
        
        return task
    }
    
    /**
    Download image
    
    :param: url
    */
    func downloadImage(url: NSURL, completionHandler: (image: UIImage?, errorString: String?) -> Void ) -> NSURLSessionTask {
        
        let task = getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let data = data {
                    if let image = UIImage( data: data ) {
                        completionHandler(image: image, errorString: nil)
                    } else {
                        completionHandler(image: nil, errorString: "Image data invalid")
                    }
                } else {
                    completionHandler(image: nil, errorString: "Error downloading image")
                }

            }
        }
        
        return task
    }
}