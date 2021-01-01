//
//  ContentView.swift
//  Movie Search
//
//  Created by Steven Brooks on 12/17/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationView {
			SearchView(model: SearchViewModel())
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
