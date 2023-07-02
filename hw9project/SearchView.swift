//  SearchView.swift


import SwiftUI
import Alamofire

struct Event: Codable, Identifiable, Hashable {
    let id: String
    let date: String
    let dateTime: String
    let icon: String
    let name: String
    let genre: String
    let venue: String

    enum CodingKeys: String, CodingKey {
        case id = "eventID"
        case date
        case dateTime
        case icon
        case name
        case genre
        case venue
    }
}

struct SearchView: View {
    // Inputs
    @State private var keyword: String = ""
    @State private var category: String = "default"
    @State private var distance: String = "10"
    @State private var location: String = ""
    @State private var autoDetectLocation: Bool = false
    
    @State private var events: [Event] = []
    // store the ticketmaster response from the backend "eventresults"
    
    @State private var isLoadingEventResult: Bool = true // for Loading spinner
    
    @State private var NoRecordPrint: Bool = false
    @State private var showResultsContainer: Bool = false
    
    // lat lng
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    // autocomplete
    @State private var suggestions: [String] = []
    @State private var showSheet: Bool = false
    @State private var stillProcessingSuggestion: Bool = true


    
    
    var body: some View {
        VStack() {
            // Rectangle Shape
            Rectangle().frame(height: 0)
            
            // All Inputs fields wrapped by Vstack
            VStack( spacing: 10) {
                HStack {
                    Text("Keyword: ")
                        .foregroundColor(.gray)
                    Spacer()
                    ZStack(alignment: .leading) {
                        if keyword.isEmpty {
                            Text("Required")
                                .foregroundColor(Color(red: 0.73, green: 0.73, blue: 0.73))
                        }
                        TextField("", text: $keyword, onCommit: {
                            if !keyword.isEmpty {
                                Task {
                                    await getSuggestions(keyword: keyword)
                                }
                                showSheet = true
                            }
                        })
                        .onTapGesture {
                            showSheet = false
                        }

                    }
                }
                .sheet(isPresented: $showSheet) {
                    VStack {
                        Text("Suggestions")
                            .font(.system(size: 27, weight: .bold))
                            .padding(.top)
                        if stillProcessingSuggestion {
                            ProgressView("Loading...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        keyword = suggestion
                                        showSheet = false
                                    }) {
                                        Text(suggestion)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                }
                
               
                Divider()
                    .background(Color(.systemGray5))
                
                HStack {
                    Text("Distance: ")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("", text: $distance)
                        .keyboardType(.numberPad)
                }
                Divider()
                    .background(Color(.systemGray5))
                
                HStack {
                    Text("Category: ")
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Category", selection: $category) {
                        Text("Default").tag("default")
                        Text("Music").tag("music")
                        Text("Sports").tag("sports")
                        Text("Arts & Theatre").tag("arts")
                        Text("Film").tag("flim")
                        Text("Miscellaneous").tag("miscellaneous")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(height: 22)
                    .padding(.trailing,10)
                }
                Divider()
                    .background(Color(.systemGray5))
                
                if !autoDetectLocation {
                    HStack {
                        Text("Location: ")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("Required", text: $location)
                    }
                    Divider()
                        .background(Color(.systemGray5))
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Toggle(isOn: $autoDetectLocation) {
                            Text("Auto-detect my location")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing,20)
                        
                        Divider()
                            .background(Color(.systemGray5))
                    }
                }
                
                // Buttons
                HStack {
                    Button(action: submitForm) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(width: 111, height: 55)
                            .background(isValidInput() ? Color.red : Color.gray)
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                    
                    // Clear
                    Button(action: clearForm) {
                        Text("Clear")
                            .foregroundColor(.white)
                            .frame(width: 111, height: 55)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                } // submit & clear buttons Hstack Closing
                .frame(maxWidth: .infinity)
                .padding(.top, 10) // padding between buttons and auto detect location
                
            } // VStack for all the inputs and buttons
            .padding(.leading)
            .padding(.top,15)
            .padding(.bottom,30)
            .background(Color.white.cornerRadius(15)) // 잠시만 commented
            
            Spacer()
            
            if (showResultsContainer){
                Spacer()
                ResultsContainer(events: events, noResults: NoRecordPrint,  isLoadingEventResult: isLoadingEventResult)
            }
            Spacer()
        }
    } // VStack Closing for body
}


// event results
struct ResultsContainer: View {
    let events: [Event]
    let noResults: Bool
    let isLoadingEventResult: Bool // result loading progressview
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Results")
                .font(.system(size: 27, weight: .bold))
                .padding(.top,15)
                .padding(.leading,5)
            Divider()
                .background(Color(.systemGray5))
            //
            if isLoadingEventResult {//
                ProgressView("Please wait...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                
                if noResults {
                    Text("No results available")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                } else {
                    VStack() {
                        ForEach(events, id: \.id) { event in
                            NavigationLink(destination: EventDetailsView(eventId: event.id, venue: event.venue)) {
                                EventRow(event: event)
                                Divider()
                                    .background(Color(.systemGray5))
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .background(Color.white.cornerRadius(15))
        
    }
}

struct EventRow: View {
    let event: Event

    var body: some View {
            HStack {
                Text("\(event.date)|\(String(event.dateTime.dropLast(3)))")
                    .frame(width:65)
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .truncationMode(.tail)
                Spacer()
                
                Image(uiImage: loadImage(url: event.icon))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
                Spacer()
                
                Text(event.name)
                    .frame(width:75)
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                    .lineLimit(3)
                    .truncationMode(.tail)
                
                Spacer()
                
                Text(event.venue)
                    .frame(width:75)
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .foregroundColor(.gray)
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing,5)
                
            }
            .padding(10)
            .frame(height: 80)
        
    }
    
    func loadImage(url: String) -> UIImage {
        guard let imageURL = URL(string: url) else {
            return UIImage()
        }
        do {
            let data = try Data(contentsOf: imageURL)
            return UIImage(data: data) ?? UIImage()
        } catch {
            print("printing out \(error)")
            return UIImage()
        }
    }
}
 

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchView()
        }
    }
}

// Helper Functions
extension SearchView {
    
    private func isValidInput() -> Bool {
        return (!keyword.trimmingCharacters(in: .whitespaces).isEmpty) && (autoDetectLocation || !location.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    private func submitForm() {
        print("submit button clicked!!")
        
        // Not valid input so doesn't operate any action on clicking submit button
        if !isValidInput() {
            return
                
        } else {
            print("valid input coming in....")
            NoRecordPrint = false
            showResultsContainer = true
            isLoadingEventResult = true // event result progress view

            if autoDetectLocation {
                Task {
                    do {
                        let response = try await getAutoLocationFromIpInfoAPI()
                        latitude = response.latitude
                        longitude = response.longitude
                        
                        // Call EventResult API with obtained latitude and longitude
                        let fetchedEvents = try await updateEvents()
                        if fetchedEvents.isEmpty {
                            NoRecordPrint = true
                        }
                        events = fetchedEvents
                        isLoadingEventResult = false
                        
                    } catch {
                        print(error)
                        isLoadingEventResult = false
                        return
                    }
                }
            } else {
                // Call Google Maps Geocode API to get latitude and longitude
                Task {
                    do {
                        let response = try await getLocationFromGoogleMapsAPI()
                        latitude = response.latitude
                        longitude = response.longitude
                        
                        // Call EventResult API with latitude and longitude
                        let fetchedEvents = try await updateEvents()
                        if fetchedEvents.isEmpty {
                            NoRecordPrint = true
                        }
                        events = fetchedEvents
                        showResultsContainer = true
                        
                        isLoadingEventResult = false // set false when events are fetched
                        
                        
                    } catch {
                        print(error)
                        isLoadingEventResult = false
                        return
                    }
                }
            }
        }
    }

    // Event Results API call
    private func updateEvents() async throws -> [Event] {
        let url = URL(string: "https://cs571hw8-381320.wn.r.appspot.com/api/eventresult")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "distance", value: String(distance)),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "location", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "autoDetectLocation", value: String(autoDetectLocation))
        ]
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let eventResultData = try decoder.decode([Event].self, from: data)

        return eventResultData
       
    }
    
    // basic seesion call reference https://designcode.io/swiftui-advanced-handbook-async-await
    // Auto Detect Location (Ipinfo API)
    private func getAutoLocationFromIpInfoAPI() async throws -> (latitude: String, longitude: String) {
        let url = URL(string: "https://ipinfo.io?token=9064bb703f6aa3")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let latlng = json["loc"] as! String
        let components = latlng.split(separator: ",")
        return (latitude: String(components[0]), longitude: String(components[1]))
    }

    // Location Input (Google Maps API)
    private func getLocationFromGoogleMapsAPI() async throws -> (latitude: String, longitude: String) {
        guard let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return ("", "")
        }
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedLocation)&key=AIzaSyDCr5lHYYM6FI-gu9R_ng77DZeB9yC6tkM") else {
            return ("", "")
        }
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return ("", "")
        }
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        guard let status = json["status"] as? String else {
            return ("", "") //
        }
        if status == "ZERO_RESULTS" {
            return ("", "") //
        } else{
            if let results = json["results"] as? [[String: Any]], let geometry = results[0]["geometry"] as? [String: Any], let location = geometry["location"] as? [String: Any], let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                return (String(latitude), String(longitude))
            }
        }
        return ("", "")
    }

 
    private func clearForm() {
        keyword = ""
        category = "default"
        distance = "10"
        location = ""
        autoDetectLocation = false
        
        showResultsContainer = false
        NoRecordPrint = false
    }
    
    
    
    private func getSuggestions(keyword: String) async {
        stillProcessingSuggestion = true // before fetching suggestions
        
        // to encode the keyword. if not keyword containing space doesn't pas to URL
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://cs571hw8-381320.wn.r.appspot.com/api/autocomplete?keyword=\(encodedKeyword)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let suggestions = try JSONDecoder().decode([String].self, from: data)
            self.suggestions = suggestions
        } catch {
            print("Error fetching suggestions: \(error)")
        }
        stillProcessingSuggestion = false // after fetching suggestions
    }
    
    
    
}
