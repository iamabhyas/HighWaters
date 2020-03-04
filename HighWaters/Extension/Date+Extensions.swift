//
//  Date+Extensions.swift
//  HighWaters
//
//  Created by Techment DEV on 04/03/20.
//  Copyright © 2020 DP. All rights reserved.
//

import Foundation

extension Date {
    func formatAsString() -> String {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dataFormatter.string(from: self)
    }
}
