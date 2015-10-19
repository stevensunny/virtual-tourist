//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Steven on 19/08/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editMessageView: UIView!
    
    /// Store the pins object
    var pins: [Pin]!
    
    /// Store the pin annotations
    var pinAnnotations = [MKPointAnnotation]()
    
    /// When the delete mode is ON, tapped pin will be deleted
    var deleteMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restoreMapRegion()
        addLongPressGestureToMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
        
        generateMapAnnotations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - UI Methods
    func configureUI() {
        self.navigationItem.title = "Virtual Tourist"
    }
    
    // MARK: - Core Methods
    
    /**
    Restore the last saved map region if exists
    */
    func restoreMapRegion() {
        if let savedRegion = UserMapRegion.sharedInstance().getLatestSavedRegion() {
            mapView.region = savedRegion
        }
    }
    
    /**
    Add a long press gesture recognizer for map. This will allow user to drop Pin
    */
    func addLongPressGestureToMap() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    /**
    Generate annotations in Map with the Pin data stored in database
    */
    func generateMapAnnotations() {
        dispatch_async( dispatch_get_main_queue() ) {
            
            // Empty the map annotations
            self.mapView.removeAnnotations( self.pinAnnotations )
            self.pinAnnotations = [MKPointAnnotation]()
            
            self.pins = self.fetchAllPins()
            
            for (index, pin) in enumerate(self.pins) {
                
                // Determine coordinate
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Construct the annotation, notice that we store the index to subtitle for easy fetching
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.subtitle = String(index)
                
                // Add it to class variable for easy delete
                self.pinAnnotations.append(annotation)
                
                // Add pin to map
                self.mapView.addAnnotation(annotation)
                
            }
        }
    }
    
    /**
    Drop pin on the map
    
    :param: sender
    */
    func dropPin(sender: UIGestureRecognizer) {
        // Do not allow multiple pins to be dropped from 1 long press
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        // Get the location coordinate
        let point: CGPoint = sender.locationInView(self.mapView)
        let locationCoordinate: CLLocationCoordinate2D = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
        
        // Persist Pin data
        let pinDictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: locationCoordinate.latitude,
            Pin.Keys.Longitude: locationCoordinate.longitude
        ]
        let pinObject = Pin(dictionary: pinDictionary, context: self.sharedContext)
        
        pinObject.loadPhotos(self.sharedContext) {
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        
        // Store the pin Object to class variable for easy delete
        self.pins.append(pinObject)
        
        // Create annotation and add it to the map, notice that we store the index to subtitle for easy fetching
        let pinAnnotation: MKPointAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = locationCoordinate
        pinAnnotation.subtitle = String( self.pins.count - 1 )
        
        // Add pin to class variable for easy delete
        self.pinAnnotations.append(pinAnnotation)
        
        self.mapView.addAnnotation(pinAnnotation)
    }

    /**
    Activate the edit / delete mode. In this mode, pin tapped will be deleted
    
    :param: sender
    */
    @IBAction func editAction(sender: UIBarButtonItem) {
        if ( self.editButton.title == "Edit") {
            self.deleteMode = true
            self.editButton.title = "Done"
            
            // We slide up the editMessageView
            UIView.animateWithDuration(0.2, animations: {
                self.mapView.frame.origin.y -= 60
                self.editMessageView.frame.origin.y -= 60
            })
        } else {
            self.deleteMode = false
            self.editButton.title = "Edit"
            
            // We slide down the editMessageView
            UIView.animateWithDuration(0.2, animations: {
                self.mapView.frame.origin.y += 60
                self.editMessageView.frame.origin.y += 60
            })
        }
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    /**
    Fetch all pins from the database
    
    :returns: Array of Pins
    */
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        if error != nil {
            println("Error in fetchAllPins(): \(error)")
        }
        return results as! [Pin]
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
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    /**
    When a region changed, we persist the latest region
    
    :param: mapView
    :param: animated
    */
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        UserMapRegion.sharedInstance().saveRegion(mapView.region)
    }
    
    /**
    Handle pin tapped. If deleteMode is ON, then we delete the pin
    If deleteMode is OFF, then we navigate to Photo Album view
    
    :param: mapView
    :param: view
    */
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {

        if deleteMode {
            
            // Delete Mode is ON, we delete the pin
            if let indexString = view.annotation.subtitle {
                let index = indexString.toInt()!
                
                // Remove pin from map
                self.mapView.removeAnnotation(self.pinAnnotations[index])
                
                // Delete object from CoreData
                sharedContext.deleteObject(self.pins[index])
                CoreDataStackManager.sharedInstance().saveContext()
            
            }
            
        } else {
            
            // Delete mode is OFF, we navigate to Photo Album view
            self.performSegueWithIdentifier("showPhotoAlbum", sender: view)
            
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.title = nil
        
        if segue.identifier == "showPhotoAlbum" {
            // Set the navigation item title to OK so that the back button 
            // in PhotoAlbum Controller will show '< OK'
            self.navigationItem.title = "OK"
            
            let photoAlbumController: PhotoAlbumController = segue.destinationViewController as! PhotoAlbumController
            
            let annotationView = sender as! MKAnnotationView
            let index = annotationView.annotation.subtitle!.toInt()
            let selectedPin = self.pins[index!]

            photoAlbumController.selectedPin = selectedPin
        }
    }


}

