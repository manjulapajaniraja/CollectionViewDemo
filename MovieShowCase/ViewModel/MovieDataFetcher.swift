//
//  MovieDataFetcher.swift
//  MovieShowCase
//
//  Created by I309659 on 20/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation

/// This class is the ViewModel part. This coordinates between View, Model and Networking layer.

class MovieDataFetcher {
    
    private let apiKey = "f431c1b1edf865a86ff909312b273b51"
    
    typealias CompletionBlockArrayType = ([Any]) -> Void
    typealias CompletionBlockDictType = ([String:Any]) -> Void
    
    /// This struct holds the keys used for parsing data from movies list array.
    private struct MoviesListModelKeys {
        
        static let imageurl = "poster_path"
        static let name = "title"
        static let releaseDate = "release_date"
        static let movieid = "id"
        
    }
    
    /// This struct holds the keys used for parsing data from movies list array.
    private struct MovieDetailsModelKeys {
        
        static let imageurl = "backdrop_path"
        static let name = "title"
        static let releaseDate = "release_date"
        static let movieid = "id"
        static let synopsis = "overview"
        static let adult = "adult"
        static let genre = "genre"
        static let rating = "vote_average"
        
        
    }
    
    private struct ConfigDetailKeys {
        
        static let postersizes = "poster_sizes"
        static let backdropsizes = "backdrop_sizes"
        static let secureBaseURL = "secure_base_url"
    }
    
    var networkingDelegate: Networking?
    var uiUpdateDelegate: UIUpdater?
    private var moviesInfo: [MovieInfo]?
    private var movieDetails: MoviesDetails?
    // default thumbnail query url
    private var thumbnailConfig: String?
    private var backdropURL: String?
    
    init(networkingDelegate: Networking?) {
        self.networkingDelegate = networkingDelegate
    }
    
    /// This Method asks the Network layer to send the query to fetch movies list and updates the model once response is received.
    ///
    /// - Parameter forPage: page number for data to be fetched
    /// - Returns: returns true if request is success
    func fetchMoviesList(forPage: Int) -> Bool {
        let completionHandler: CompletionBlockArrayType = { (Result) -> Void in
            if self.updateMoviesListModel(data: Result) {
                DispatchQueue.main.async {
                    self.uiUpdateDelegate?.updateUI()
                }
            }
        }
        return networkingDelegate?.fetchMoviesListUsing(APIKey: apiKey, forPage: forPage , onCompletion: completionHandler) ?? false
        
    }
    
    /// This Method asks the Network layer to send the query to fetch movies list and updates the model once response is received.
    ///
    /// - Parameter forPage: page number for data to be fetched
    /// - Returns: returns true if request is success
    func fetchMovieDetailsFor(movieId: Int) -> Bool {
        let completionHandler: CompletionBlockDictType = { (Result) -> Void in
            if self.updateMovieDetailsModel(data: Result) {
                DispatchQueue.main.async {
                    self.uiUpdateDelegate?.updateUI()
                }
            }
        }
        return networkingDelegate?.fetchMovieDetailsUsing(movieId: movieId, APIKey: apiKey, onCompletion: completionHandler) ?? false
        
    }
    
    /// This method asks the network layer to fetch the configuration details for sending thumbnail query.
    ///
    /// - Returns: returns true if query is successful
    func fetchMovieThumbnailConfig() -> Bool {
     //   thumbnailConfig = ""
        return networkingDelegate?.getImageConfigurationPathForMovieWith(APIKey: apiKey, onCompletion: {[weak self] result -> Void in
            self?.thumbnailConfig = self?.thumbnailConfig ?? "" + (result[ConfigDetailKeys.secureBaseURL] as? String ?? "")
             self?.backdropURL = self?.backdropURL ?? "" + (result[ConfigDetailKeys.secureBaseURL] as? String ?? "")
            let posterSizes: [String] = result[ConfigDetailKeys.postersizes] as? [String] ?? []
            let backdropSizes: [String] = result[ConfigDetailKeys.backdropsizes] as? [String] ?? []
            guard posterSizes.count > 0 else {
                return
            }
            self?.thumbnailConfig = (self?.thumbnailConfig ?? "") + posterSizes[4]
            guard backdropSizes.count > 0 else {
                return
            }
            self?.backdropURL = (self?.backdropURL ?? "") + backdropSizes[0]
        }) ?? false
    }
    
    // MARK: Getters for Movies Models
    
    func getMovieDetails() -> MoviesDetails? {
        return movieDetails        
    }
    
    func getMoviesList() -> [MovieInfo] {
        return moviesInfo ?? [MovieInfo]()
    }
    
    func getThumbnailConfigURL() -> String {
        return thumbnailConfig ?? ""
    }
    func getBAckDropURL() -> String {
        return backdropURL ?? ""
    }
    
    // MARK: Model Updation methods
    
    /// This method updates the model with movie details
    ///
    /// - Parameter data: movieList array
    /// - Returns: returns true if updated properly
    private func updateMoviesListModel(data: [Any]?) -> Bool {
        guard let moviesList = data as? [[String:Any]] else {
            return false
        }
        for each in moviesList {
            let movieInfo = MovieInfo(thumbNailURL: each[MoviesListModelKeys.imageurl] as? String ?? "", name: each[MoviesListModelKeys.name] as? String ?? "", ReleaseDate: each[MoviesListModelKeys.releaseDate] as? String ?? "", movieId: each[MoviesListModelKeys.movieid] as? Int ?? 0, movieThumbnail: nil)
            moviesInfo == nil ? moviesInfo = [movieInfo] : moviesInfo?.append(movieInfo)
        }
        return true
    }
    
    /// This method updates the model with movie details
    ///
    /// - Parameter data: movieDetails array
    /// - Returns: returns true if updated properly
    private func updateMovieDetailsModel(data: [String: Any]?) -> Bool {
        guard let moviesDetails = data else {
            return false
        }
        let imageurl = moviesDetails[MovieDetailsModelKeys.imageurl] as? String ?? ""
        let name = moviesDetails[MovieDetailsModelKeys.name] as? String ?? ""
        let releaseDate = moviesDetails[MovieDetailsModelKeys.releaseDate] as? String ?? ""
        let movieid: Int = moviesDetails[MovieDetailsModelKeys.movieid] as? Int ?? 0
        let synopsis = moviesDetails[MovieDetailsModelKeys.synopsis] as? String ?? ""
        let adult: Bool = moviesDetails[MovieDetailsModelKeys.adult] as? Bool ?? false
        let genre: [String] = moviesDetails[MovieDetailsModelKeys.genre] as? [String] ?? []
        let rating: Double = moviesDetails[MovieDetailsModelKeys.rating] as? Double ?? 0.0
            movieDetails = MoviesDetails(title: name, synopsis: synopsis, ratings: rating, genre: genre, id: movieid, backdrop_path: imageurl, adult: adult, releasedate: releaseDate)
        return true
    }
}
