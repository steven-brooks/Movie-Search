//
//  DetailView.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/28/20.
//

import SwiftUI

struct DetailView: View {
	@StateObject var model: DetailViewModel
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.openURL) var openUrl
	
    var body: some View {
		ZStack {
			VStack {
				// custom "nav bar" to accomodate multi-line titles
				HStack {
					Button(action: {presentationMode.wrappedValue.dismiss()} ) {
						Image(systemName: "chevron.left")
					}
					
					Spacer()
					
					Text(model.title)
						.bold()
						.multilineTextAlignment(.center)
					
					Spacer()
					
					// fo centering the title
					Button(action: {presentationMode.wrappedValue.dismiss()} ) {
						Image(systemName: "chevron.left")
					}.hidden()
				}
				.padding()
				.frame(maxWidth: .infinity)
				Divider()
			
				ScrollView {
					VStack {
						Group {
							if model.details?.production.isValid ?? false {
								item(key: "Produced By", value: model.details?.production)
								Divider()
							}
							item(key: "Plot", value: model.details?.plot)
							Divider()
						}
						HStack {
							item(key: "Rated", value: model.details?.rated)
							Divider()
							if model.details?.released.isValid ?? false {
								item(key: "Released", value: dateFormatter.string(from: model.details!.released))
							} else {
								item(key: "Released", value: nil)
							}
							Divider()
							item(key: "Runtime", value: model.details?.runtime)
						}
						.fixedSize(horizontal: false, vertical: true)
						Divider()
						
						Group {
							item(key: "Starring", value: model.details?.actors)
							Divider()
							item(key: "Director".plural(model.details?.director), value: model.details?.director)
							Divider()
							item(key: "Writer".plural(model.details?.writer), value: model.details?.writer)
							Divider()
						}
						Group {
							if model.details?.awards.isValid ?? false {
								item(key: "Awards", value: model.details?.awards)
								Divider()
							}
							HStack {
								if model.details?.boxOffice.isValid ?? false {
									item(key: "Box Office", value: model.details?.boxOffice)
									Divider()
								}
								item(key: "Metascore", value: model.details?.metascore)
							}
							.fixedSize(horizontal: false, vertical: true)
							Divider()
						}
						
						if model.details?.website?.isValid ?? false {
							Button(action: {openUrl(URL(string: model.details!.website!)!)} ) {
								item(key: "Website", value: model.details?.website)
							}
							Divider()
						}
						if model.details?.poster.isValid ?? false {
							RemoteImage(url: URL(string: model.details!.poster), showNoImage: false)
								.background(Color.orange)
						}
						Spacer()
					}
					.padding(.horizontal)
				}
			}
			Group {
				Rectangle()
					.foregroundColor(.black)
					.opacity(0.4)
					.edgesIgnoringSafeArea(.all)
							
				ProgressView()
			}
			.opacity(model.isLoading ? 1 : 0)
			.animation(.easeOut)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.onAppear() {
			if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil {
				model.getDetails()
			}
		}
		.alert(item: $model.errorMessage) {
			Alert(title: Text($0))
		}
		.navigationBarHidden(true)
    }
	
	func item(key: String, value: String?) -> some View {
		HStack {
			VStack(alignment: .leading) {//(alignment: .top) {
				Text(key)
					.font(.footnote)
					.bold()
					.foregroundColor(.gray)
				
				Text(value ?? "")
					.fixedSize(horizontal: false, vertical: true)
				
			}
			Spacer()
		}
	}
	
	var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .medium
		formatter.locale = Locale.current
		return formatter
	}
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
		
		let json = """
		{
		"Title": "Teenage Mutant Ninja Turtles II: The Secret of the Ooze",
		"Year": "2014",
		"Rated": "PG-13",
		"Released": "08 Aug 2014",
		"Runtime": "101 min",
		"Genre": "Action, Adventure, Comedy, Sci-Fi",
		"Director": "Jonathan Liebesman",
		"Writer": "Josh Appelbaum, André Nemec, Evan Daugherty, Peter Laird (based on the Teenage Mutant Ninja Turtles characters created by), Kevin Eastman (based on the Teenage Mutant Ninja Turtles characters created by)",
		"Actors": "Megan Fox, Will Arnett, William Fichtner, Alan Ritchson",
		"Plot": "When a kingpin threatens New York City, a group of mutated turtle warriors must emerge from the shadows to protect their home.",
		"Language": "English, Japanese",
		"Country": "USA",
		"Awards": "1 win & 10 nominations.",
		"Poster": "https://m.media-amazon.com/images/M/MV5BNjUzODQ5MDY5NV5BMl5BanBnXkFtZTgwOTc1NzcyMjE@._V1_SX300.jpg",
		"Ratings": [
		{
		"Source": "Internet Movie Database",
		"Value": "5.8/10"
		},
		{
		"Source": "Rotten Tomatoes",
		"Value": "21%"
		},
		{
		"Source": "Metacritic",
		"Value": "31/100"
		}
		],
		"Metascore": "31",
		"imdbRating": "5.8",
		"imdbVotes": "200,085",
		"imdbID": "tt1291150",
		"Type": "movie",
		"DVD": "N/A",
		"BoxOffice": "$191,204,754",
		"Production": "Heavy Metal, Platinum Dunes, Mednick Productions, Gama Entertainment",
		"Website": "http://www.tmnt.com",
		"Response": "True"
		}
		"""
		
		
		let details = try? ServiceDecoder().decode(MediaDetails.self, from: json.data(using: .utf8)!)
		let model = DetailViewModel(imdbId: "tt1291150", title: details!.title)
		model.details = details
		
		return NavigationView { DetailView(model: model) }
	}
}

extension String {
	func plural(_ value: String?) -> String {
		return (value?.contains(",") ?? false) ? self + "s" : self
	}
	
	var isValid: Bool {
		return self != "NA" && self != "N/A"
	}
}
