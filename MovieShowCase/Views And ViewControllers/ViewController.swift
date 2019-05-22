//
//  ViewController.swift
//  MovieShowCase
//
//  Created by I309659 on 19/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var moviesListCollection: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cellIdentifierID = "MovieListCell"
    
    let movieDetailsViewNibName = "MovieDetailsView"
    
    var movieDataFetcher: MovieDataFetcher?
    
    var moviesList: [MovieInfo]?
    
    var isSearchBarActive: Bool = false
    
    var searchResults = [MovieInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        moviesListCollection.register(UINib(nibName:cellIdentifierID, bundle: nil), forCellWithReuseIdentifier: cellIdentifierID)
        setupMoviesListView()
        setupNetworkLayer()
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.movieDataFetcher?.uiUpdateDelegate = self
    }
    
    private func setupMoviesListView() {
        moviesListCollection.dataSource = self
        moviesListCollection.delegate = self
    }

    private func setupNetworkLayer() {
        OperationQueue().addOperation() {
            self.movieDataFetcher = MovieDataFetcher(networkingDelegate: RequestResponseHandler())
            self.movieDataFetcher?.uiUpdateDelegate = self
            _ = self.movieDataFetcher?.fetchMovieThumbnailConfig()
            _ = self.movieDataFetcher?.fetchMoviesList(forPage: 1)
        }
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: CollectionView delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearchBarActive ? searchResults.count : (moviesList?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifierID, for: indexPath) as? MoviesListCell else {
            collectionView.register(UINib(nibName:cellIdentifierID, bundle: nil), forCellWithReuseIdentifier: cellIdentifierID)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifierID, for: indexPath) as? MoviesListCell ?? MoviesListCell()
            return cell
        }
        cell.layer.cornerRadius = 15
        var movieInfo: MovieInfo
        if isSearchBarActive && searchBar.text != "" {
            movieInfo = searchResults[indexPath.row]
        } else {
            guard let movieData = moviesList?[indexPath.row] else {
                return cell
            }
            movieInfo = movieData
        }
        cell.movieName.text = movieInfo.name
        cell.releaseDate.text = movieInfo.ReleaseDate
        if movieInfo.movieThumbnail == nil {
            var thumbnailurl = movieDataFetcher?.getThumbnailConfigURL() ?? ""
            thumbnailurl += movieInfo.thumbNailURL
            guard let url = URL(string: thumbnailurl) else {
                return cell
            }
            do {
                let data = try Data(contentsOf: url)
                let movieImage = UIImage(data: data)
                moviesList?[indexPath.row].movieThumbnail = movieImage
                cell.movieThumbNail.image = movieImage
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            cell.movieThumbNail.image = movieInfo.movieThumbnail
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the code to push new vc
        var movieInfo: MovieInfo
        if isSearchBarActive && searchBar.text != "" {
            movieInfo = searchResults[indexPath.row]
        } else {
            guard let movieData = moviesList?[indexPath.row] else {
                return
            }
            movieInfo = movieData
        }
        _ = movieDataFetcher?.fetchMovieDetailsFor(movieId: movieInfo.movieId)
        let moviesDetailVC = MovieDetailsViewController(nibName: movieDetailsViewNibName, bundle: nil)
        moviesDetailVC.movieDataFetcher = self.movieDataFetcher
        moviesDetailVC.movieDataFetcher?.uiUpdateDelegate = moviesDetailVC
        self.navigationController?.pushViewController(moviesDetailVC, animated: true)
    }
    
}

extension ViewController: UIUpdater {
    
    func updateUI() {
        moviesList = movieDataFetcher?.getMoviesList()
        activityIndicator.stopAnimating()
        moviesListCollection.reloadData()
        
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isSearchBarActive = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // preconditions to check and stop unnecessary search.
        if searchText == "" && searchBar.text == ""{
            resetSearchState()
            return
        } else if searchText == "" && searchBar.text != "" {
            return
        }
        
        // search begins
        isSearchBarActive = true
        searchResults = [MovieInfo]()
        
        // seperating each word in search test
        let searchterms = searchText.components(separatedBy: " ")
        guard var moviesInfo = moviesList else {
            return
        }
        
        // iterating over each word in search text.
        for eachSearchTerm in searchterms {
            if eachSearchTerm != "" {
                for movie in moviesInfo {
                    
                    // Seperating out the words in the movie name and iterating over each word to check with search text.
                    // only for the last search word, it should be beginsWith()
                    // for the rest, the search term should match exactly, since thery are completed words.
                    let wordsInmovieName = movie.name.components(separatedBy: " ")
                    for eachword in wordsInmovieName {
                        if searchterms.count > 1 {
                           if eachword == eachSearchTerm ||
                            ((searchterms.firstIndex(of: eachSearchTerm) == (searchterms.count - 1)) && eachword.starts(with: eachSearchTerm)) {
                            if !exists(moviesList: searchResults,movieInfo: movie) {
                                    searchResults.append(movie)
                                }
                           }
                        } else {
                            if eachword.starts(with: eachSearchTerm) {
                                searchResults.append(movie)
                            }
                        }
                    }
                }
            }
            
            // Assigning it back, to reduce the scope of search.
            moviesInfo = searchResults
        }
        moviesListCollection.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearchState()
    }
    
    private func resetSearchState() {
        isSearchBarActive = false
        searchResults = [MovieInfo]()
        moviesListCollection.reloadData()
    }
    
    private func exists(moviesList:[MovieInfo], movieInfo:MovieInfo) -> Bool {
        for each in moviesList {
            if each == movieInfo {
                return true
            }
        }
        return false
    }
    
}

