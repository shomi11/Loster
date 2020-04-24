//
//  RadiusShadowView.swift
//  Loster
//
//  Created by Malovic, Milos on 4/22/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RadiusShadowView: UIView {
    
    
  @IBInspectable var cornerRadius: Double {
         get {
           return Double(self.layer.cornerRadius)
         }set {
           self.layer.cornerRadius = CGFloat(newValue)
         }
    }
  
    @IBInspectable var borderWidth: Double {
          get {
            return Double(self.layer.borderWidth)
          }
          set {
           self.layer.borderWidth = CGFloat(newValue)
          }
    }
  
    @IBInspectable var borderColor: UIColor? {
         get {
            return UIColor(cgColor: self.layer.borderColor!)
         }
         set {
            self.layer.borderColor = newValue?.cgColor
         }
    }
  
    @IBInspectable var shadowColor: UIColor? {
        get {
           return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
           self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOffSet: CGSize {
        get {
           return self.layer.shadowOffset
        }
        set {
           self.layer.shadowOffset = newValue
       }
    }
 
    @IBInspectable var shadowRadius: Double {
            get {
              return Double(self.layer.shadowRadius)
            }set {
              self.layer.shadowRadius = CGFloat(newValue)
            }
       }
    
    @IBInspectable var shadowOpacity: Float {
        get {
           return self.layer.shadowOpacity
        }
        set {
           self.layer.shadowOpacity = newValue
       }
    }
    
}
