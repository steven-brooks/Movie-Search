//
//  RemoteImage.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/31/20.
//

import SwiftUI
import UIKit
import Combine

struct RemoteImage: View {
	var url: URL?
	var showNoImage = true
	@StateObject var loader = RemoteImageLoader()
	
    var body: some View {
		ZStack {
			if loader.image == nil && !loader.isLoading && showNoImage {
				// put up a no sign if no image could be loaded
				ZStack {
					Rectangle()
						.foregroundColor(.black)
						.opacity(0.2)

					Image(systemName: "nosign")
						.aspectRatio(contentMode: .fit)
				}
			}
			else if loader.image != nil {
				Image(uiImage: loader.image!)
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
			
			ProgressView()
				.foregroundColor(.black)
				.opacity(loader.isLoading ? 1 : 0)
		}
		.onAppear { if let url = url { loader.load(url) } }
    }
}

class RemoteImageLoader: ObservableObject {
	@Published var image: UIImage?
	@Published var isLoading = false
	private var cancellables: [AnyCancellable] = []

	func load(_ url: URL) {
		// check the cache, first
		if let data = SearchCache.shared.image(for: url) {
			image = UIImage(data: data)
			return
		}
		
		isLoading = true
		URLSession.shared.dataTaskPublisher(for: url)
			.receive(on: RunLoop.main)
			.sink { [weak self] (completion) in
				self?.isLoading = false
			} receiveValue: { [weak self] in
				self?.image = UIImage(data: $0.data)
				
				SearchCache.shared.setImage(for: url, image: $0.data)
			}
			.store(in: &cancellables)
	}
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
		RemoteImage(url: URL(string: "https://m.media-amazon.com/images/M/MV5BNzg3NTQ4NDk5NV5BMl5BanBnXkFtZTgwNzMzNDg4NjE@._V1_SX300.jpg")!)
    }
}
