//
//  SearchService.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/16/20.
//

import Foundation
import Combine

struct SearchResultsResponse: Decodable {
	enum CodingKeys: String, CodingKey {
		case results = "Search"
		case totalResults
		case error = "Error"
	}
	var results: [SearchResult]
	var totalResults: Int = 0
	var error: String?
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		if let countString = try? container.decode(String.self, forKey: .totalResults) {
			totalResults = Int(countString) ?? 0
		}
		results = (try? container.decode([SearchResult].self, forKey: .results)) ?? []
		error = try? container.decode(String.self, forKey: .error)
	}
}

class SearchService {
	func search(for term: String) -> AnyPublisher<SearchResultsResponse, Error> {
		var components = URLComponents(string: Service.host)!
		// make it a wildcard search
		var queryItems = [URLQueryItem(name: "s", value: "\(term)*")]
		queryItems.appendApiKey()
		components.queryItems = queryItems
		
		// check for valid url
		guard let _ = components.url else {
			return Result.Publisher(.failure(Service.Error.malformedUrlError)).eraseToAnyPublisher()
		}
		
		// single page publishers
		func get(components: URLComponents, page: Int) -> AnyPublisher<SearchResultsResponse, Error> {
			var comps = components
			comps.queryItems!.append(URLQueryItem(name: "page", value: "\(page)"))
			
			let request = URLRequest(url: comps.url!)
			
			// check the cache
			if let results = SearchCache.shared.results(for: comps.url!) {
				return Result.Publisher(.success(results)).eraseToAnyPublisher()
			}
			
			return URLSession.shared.dataTaskPublisher(for: request)
				.map { $0.data }
				.decode(type: SearchResultsResponse.self, decoder: JSONDecoder())
				.map {
					// save the resuls to the cache
					SearchCache.shared.setResults(for: comps.url!, response: $0)
					return $0
				}
				.eraseToAnyPublisher()
		}
		
		// start with page 1 to determine page count, then sequence the publishers
		return get(components: components, page: 1)
			.flatMap { (response) -> AnyPublisher<SearchResultsResponse, Error> in
				if true {// self != nil {
					let fetchedResults = response.results.count
					
					if fetchedResults >= response.totalResults {
						// all the results are on this page
						return Result.Publisher(.success(response)).eraseToAnyPublisher()
					} else {
						// make multiple page requests (limit to 5 pages so we don't blow throught the request limit)
						// fractions go to the next Int
						let pageCount = min(5, Int(ceil(Float(response.totalResults) / Float(response.results.count))))
						
						var pubs: [AnyPublisher<SearchResultsResponse, Error>] = (2...pageCount).map {
							get(components: components, page: $0)
						}
						
						// insert the currect page's publisher
						pubs.insert(Result.Publisher(.success(response)).eraseToAnyPublisher(), at: 0)
						
						return Publishers.Sequence(sequence: pubs)
							.flatMap { $0 }
							.eraseToAnyPublisher()
					}
				}
			}
			.eraseToAnyPublisher()
	}
}
