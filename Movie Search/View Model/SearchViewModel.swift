//
//  SearchViewModel.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/16/20.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
	@Published var searchTerm: String = ""
	@Published var results: [SearchResult] = []
	@Published var statusMessage: String?
	@Published var errorMessage: String?
	@Published var isServiceActive = false
	
	private var searchService = SearchService()
	
	var resultTypes: [MediaType] {
		Set(results.compactMap { $0.type }).sorted(by: {$0.index < $1.index})
	}
	
	var cancellables: [AnyCancellable] = []
	var timer: Cancellable? = nil
	var search: AnyCancellable? = nil
	
	init() {
		$searchTerm
			.sink {[unowned self] (value) in
				// give the user 1/2 second to continue typing before searching
				if value.isEmpty {
					results = []
					statusMessage = nil
					return
				}
				
				isServiceActive = true
				timer?.cancel()
				timer = Timer.publish(every: 0.5, on: .main, in: .default)
					.autoconnect()
					.sink(receiveValue: { (_) in
						timer?.cancel()
						search(term: value)
					})
			}
			.store(in: &cancellables)
	}
	
	func search(term: String) {
		isServiceActive = true
		results = []
		statusMessage = nil
		
		search?.cancel()
		
		search = SearchService().search(for: term)
			.receive(on: RunLoop.main)
			.sink { [weak self] (completion) in
				self?.isServiceActive = false
				switch completion {
				case .finished:
					break
				case .failure(let error):
					self?.errorMessage = error.localizedDescription
				}
			} receiveValue: { [weak self] (response) in
				self?.statusMessage = response.error
				self?.results += response.results
			}
	}
	
	var resultsByType: [MediaType: [SearchResult]] {
		var result: [MediaType: [SearchResult]] = [:]

		for type in resultTypes {
			result[type] = results.filter { $0.type == type }
		}
		
		return result
	}
}
