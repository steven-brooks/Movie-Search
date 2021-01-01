//
//  MediaDetails.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/28/20.
//

import Foundation

struct MediaDetails: Decodable {
	struct Rating: Decodable {
		var source: String
		var value: String
	}
	
	var title: String
	var year: String
	var rated: String
	var released: Date
	var runtime: String?
	var genre: String
	var director: String
	var writer: String
	var actors: String
	var plot: String
	var awards: String
	var boxOffice: String
	var poster: String
	var metascore: String
	
	var ratings: [Rating]
	var production: String
	var type: MediaType
	var website: String?
}
