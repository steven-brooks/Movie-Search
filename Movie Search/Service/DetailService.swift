//
//  DetailService.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/28/20.
//

import Foundation
import Combine

struct DetailService {
	func getDetails(for imdbId: String) -> AnyPublisher<MediaDetails, Error> {
		var components = URLComponents(string: Service.host)!
		var queryItems = [URLQueryItem(name: "i", value: imdbId), URLQueryItem(name: "plot", value: "full")]
		queryItems.appendApiKey()
		components.queryItems = queryItems
		
		guard let url = components.url else {
			return Result.Publisher(.failure(Service.Error.malformedUrlError)).eraseToAnyPublisher()
		}
		
		// check the cache
		if let details = SearchCache.shared.details(for: url) {
			return Result.Publisher(.success(details)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: MediaDetails.self, decoder: ServiceDecoder())
			.map {
				// cache it
				SearchCache.shared.setDetails(for: url, details: $0)
				return $0
			}
			.eraseToAnyPublisher()
	}
}
