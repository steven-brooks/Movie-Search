//
//  SearchView.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/16/20.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var model: SearchViewModel
	@State var collapsedSections: [MediaType] = []
	
    var body: some View {
		VStack {
			
			HStack {
				TextField("Search", text: $model.searchTerm)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()
				
				ProgressView()
					.opacity(model.isServiceActive ? 1 : 0)
					.animation(.easeIn)
					.padding(.trailing)
			}
			
			if model.statusMessage != nil {
				Text(model.statusMessage!)
					.opacity(0.6)
					.transition(.slide)
			}
			
			ScrollView {
				LazyVStack {
					ForEach(model.resultTypes, id: \.self) { type in
						Section(header: header(for: type)) {
							ForEach(results(for: type), id: \.imdbId) { result in
								NavigationLink(destination: DetailView(model: DetailViewModel(imdbId: result.imdbId, title: result.title))) {
									cell(for: result)
										.accentColor(.black)
										.padding(.trailing)
								}
							}
							
							Divider()
						}
					}
				}
			.animation(.default)
			}
		}
		.edgesIgnoringSafeArea(.bottom)
		
		.alert(item: $model.errorMessage) {
			Alert(title: Text($0))
		}
		.navigationBarTitle("Movie Search", displayMode: .inline)
    }
	
	func header(for type: MediaType) -> some View {
		ZStack {
			// for tapping
			Rectangle()
				.opacity(0.001)
			
			HStack {
				Text(type.rawValue)
			.bold()
			.font(.footnote)

				Spacer()

				Image(systemName: "chevron.down")
					.rotationEffect(collapsedSections.contains(type) ? Angle(degrees: -90) : .zero)
					.animation(.easeInOut)
			}
		}
		.onTapGesture {
			if collapsedSections.contains(type) {
				collapsedSections.removeAll(where: { $0 == type} )
			} else {
				collapsedSections.append(type)
			}
		}
	}
	
	func results(for type: MediaType) -> [SearchResult] {
		if collapsedSections.contains(type) {
			return []
		} else {
			return model.results.filter { $0.type == type }.sorted(by: {$0.year < $1.year})
		}
	}
	
	func cell(for result: SearchResult) -> some View {
		HStack {
			RemoteImage(url: URL(string: result.posterUrl))
				.frame(width: 64, height: 96)
			
			Text(result.title)
			Spacer()
			Text(result.year)
		}
	}
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			SearchView(model: SearchViewModel())
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
}
