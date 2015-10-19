//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Steven on 14/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let BaseURLSecure = "https://api.flickr.com/services/rest/"
        static let ApiKey = "2b11ab62d2c88081a10514b0e0656986"
        
        // Parameters
        static let Extras = "url_m,geo"
        static let SafeSearch = "1"
        static let DataFormat = "json"
        static let NoJsonCallback = "1"
        static let PerPage = "21"
        
        // BBox 
        static let BBoxHalfWidth = 1.0
        static let BBoxHalfHeight = 1.0
        static let LatMin = -90.0
        static let LatMax = 90.0
        static let LonMin = -180.0
        static let LonMax = 180.0
    }
    
    struct Methods {
        static let SearchPhotos = "flickr.photos.search"
    }
    
}