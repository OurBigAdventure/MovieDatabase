//
//  ViewController.swift
//  MovieDatabase
//
//  Created by Chris Brown on 12/10/19.
//  Copyright © 2019 Chris Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MDBConnectionDelegate {

    @IBOutlet weak var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageBaseURL = ""
    var posterImageSize = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        MDBConnection.shared.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MDBConnection.shared.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableCell
        let currentMovie = MDBConnection.shared.movies[indexPath.item]
        cell.titleLabel.text = currentMovie.title
        if let releaseDate = currentMovie.releaseDate {
            cell.yearLabel.text = String(releaseDate.prefix(4))
        }
        if let voteAverage = currentMovie.voteAverage {
            cell.userRatingLabel.text = String(format:"%.1f", voteAverage)
        }
        if let posterPath = currentMovie.posterPath, let url = URL(string: imageBaseURL + posterImageSize + posterPath) {
            if let data = try? Data(contentsOf: url) {
                cell.posterImageView.image = UIImage(data: data)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    // MARK: - MDBConnection Delegate

    func movieListUpdated() {
        self.tableView.reloadData()
    }

    func updateConfigInfo() {
        if let imageSettings = MDBConnection.shared.config["images"] as? [String:Any],
            let baseURL = imageSettings["secure_base_url"] as? String,
            let posterSizes = imageSettings["poster_sizes"] as? [String] {
            imageBaseURL = baseURL
            posterImageSize = posterSizes[2]
            self.tableView.reloadData()
        }
    }

}

