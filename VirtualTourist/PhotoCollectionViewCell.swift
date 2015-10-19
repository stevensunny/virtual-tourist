//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Steven on 20/09/2015.
//  Copyright (c) 2015 horsemen. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photoImage: UIImageView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
