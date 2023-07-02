//
//  Autocomplete.swift
//
//  Created by Yechan Seo on 4/27/23.
//

import SwiftUI

struct Autocomplete: View {
    let suggestions: [String]
    @Binding var selectedSuggestion: String
    
    var body: some View {
        VStack  {
            if suggestions.isEmpty {
                Text("No suggestions found")
                    .font(.system(size: 27))
                    .padding()
                    .padding(.top,30)
                    .foregroundColor(.red)
                Spacer()
            } else {
                List(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        selectedSuggestion = suggestion
                    }) {
                        Text(suggestion)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct Autocomplete_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Autocomplete(suggestions: ["P!NK", "Australian Pink Floyd Show", "Pink Martini", "Pink Droyd", "Wild Pink"],
                          selectedSuggestion: .constant(""))
            Autocomplete(suggestions: [],
                          selectedSuggestion: .constant(""))
        }
    }
}
