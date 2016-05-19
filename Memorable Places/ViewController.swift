//
//  ViewController.swift
//  Memorable Places
//
//  Created by Paco Lee on 2016-05-17.
//  Copyright © 2016 Paco Lee. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            let latDelta: CLLocationDegrees = 0.01
            let lonDelta: CLLocationDegrees = 0.01
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(memorablePlaces[activePlace], span)
            
            self.map.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = memorablePlaces[activePlace]
            annotation.title = memorablePlaceNames[activePlace]
            self.map.addAnnotation(annotation)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action:"action:" )
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.map)
            let newCoordinate: CLLocationCoordinate2D = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
           
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                
                if error == nil {
                    if let p = placemarks?[0] {
                        
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        
                        if p.subThoroughfare != nil {
                            subThoroughfare = p.subThoroughfare!
                        }
                        
                        if p.thoroughfare != nil {
                            thoroughfare = p.thoroughfare!
                        }
                        
                        title = "\(subThoroughfare) \(thoroughfare)"
                    }
                }
                
                if title == " " {
                    title = "Added \(NSDate())"
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)

                
                memorablePlaces.append(newCoordinate)
                memorablePlaceNames.append(title)
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: true)
    }
}

