//
//  MaterialView.swift
//  WishList
//
//  Created by 徐永宏 on 2017/8/20.
//  Copyright © 2017年 徐永宏. All rights reserved.
//

import UIKit

/**
 * extension can not contain stored property, so declared here
 */
var useMaterial = false

extension UIView {
    
    
    @IBInspectable var applyMaterial: Bool {
        get {
            return useMaterial
        }
        
        set {
            useMaterial = newValue
            
            if useMaterial { // if use meterial style, do some material design change to the view
                layer.masksToBounds = false
                layer.cornerRadius = 3.0
                layer.shadowOpacity = 0.8
                layer.shadowRadius = 3.0
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
            } else { // restore the default style
                layer.cornerRadius = 0
                layer.shadowOpacity = 0
                layer.shadowRadius = 0
                layer.shadowColor = nil
            }
        }
    }
    
}
