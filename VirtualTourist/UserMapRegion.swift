//
//  UserMapRegion.swift
//  VirtualTourist
//
//  Created by Steven on 30/08/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import Foundation
import MapKit

class UserMapRegion {
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UserMapRegion {
        struct Static {
            static let instance = UserMapRegion()
        }
        
        return Static.instance
    }
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    /**
    Save map region to NSUserDefaults
    
    :param: region
    */
    func saveRegion(region: MKCoordinateRegion) {
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta
        
        userDefaults.setDouble(latitude, forKey: "regionLatitude")
        userDefaults.setDouble(longitude, forKey: "regionLongitude")
        userDefaults.setDouble(latitudeDelta, forKey: "regionLatitudeDelta")
        userDefaults.setDouble(latitudeDelta, forKey: "regionLongitudeDelta")
    }
    
    /**
    Get the latest saved map region from NSUserDefaults
    
    :returns: Latest saved region
    */
    func getLatestSavedRegion() -> MKCoordinateRegion? {
        let latitude = userDefaults.doubleForKey("regionLatitude")
        let longitude = userDefaults.doubleForKey("regionLongitude")
        let latitudeDelta = userDefaults.doubleForKey("regionLatitudeDelta")
        let longitudeDelta = userDefaults.doubleForKey("regionLongitudeDelta")
        
        // We want to return nil if this is the first time a user opens this app
        if latitude != 0 && longitude != 0 && latitudeDelta != 0 && longitudeDelta != 0 {
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            return MKCoordinateRegion(center: center, span: span)
        }
        
        return nil
    }
    
}
