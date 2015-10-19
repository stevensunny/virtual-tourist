//
//  Photo.swift
//  VirtualTourist
//
//  Created by Steven on 26/08/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import CoreData
import UIKit

@objc(Photo)

class Photo: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let ImagePath = "url_m"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var id: Int
    @NSManaged var imagePath: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var title: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID]!.integerValue
        imagePath = dictionary[Keys.ImagePath] as? String
        latitude = dictionary[Keys.Latitude]!.doubleValue
        longitude = dictionary[Keys.Longitude]!.doubleValue
        title = dictionary[Keys.Title] as? String
    }
    
    override func prepareForDeletion() {
        FlickrClient.Caches.imageCache.deleteImageWithIdentifier(imagePath!)
    }
    
    var image: UIImage? {
        get {
            
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
