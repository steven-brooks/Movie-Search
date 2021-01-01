//
//  Service.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/16/20.
//

import Foundation

struct Service {
	enum Error: Swift.Error {
		case malformedUrlError
		case tooManyResults
		case httpError
	}
	
	static let host = "http://www.omdbapi.com/"
}

class ServiceDecoder: JSONDecoder {
	struct ServiceKey: CodingKey {
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		
		init?(intValue: Int) {
			self.stringValue = "\(intValue)"
			self.intValue = intValue
		}
		
		var intValue: Int?
		var stringValue: String
	}
	
	override init() {
		super.init()
		keyDecodingStrategy =
				.custom { (keys) -> CodingKey in
					if let key = keys.last?.stringValue {
						if key.hasPrefix("imdb") || key == "totalResults" {
							return ServiceKey(stringValue: key)!
						} else {
							// replace the first letter with a lowercase
							let firstLetter = key.first!.lowercased()
							let result = firstLetter + key.dropFirst()
							return ServiceKey(stringValue: result)!
						}
					} else {
						return keys.last!
					}
				}
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMM yyyy"
		dateDecodingStrategy = .custom({ (decoder) -> Date in
			do {
				let container = try decoder.singleValueContainer()
				let dateString = try container.decode(String.self)
				return formatter.date(from: dateString) ?? Date.distantPast
			} catch {
				return Date.distantPast
			}
		})
	}
}

extension Array where Element == URLQueryItem {
	mutating func appendApiKey() {
		append(URLQueryItem(name: "apiKey", value: "9d773e1e"))
	}
}

extension Date {
	var isValid: Bool {
		return self != Date.distantPast
	}
}
