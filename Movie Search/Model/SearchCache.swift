//
//  SearchCache.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/31/20.
//

import Foundation

class SearchCache {
	static let shared = SearchCache()
	static let maxResultPages = 100
	static let maxImages = 50
	static let maxDetails = 50
	
	private var searchUrls: [URL] = [] // queue style
	private var searchUrlResults: [URL: SearchResultsResponse] = [:]
	
	private var imageUrls: [URL] = []
	private var images: [URL: Data] = [:]
	
	private var detailUrls: [URL] = []
	private var details: [URL: MediaDetails] = [:]
	
	func results(for url: URL) -> SearchResultsResponse? {
		return searchUrlResults[url]
	}
	
	func setResults(for url: URL, response: SearchResultsResponse) {
		// if it's already in there, remove it so we can re-add it to the back of the queue
		if let index = searchUrls.firstIndex(of: url) {
			searchUrls.remove(at: index)
		} else if searchUrls.count >= SearchCache.maxResultPages - 1 {
			searchUrlResults.removeValue(forKey: searchUrls[0])
			searchUrls.remove(at: 0)
		}
		
		searchUrls.append(url)
		searchUrlResults[url] = response
	}
	
	func image(for url: URL) -> Data? {
		return images[url]
	}
	
	func setImage(for url: URL, image: Data) {
		// if it's already in there, remove it so we can re-add it to the back of the queue
		if let index = imageUrls.firstIndex(of: url) {
			imageUrls.remove(at: index)
		} else if imageUrls.count >= SearchCache.maxImages - 1 {
			images.removeValue(forKey: imageUrls[0])
			imageUrls.remove(at: 0)
		}
		
		imageUrls.append(url)
		images[url] = image
	}
	
	func details(for url: URL) -> MediaDetails? {
		return details[url]
	}
	
	func setDetails(for url: URL, details: MediaDetails) {
		// if it's already in there, remove it so we can re-add it to the back of the queue
		if let index = detailUrls.firstIndex(of: url) {
			detailUrls.remove(at: index)
		} else if detailUrls.count >= SearchCache.maxDetails - 1 {
			self.details.removeValue(forKey: detailUrls[0])
			detailUrls.remove(at: 0)
		}
		
		searchUrls.append(url)
		self.details[url] = details
	}
}
