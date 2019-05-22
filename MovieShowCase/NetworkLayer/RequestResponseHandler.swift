//
//  RequestResponseHandler.swift
//  MovieShowCase
//
//  Created by I309659 on 20/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation

enum RequestType {
    
    case MoviesList
    case MovieDetails
    case MovieThumbnailConfig
}

enum HTTPMethod: String {
    
    case GET = "GET"
    case POST = "POST"
    
}

class RequestResponseHandler: Networking {
    
    private let language = "en-US"
    
    private struct APIRequests {
        
        static let movieLsitAPI = "https://api.themoviedb.org/3/movie/now_playing"
        static let movieThumbnailConfig = "https://api.themoviedb.org/3/configuration?"
        static let movieDetailsAPI = "https://api.themoviedb.org/3/movie/"
        
    }
    
    private struct QueryParams {
        
        static let language = "language"
        static let page = "page"
        static let apiKey = "api_key"
        static let movieId = "movieId"
        
    }
    
    func fetchMoviesListUsing(APIKey: String, forPage:Int, onCompletion: @escaping ([Any]) -> Void) -> Bool {
        
        let requestParams = [QueryParams.page: forPage, QueryParams.apiKey: APIKey] as [String : Any]
        guard let urlRequest = buildQueryFor(requestType: .MoviesList, reqestParams: requestParams, httpMethod: .GET) else {
            debugPrint("Not a valid url to fetch data")
            return false
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                guard let data = data else {
                    return
                }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data , options: .allowFragments) as? [String:Any]
                    let moviesList = jsonResponse?["results"] as? [Any]
                    onCompletion(moviesList ?? [Any]())
                } catch let error {
                    print(error)
                }
            }
        })
        dataTask.resume()
        return true
    }
    
    func getImageConfigurationPathForMovieWith(APIKey: String, onCompletion: @escaping ([String: Any]) -> Void) -> Bool {
        
        let requestParams = [QueryParams.apiKey: APIKey] as [String : Any]
        guard let urlRequest = buildQueryFor(requestType: .MovieThumbnailConfig, reqestParams: requestParams, httpMethod: .GET) else {
            debugPrint("Not a valid url to fetch data")
            return false
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                guard let data = data else {
                    return
                }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data , options: .allowFragments) as? [String:Any]
                    let movieThumbnailConfig = jsonResponse?["images"] as? [String:Any]
                    onCompletion(movieThumbnailConfig ?? [String: Any]())
                } catch let error {
                    print(error)
                }
            }
        })
        dataTask.resume()
        return true

    }
    
    func fetchMovieDetailsUsing(movieId: Int, APIKey: String, onCompletion: @escaping ([String: Any]) -> Void) -> Bool {
        
        let requestParams = [QueryParams.movieId: movieId, QueryParams.apiKey: APIKey, QueryParams.language: language] as [String : Any]
        guard let urlRequest = buildQueryFor(requestType: .MovieDetails, reqestParams: requestParams, httpMethod: .GET) else {
            debugPrint("Not a valid url to fetch data")
            return false
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                guard let data = data else {
                    return
                }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data , options: .allowFragments) as? [String:Any]
                    onCompletion(jsonResponse ?? [String: Any]())
                } catch let error {
                    print(error)
                }
            }
        })
        dataTask.resume()
        return true
    }
    
    private func buildQueryFor(requestType: RequestType, reqestParams: [String:Any], httpMethod: HTTPMethod ) -> URLRequest? {
        
        var urlString = ""
        
        switch requestType {
            
        case .MoviesList:
            
            urlString = APIRequests.movieLsitAPI
            let page:Int = reqestParams[QueryParams.page] as? Int ?? 1
            let apikey: String = reqestParams[QueryParams.apiKey] as? String ?? ""
            //Append query params
            var queryparams = QueryParams.page + "=" + String(page)
            queryparams += "&" + QueryParams.language + "=" + language
            queryparams += "&" + QueryParams.apiKey + "=" + apikey
            urlString += ("?" + queryparams)
            
        case .MovieThumbnailConfig:
            
            urlString = APIRequests.movieThumbnailConfig
            let apikey: String = reqestParams[QueryParams.apiKey] as? String ?? ""
            //Append query params
            var queryparams = QueryParams.apiKey + "=" + apikey
            queryparams += "&" + QueryParams.language + "=" + language
            urlString += queryparams
            
        case .MovieDetails:
            
            urlString = APIRequests.movieDetailsAPI
            let movieId = reqestParams[QueryParams.movieId] as? Int ?? 0
            let apikey: String = reqestParams[QueryParams.apiKey] as? String ?? ""
            urlString += String(movieId)
            //Append query params
            var queryparams = QueryParams.apiKey + "=" + apikey
            queryparams += "&" + QueryParams.language + "=" + language
             urlString += ("?" + queryparams)
            
        }
        
        guard let url = URL(string: urlString) else {
            debugPrint("Not a valid url to fetch data")
            return nil
        }
        
        let request = NSMutableURLRequest(url: url,
                                          cachePolicy: .reloadIgnoringCacheData,
                                          timeoutInterval: 10.0)
        request.httpMethod = httpMethod.rawValue
       //  request.setValue("https://cors-anywhere.herokuapp.com/", forHTTPHeaderField: "Origin")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Allow-Origin")
        request.setValue("x-requested-with", forHTTPHeaderField: "Access-Control-Allow-Headers")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Allow-Methods")
    
        return request as URLRequest
        
    }
    
    
}
