//
//  APIType.swift
//  MovieShowCase
//
//  Created by I309659 on 20/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation

protocol Networking: class {
    
    func fetchMoviesListUsing(APIKey: String, forPage: Int, onCompletion: @escaping([Any]) -> Void) -> Bool
    
    func fetchMovieDetailsUsing(movieId: Int, APIKey: String, onCompletion: @escaping ([String: Any]) -> Void) -> Bool
    
    func getImageConfigurationPathForMovieWith(APIKey: String, onCompletion: @escaping ([String: Any]) -> Void) -> Bool
    
}
