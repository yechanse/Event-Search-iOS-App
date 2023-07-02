//
//  FavoriteView.swift
//
//  Created by Yechan Seo on 4/10/23.
//

import SwiftUI


struct FavoriteView: View {
    @State private var favorites: [EventDetail] = []

    var body: some View {
        VStack {
            VStack {
                if favorites.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No favorites found")
                                .font(.system(size: 17))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(favorites) { event in
                            FavoriteRow(event: event)
                        }
                        .onDelete(perform: removeFavorite)
                    }
                }
            }
            .onAppear {
                favorites = FavoritesClass.getFavorites()
            }
            .navigationBarTitle("Favorites")
        }.background(Color(.systemGray6))
    }
}

extension FavoriteView {
    // reference from https://developer.apple.com/forums/thread/665140
    private func removeFavorite(at offsets: IndexSet) {
        offsets.forEach { index in
            let event = favorites[index]
            FavoritesClass.removeFavorite(event: event)
        }
        favorites.remove(atOffsets: offsets)
    }
}


struct FavoriteRow: View {
    let event: EventDetail

    var body: some View {
        HStack {
            // date
            Text("\(event.onlydate)")
                .frame(width: 75)
                .font(.system(size: 12))
                .lineLimit(3)
                .truncationMode(.tail)
            Spacer()
            
            // name of the event
            Text(event.eventName)
                .frame(width: 75)
                .font(.system(size: 12))
                .lineLimit(3)
                .truncationMode(.tail)

            Spacer()
            
            // genre of the event
            Text(event.genre)
                .frame(width: 75)
                .font(.system(size: 12))
                .lineLimit(4)
                .truncationMode(.tail)
            
            // venue of the event
            Text(event.venue)
                .frame(width: 75)
                .font(.system(size: 12))
                .lineLimit(4)
                .truncationMode(.tail)

            Spacer(minLength: 0)
        }
        .padding(5)
        .frame(height: 60)
    }
}


