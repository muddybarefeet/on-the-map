//
//  CAGradientLayer.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/23/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        
        let topColor = UIColor(red: (38/255.0), green: (195/255.0), blue: (185/255.0), alpha: 1)
        let bottomColor = UIColor(red: (34/255.0), green: (175/255.0), blue: (166/255.0), alpha: 1)
        
        let gradientColors: Array <AnyObject> = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
}