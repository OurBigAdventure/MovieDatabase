// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let movies = try Movies(json)

import Foundation

// MARK: - Movies
struct Movies: Codable {
    let page, totalResults, totalPages: Int?
    let results: [Movie]?
}

// MARK: - Movie
struct Movie: Codable {
    let popularity: Double?
    let voteCount: Int?
    let video: Bool?
    let posterPath: String?
    let id: Int?
    let adult: Bool?
    let backdropPath: String?
    let originalLanguage: String?
    let originalTitle: String?
    let genreIds: [Int]?
    let title: String?
    let voteAverage: Double?
    let overview, releaseDate: String?
}
