//
//  Post+Mapping.swift
//  LambdaTimeline
//
//  Created by Nikita Thomas on 1/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import MapKit


extension Post: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return geotag!
    }
    
    var geoTitle: String? {
        return title
    }

}
