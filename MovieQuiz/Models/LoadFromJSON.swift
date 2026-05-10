//
//  LoadFromJSON.swift
//  MovieQuiz
//
//  Created by Flymetric on 02.05.2026.
//
//import Foundation

struct LoadFromJSON: Codable {
    let items: [Item]
    let errorMessage: String
}

struct Item: Codable {
    let id: String
    let rank: String
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let crew: String
    let imDbRating: String
    let imDbRatingCount: String
}

/*
{
    "items": [
        {
            "id": "tt0111161",
            "rank": "1",
            "title": "The Shawshank Redemption",
            "fullTitle": "The Shawshank Redemption (1994)",
            "year": "1994",
            "image": "https://m.media-amazon.com/images/M/MV5BMDFkYTc0MGEtZmNhMC00ZDIzLWFmNTEtODM1ZmRlYWMwMWFmXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_Ratio0.6716_AL_.jpg",
            "crew": "Frank Darabont (dir.), Tim Robbins, Morgan Freeman",
            "imDbRating": "9.2",
            "imDbRatingCount": "2619254"
        },
        {
            "id": "tt0101414",
            "rank": "250",
            "title": "Beauty and the Beast",
            "fullTitle": "Beauty and the Beast (1991)",
            "year": "1991",
            "image": "https://m.media-amazon.com/images/M/MV5BMzE5MDM1NDktY2I0OC00YWI5LTk2NzUtYjczNDczOWQxYjM0XkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_Ratio0.6716_AL_.jpg",
            "crew": "Gary Trousdale (dir.), Paige O'Hara, Robby Benson",
            "imDbRating": "8.0",
            "imDbRatingCount": "449434"
        }
    ],
    "errorMessage": ""
}
 */
