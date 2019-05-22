//
//  MoviesListViewCell.swift
//  MovieShowCase
//
//  Created by I309659 on 20/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation
import  UIKit

class MoviesListCell: UICollectionViewCell {
    
    @IBOutlet weak var movieName: UILabel!
    
    @IBOutlet weak var movieThumbNail: UIImageView!
    
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBAction func getDetails(_ sender: Any) {
        
    }
    
}
