//
//  PhotoAlbumController.swift
//  VirtualTourist
//
//  Created by Steven on 10/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
        generateMapAnnotation()
        centerMapRegion()
    }
    
    // MARK: - UI methods
    
    /**
    Configure this screen's UI
    Populate logout, refresh and post location button on navigation item
    */
    func configureUI() {
        // Set navigation buttons
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "processLogout")
        var refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
        var postLocationButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "displayPostStudentLocationModal")
        
        self.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
        self.parentViewController!.navigationItem.rightBarButtonItems = [refreshButton, postLocationButton]
    }
    
    /**
    Put the selectedPin annotation in map
    */
    func generateMapAnnotation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Determine coordinate
            let lat = CLLocationDegrees(self.selectedPin.latitude)
            let long = CLLocationDegrees(self.selectedPin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Construct the annotation, notice that we store the index to subtitle for easy fetching
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Add pin to map
            self.mapView.addAnnotation(annotation)
        })
    }
    
    /**
    Configure the map region to center around the pin
    */
    func centerMapRegion() {
        let center = CLLocationCoordinate2D(latitude: self.selectedPin.latitude, longitude: self.selectedPin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        
        self.mapView.region = MKCoordinateRegion(center: center, span: span)
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - Collection View Delegate & Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = selectedPin.photos[indexPath.row] as Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    /**
    If collection view cell is tapped, we delete the photo
    
    :param: collectionView
    :param: indexPath
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Delete the photo from Core Data
        let photo = selectedPin.photos[indexPath.row] as Photo
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        
        self.collectionView.deleteItemsAtIndexPaths( [indexPath] )
        self.collectionView.reloadData()
    }
    
    /**
    Configure collection view cell photo
    
    :param: cell
    :param: photo
    */
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var image = UIImage(named: "PhotoPlaceholder")
        
        // By default, display the loading picture and rotate the image view
        cell.photoImage!.image = image
        cell.photoImage.rotate()
        
        if photo.image != nil {
            // If image from cache exists, display it immediately
            cell.photoImage.stopRotate()
            cell.photoImage!.image = photo.image
        } else {
            // No image from cache, download the photo
            if let imagePath = photo.imagePath {
                
                if let imageURL = NSURL(string: imagePath) {
                    
                    let task = FlickrClient.sharedInstance().downloadImage(imageURL, completionHandler: { (image, errorString) -> Void in
                        
                        if let error = errorString {
                            println("Error downloading image")
                        } else {
                            photo.image = image
                            
                            // Upon download completion, display the photo
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.photoImage.stopRotate()
                                cell.photoImage!.image = image
                            }
                        }
                    })
                    
                    cell.taskToCancelifCellIsReused = task
                    
                } else {
                    println("Error parsing image URL")
                }
                
            }
        }
        
    }

    
    // MARK: - MKMapView Delegate Methods
    
    /**
    Annotations / Pin configurations
    */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinColor = .Red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: - Button Actions
    
    /**
    Download new photos
    
    :param: sender
    */
    @IBAction func downloadNewCollection(sender: UIButton) {
        // Delete ALL the current photos
        for photo in selectedPin.photos {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Initiate loadPhotos again
        self.selectedPin.loadPhotos(sharedContext) {
            CoreDataStackManager.sharedInstance().saveContext()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.reloadData()
            })
        }
    }
    
}


