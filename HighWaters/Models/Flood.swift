//
//  Flood.swift
//  HighWaters
//
//  Created by Techment DEV on 03/03/20.
//  Copyright © 2020 DP. All rights reserved.
//

import Foundation
import Firebase

struct Flood {
    var documentID:String?
    let latitude: Double
    let longitude: Double
    var reportedDate:Date = Date()
}

extension Flood {
    
    init?(_ snapshot:QueryDocumentSnapshot){
        guard let latitude = snapshot["latitude"] as? Double,
        let longitude = snapshot["longitude"] as? Double else {
            return nil
        }
        self.latitude = latitude
        self.longitude = longitude
        self.documentID = snapshot.documentID
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Flood {
    func toDictinary() -> [String:Any] {
        return [
            "latitude" : self.latitude,
            "longitude": self.longitude,
            "reportDate": self.reportedDate.formatAsString()
        ]
    }
}
