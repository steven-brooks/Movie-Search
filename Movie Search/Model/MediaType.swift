//
//  MediaType.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/28/20.
//

import Foundation

enum MediaType: String, CaseIterable {
	case movie
	case series
	case game
	case unknown
	
	var index: Int {
		return MediaType.allCases.firstIndex(of: self) ?? MediaType.allCases.count
	}
}

extension MediaType: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		let string = try container.decode(String.self)
		
		self = .unknown
		
		for type in MediaType.allCases {
			if type.rawValue.lowercased() == string.lowercased() {
				self = type
			}
		}
		
		if self == .unknown {
			print("Unknown media type: \(string)")
		}
	}
}
