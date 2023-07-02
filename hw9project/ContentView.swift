//
//  ContentView.swift
//
//  Created by Yechan Seo on 4/10/23.
//

import SwiftUI
import CoreData
//import Alamofire


struct ContentView: View {
    var body: some View {
        NavigationView {
                VStack(){
                    ScrollView{
                        VStack{
                            SearchView()
                        }
                        .padding()
                    }
                } // VStack : favorite button, title, event search
                .navigationTitle("Event Search")
                .navigationBarItems(trailing:
                    NavigationLink(destination: FavoriteView()) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                            .background(Circle().stroke(Color.blue, lineWidth: 3))
                            .clipShape(Circle())
                            .padding(.trailing,15)
                    }
                ).background(Color(.systemGray6))
        } // navigation view closing
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





