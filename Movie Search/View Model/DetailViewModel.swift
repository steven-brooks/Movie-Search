//
//  DetailViewModel.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/28/20.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
	@Published var details: MediaDetails?
	@Published var errorMessage: String?
	@Published var isLoading = false
	@Published var title: String
	
	private var cancellables: [AnyCancellable] = []
	private var imdbId: String
	
	init(imdbId: String, title: String) {
		self.imdbId = imdbId
		self.title = title
	}
	
	func getDetails() {
		isLoading = true
		DetailService().getDetails(for: imdbId)
			.receive(on: RunLoop.main)
			.sink { [weak self] (completion) in
				self?.isLoading = false
				switch completion {
				case .finished:
					break
				case .failure(let error):
					self?.errorMessage = error.localizedDescription
				}
			} receiveValue: { [weak self] in
				self?.details = $0
			}
			.store(in: &cancellables)
	}
}
