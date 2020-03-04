//
//  UIButton+Extensions.swift
//  HighWaters
//
//  Created by Techment DEV on 04/03/20.
//  Copyright © 2020 DP. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    static func buttonForRightAccessoryView() -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 18, height: 22)
        button.setImage(UIImage(imageLiteralResourceName: "711-trash-toolbar"), for:.normal)
        return button
    }
}
