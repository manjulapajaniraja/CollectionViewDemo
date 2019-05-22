//
//  MovieDetailViewController.swift
//  MovieShowCase
//
//  Created by I309659 on 21/05/19.
//  Copyright © 2019 Pajaniraja, Manjula. All rights reserved.
//

import Foundation
import UIKit

class MovieDetailsViewController : UIViewController {
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!

    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var synopsis: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movieDetails: MoviesDetails?
    
    var movieDataFetcher: MovieDataFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        movieTitle.text = ""
        rating.text = ""
        synopsis.text = ""
    }
    
}

extension MovieDetailsViewController: UIUpdater {
    
    func updateUI() {

        movieDetails = movieDataFetcher?.getMovieDetails()
        movieTitle.text = movieDetails?.title
        synopsis.text = movieDetails?.synopsis
        rating.text = String(format:"%.1f", movieDetails?.ratings ?? 0.0)
        self.title = "Movie Info"
        view.layoutSubviews()
        updateBackDrop()
        activityIndicator.stopAnimating()
        ratingLabel.isHidden = false
    }
    
    private func updateBackDrop() {
        var backdropurl = movieDataFetcher?.getBAckDropURL() ?? ""
        backdropurl = backdropurl + (movieDetails?.backdrop_path ?? "")
        guard let url = URL(string: backdropurl) else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            movieImage.image = UIImage(data: data)
        } catch let error {
            print(error.localizedDescription)
        }
        view.layoutSubviews()
    }
}
