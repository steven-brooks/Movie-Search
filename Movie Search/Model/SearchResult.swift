//
//  SearchResult.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/16/20.
//

import Foundation

struct SearchResult: Decodable {
	enum CodingKeys: String, CodingKey {
		case title = "Title"
		case year = "Year"
		case imdbId = "imdbID"
		case type = "Type"
		case posterUrl = "Poster"
	}
	
	var title: String
	var year: String
	var imdbId: String
	var type: MediaType
	var posterUrl: String
}
