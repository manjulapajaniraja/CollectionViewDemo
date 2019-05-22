//
//  MovieInfo.swift
//  MovieShowCase
//
//  Created by I309659 on 19/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation
import UIKit

/// This is the base model for Movies Info
struct MovieInfo: Equatable {
    
    var thumbNailURL: String
    var name: String
    var ReleaseDate: String
    var movieId: Int
    var movieThumbnail: UIImage?
    
}
