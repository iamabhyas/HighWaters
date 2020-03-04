//
//  FloodAnnotations.swift
//  HighWaters
//
//  Created by Techment DEV on 04/03/20.
//  Copyright © 2020 DP. All rights reserved.
//

import Foundation
import MapKit

class FloodAnnotation: MKPointAnnotation {
    let flood : Flood
    
    init(_ flood: Flood) {
        self.flood = flood
    }
}
