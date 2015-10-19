//
//  UIViewRotate.swift
//  VirtualTourist
//
//  Created by Steven on 20/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import UIKit

extension UIView {
    func rotate(duration: CFTimeInterval = 3.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func stopRotate() {
        self.layer.removeAllAnimations()
    }
}
