//
//  Pin.swift
//  VirtualTourist
//
//  Created by Steven on 26/08/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import CoreData
import UIKit

@objc(Pin)

class Pin: NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
    /**
    Make a request to Flickr API and load the photos of the selected Pin
    */
    func loadPhotos( context: NSManagedObjectContext!, completionHandler: ( () -> () )? ) {
        FlickrClient.sharedInstance().getPhotos(latitude, lon: longitude) { (results, errorString) -> Void in
            
            if let errorString = errorString {
                println(errorString)
            } else {
                if let photosDictionary = results.valueForKey("photo") as? [[String: AnyObject]] {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var photos = photosDictionary.map() {
                            (dictionary: [String: AnyObject]) -> Photo in
                            
                            let photo = Photo(dictionary: dictionary, context: context)
                            photo.pin = self
                            
                            
                            return photo
                        }
                        
                        completionHandler!()
                    })
                    
                }
            }
            
        }
    }
    
}
