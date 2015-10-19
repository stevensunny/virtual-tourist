//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Steven on 14/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    var session: NSURLSession

    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Request Methods
    
    func taskForGETMethod(parameters: [String: AnyObject], completionHandler: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Complete parameters
        var mutableParameters = parameters
        mutableParameters["method"] = Methods.SearchPhotos
        mutableParameters["api_key"] = Constants.ApiKey
        mutableParameters["safe_search"] = Constants.SafeSearch
        mutableParameters["extras"] = Constants.Extras
        mutableParameters["format"] = Constants.DataFormat
        mutableParameters["nojsoncallback"] = Constants.NoJsonCallback
        mutableParameters["per_page"] = Constants.PerPage

        // Build URL and configure URLRequest
        let urlString = Constants.BaseURLSecure + FlickrClient.escapedParameters(mutableParameters)
        let url: NSURL = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(results: nil, error: error)
            } else {
                
                // Parse the response data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    completionHandler(results: nil, error: error)
                } else {
                    completionHandler(results: parsedResult, error: nil)
                }
                
            }
        }
        
        task.resume()
        
        return task
        
    }
    
    // MARK: - Helper Methods
    
    /**
    Given a dictionary of parameters, convert to a string for a url
    
    :param: parameters Parameters to be converted
    :returns: String containing the parameters url
    */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /**
    Create bbox string parameter from latitude and longitude
    
    :param: lat latitude
    :param: lon longitude
    
    :returns: string
    */
    class func createBBoxStringFromLatitude(lat: Double, andLongitude lon: Double) -> String {
        let bottom_left_lon = max(lon - Constants.BBoxHalfWidth, Constants.LonMin)
        let bottom_left_lat = max(lat - Constants.BBoxHalfHeight, Constants.LatMin)
        let top_right_lon = min(lon + Constants.BBoxHalfWidth, Constants.LonMax)
        let top_right_lat = min(lat + Constants.BBoxHalfHeight, Constants.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // MARK: - Shared Instance
    
    /**
    Get the shared singleton instance of ParseClient
    */
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}
