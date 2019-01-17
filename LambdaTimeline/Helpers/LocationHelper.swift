//
//  LocationHelper.swift
//  LambdaTimeline
//
//  Created by Nikita Thomas on 1/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LocationHelper {
    
    static let shared = LocationHelper()
    
    let locationManager = CLLocationManager()
    
    init() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

}
