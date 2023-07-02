//  EventDetailsView.swift
//  Created by Yechan Seo on 4/16/23.

import SwiftUI
import Kingfisher
import MapKit

struct EventDetail: Codable, Identifiable{
    let eventId: String
    let eventName: String
    let onlydate: String
    let date: String
    let genre: String
    let venue: String
    let priceRange: String
    let ticketStatus: TicketStatus
    let buyTicketUrl: String
    let seatMapUrl: String
    let artistsMusicRelated: [String]
    
    var id: String {
        eventId
    }

    struct TicketStatus: Codable {
        var color: String
        var status: String
    }
}

struct VenueDetail: Codable {
    // Name, Address, Phone Number, Open Hours, General Rule, Child Rule
    let venueName: String
    let address: String
    let phoneNumber: String
    let openHours: String
    let generalRule: String
    let childRule: String
    let latitude: String
    let longitude: String
}


// MapView
// Reference from Mapkit Documentation and https://stackoverflow.com/questions/56563660/accessing-mkmapview-elements-as-uiviewrepresentable-in-the-main-contentview-sw
struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 900, longitudinalMeters: 900)
        view.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}


struct SpotifyDetail: Codable, Identifiable {
    let id = UUID()
    let name: String
    let artistImage: String
    let followers: String
    let popularity: Int
    let spotifyLink: String
    let albumCovers: [String]
}



struct EventDetailsView: View {
    // data from SearchView
    let eventId: String
    let venue: String

    @State private var eventDetail: EventDetail? // for eventinfotab
    @State private var spotifyDetail: [SpotifyDetail]? // for spotifytab
    @State private var venueDetail:  VenueDetail? // for venuetab

    @State private var isLoading = false // progressview
    @State private var isLoadingVenue = false // progressview
    @State private var isLoadingSpotify = false // progressview
    
    

    var body: some View {
        VStack {
            if (isLoading){
                ProgressView("Please wait...") // Show spinner while loading
            } else if let eventDetail = eventDetail {
                TabView {
                        EventInfoTab(eventDetail: eventDetail)
                            .tabItem {
                                Image(systemName: "text.bubble.fill")
                                Text("Events")
                            }
                        SpotifyTab(spotifyDetails: spotifyDetail ?? [])
                            .tabItem {
                                Image(systemName: "guitars.fill")
                                Text("Artist/Team")
                            }
                        VenueTab(venueDetail: venueDetail, eventName: eventDetail.eventName)
                            .tabItem {
                                Image(systemName: "location.fill")
                                Text("Venue")
                            }
                }
            } else {
                Text("Error loading event due to the server")
            }
        }
        .task {
            await loadEventDetails()
            await loadSpotifyDetails()
            await loadVenueDetails()
        }
    }

    private func loadEventDetails() async {
        isLoading = true
        do {
            eventDetail = try await callEventDetailAPI()
            isLoading = false
        } catch {
            print("Error loading event details: \(error)")
            isLoading = false
        }
    }

    private func loadSpotifyDetails() async {
        print("loadSpotifyDetails.......")
        isLoadingSpotify = true
        do {
            spotifyDetail = try await callSpotifyAPI()
            isLoadingSpotify = false
        } catch {
            print("Error loading artist details: \(error)")
            isLoadingSpotify = false
        }
    }
    private func loadVenueDetails() async {
        print("start loadVenueDetails... about to callVenueAPI")
        isLoadingVenue = true
        do {
            venueDetail = try await callVenueAPI()
            isLoadingVenue = false
        } catch {
            print("Error loading venue details: \(error)")
            isLoadingVenue = false
        }
    }
}


struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(eventId: "vvG1IZ9KBiqNAT", venue: "Levi's® Stadium")
    }
}



extension EventDetailsView {
    // for the API call, I used the documentation reference for all 3 different APIs
    // Event Results API call
    private func callEventDetailAPI() async throws -> EventDetail {
        let url = URL(string: "https://cs571hw8-381320.wn.r.appspot.com/api/eventdetail")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "eventID", value: eventId),
        ]
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let eventDetailData = try decoder.decode(EventDetail.self, from: data)
        return eventDetailData
    }
    
    // Spotify API call
    private func callSpotifyAPI() async throws -> [SpotifyDetail] {
        let url = URL(string: "https://cs571hw8-381320.wn.r.appspot.com/api/spotify")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        guard let eventDetail = eventDetail else {
            throw NSError(domain: "EventDetailError", code: -1, userInfo: [NSLocalizedDescriptionKey: "EventDetail is nil"])
        }
        let encoder = JSONEncoder()
        let artistNamesData = try encoder.encode(eventDetail.artistsMusicRelated)
        let artistNamesString = String(data: artistNamesData, encoding: .utf8)

        components.queryItems = [
            URLQueryItem(name: "artists", value: artistNamesString),
        ]
        
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let spotifyDetailData = try decoder.decode([SpotifyDetail].self, from: data)
        return spotifyDetailData
    }

    
    
    private func callVenueAPI() async throws -> VenueDetail {
        let url = URL(string: "https://cs571hw8-381320.wn.r.appspot.com/api/venue")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "venueName", value: venue),
        ]
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let venueDetailDataArray = try decoder.decode([VenueDetail].self, from: data)
        guard let venueDetailData = venueDetailDataArray.first else {
            throw NSError(domain: "No venue detail found", code: -1, userInfo: nil)
        }
        return venueDetailData
    }
}


//EventInfoTab View
struct EventInfoTab: View {
    let eventDetail: EventDetail
    
    @State private var buttomAlertMessage = ""

    @State private var isEventFavorite: Bool = false

    
    @State var showToast: Bool = false
    
    
    private var ticketStatusConvert: (color: Color, status: String) {
        if let ticketStatus = eventDetail.ticketStatus as EventDetail.TicketStatus? {
            switch ticketStatus.status {
            case "On Sale":
                return (color: .green, status: "On Sale")
            case "Postponed":
                return (color: .orange, status: "Postponed")
            case "Rescheduled":
                return (color: .orange, status: "Rescheduled")
            case "Off Sale":
                return (color: .red, status: "Off Sale")
            case "Canceled":
                return (color: .black, status: "Canceled")
            default:
                return (color: .green, status: "On Sale") // dealing side cases
            }
        } else{
            return (color: .green, status: "On Sale")
        }
    }

    var body: some View {
        ZStack{
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Text(eventDetail.eventName)
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 3)
                        Spacer()
                    }
                    
                    // 1st row
                    HStack{
                        VStack (alignment: .leading){
                            Text("Date")
                                .font(.system(size: 17, weight: .bold))
                            Text(eventDetail.onlydate)
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("Artist | Team")
                                .font(.system(size: 17, weight: .bold))
                            HStack {
                                let artistNames = eventDetail.artistsMusicRelated.joined(separator: " ")
                                Text(artistNames) //
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }.padding(.bottom, 5)
                    
                    // 2nd row
                    HStack{
                        VStack(alignment: .leading){
                            Text("Venue")
                                .font(.system(size: 17, weight: .bold))
                            Text(eventDetail.venue)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing){
                            Text("Genre")
                                .font(.system(size: 17, weight: .bold))
                            Text(eventDetail.genre)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }.padding(.bottom, 5)
                    
                    
                    // 3rd row
                    HStack{
                        VStack(alignment: .leading){
                            Text("Price Range")
                                .font(.system(size: 17, weight: .bold))
                            Text(eventDetail.priceRange)
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("Ticket Status")
                                .font(.system(size: 17, weight: .bold))
                            ZStack{
                                Rectangle()
                                    .frame(width: 100, height: 25)
                                    .cornerRadius(5)
                                    .foregroundColor(ticketStatusConvert.color)
                                Text(ticketStatusConvert.status)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }.padding(.top, -5)
                        }
                    }.padding(.bottom, 5)
                    
       
                    
                    Button(action: {
                        if self.isEventFavorite {
                            self.showToast.toggle()
                            buttomAlertMessage = "Removed from favorites."
                            FavoritesClass.removeFavorite(event: eventDetail)
                        } else {
                            self.showToast.toggle()
                            buttomAlertMessage = "Added from favorites."
                            FavoritesClass.saveFavorite(event: eventDetail)
                        }
                        isEventFavorite.toggle()
                    }) {
                        if self.isEventFavorite {
                            Text("Remove F...")
                                .foregroundColor(.white)
                                .frame(width: 111, height: 55)
                                .background(Color.red)
                                .cornerRadius(10)
                        } else {
                            Text("Save Event")
                                .foregroundColor(.white)
                                .frame(width: 111, height: 55)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing)//
                    
                    
                    
                    if !eventDetail.seatMapUrl.isEmpty {
                        KFImage(URL(string: eventDetail.seatMapUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 180)
                    } else{
                        VStack{
                            Spacer()
                            Spacer()
                        }
                    }
                    
                    
                    HStack{
                        Text("Buy Ticket At: ")
                            .font(.system(size: 17, weight: .bold))
                        Link("Ticketmaster", destination: URL( string: eventDetail.buyTicketUrl)!)
                    }
                    HStack{
                        Text("Share on:")
                            .font(.system(size: 17, weight: .bold))
                        // two buttons
                        Button(action: {
                            if let url = URL(string: "http://www.facebook.com/sharer/sharer.php?u=\(eventDetail.buyTicketUrl)") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("facebookIcon")
                                .resizable()
                                .frame(width:38, height: 38)
                        }
                        
                        Button(action: {
                            let urlString = "https://twitter.com/intent/tweet?text=Check%20\(eventDetail.eventName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&url=\(eventDetail.buyTicketUrl)"
                            
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image("twitterIcon")
                                .resizable()
                                .frame(width: 38, height: 38)
                        }
                    }
                }
                .padding()
                .onAppear {
                    isEventFavorite = FavoritesClass.isEventFavorite(event: eventDetail)
                }
            }
            .toast(isShowing: $showToast, text: Text(buttomAlertMessage))
        }
    }
}

// EventInfoTab Preivew
struct EventInfoTab_Previews: PreviewProvider {
    static var previews: some View {
        EventInfoTab(eventDetail: sampleEventDetail)
    }
    static let sampleEventDetail = EventDetail(
        eventId: "Z7r9jZ1AdqPJo",
        eventName: "UCLA Bruins Football vs. Arizona State Sun Devils Football",
        onlydate: "2023-11-11",
        date: "2023-11-11",
        genre: "Sports | Football | College",
        venue: "Rose Bowl",
        priceRange: "49.0-159.0",
        ticketStatus: EventDetail.TicketStatus(color: "green", status: "On Sale"),
        buyTicketUrl: "https://www.ticketmaster.com/event/Z7r9jZ1AdqPJo",
        seatMapUrl: "",
        artistsMusicRelated: ["Pink", "Yechan"]
    )
}


// VenueTab
struct VenueTab: View {
    let venueDetail: VenueDetail?
    let eventName: String
    @State private var showMapView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 10) {
                if let venueDetail = venueDetail {
                    Text(eventName)
                        .font(.system(size: 21, weight: .bold))
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.center)
                    
                    VStack {
                        Text("Name")
                            .font(.system(size: 16, weight: .bold))
                        Text(venueDetail.venueName)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15))
                    }
                    VStack {
                        Text("Address")
                            .font(.system(size: 16, weight: .bold))
                        Text(venueDetail.address)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15))
                    }
                    VStack {
                        Text("Phone Number")
                            .font(.system(size: 16, weight: .bold))
                        Text(venueDetail.phoneNumber)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15))
                    }
                    VStack {
                        Text("Open Hours")
                            .font(.system(size: 16, weight: .bold))
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(venueDetail.openHours)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 3 * 16 * 1.2)
                    }
                    VStack {
                        Text("General Rule")
                            .font(.system(size: 16, weight: .bold))
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(venueDetail.generalRule)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 3 * 16 * 1.2)
                    }
                    
                    VStack {
                        Text("Child Rule")
                            .font(.system(size: 16, weight: .bold))
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(venueDetail.childRule)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 3 * 16 * 1.2)
                    }.padding(.bottom,10)
                    
                    Button(action: {
                        showMapView = true
                    }) {
                        Text("Show venue on maps")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                } else {
                    Text("Loading venue details...")
                }
            }
            .sheet(isPresented: $showMapView) {
                if let venue = venueDetail, let latitude = Double(venue.latitude), let longitude = Double(venue.longitude) {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("Venue Location", displayMode: .inline)
                        .padding(20)
                        .cornerRadius(20)
                }
            }
            .padding()
        }
    }
}


struct VenueTab_Previews: PreviewProvider {
    static var previews: some View {
        VenueTab(venueDetail: sampleVenueDetail, eventName: "event sample name")
    }
    static let sampleVenueDetail = VenueDetail(
        venueName: "Rose Bowl",
        address: "1001 Rose Bowl Dr, Pasadena, CA 91103",
        phoneNumber: "(626) 577-3100",
        openHours: "Open 24 hours",
        generalRule: "No outside food or beverages allowedNo outside food or beverages allowedNo outside food or beverages allowedNo outside food or beverages allowedNo outside food or beverages allowedNo outside food or beverages allowedNo outside food or beverages allowed.",
        childRule: "Children under 2 are admiunder 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted under 2 are admitted tted free.",
        latitude: "34.1613",
        longitude: "-118.1676"
    )
}


// Spotify Tab for Artist/Team
struct SpotifyTab: View {
    let spotifyDetails: [SpotifyDetail]
    
    var body: some View {
        VStack{ // wrap the whole...
            if spotifyDetails.isEmpty {
                Text("No music related artist details to show")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    ForEach(spotifyDetails) { detail in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 1) {
                                
                                // ARTIST PICTURE
                                AsyncImage(url: URL(string: detail.artistImage)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .clipped()
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                }
                                
                                // Artist Name, Followers, Spotify Link
                                VStack(alignment: .leading, spacing: 15) {
                                    Text(detail.name)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                    HStack {
                                        let numberFormat = formatFollowers(detail.followers)
                                        Text(numberFormat)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Followers")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                    }
                                    HStack {
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: detail.spotifyLink)!)
                                        }, label: {
                                            Image("spotifyIcon")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(.white)
                                        })
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text("Spotify")
                                            .foregroundColor(.green)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }.frame(maxWidth: .infinity)
                                
                                // Populairty and ProgressView
                                VStack(spacing: 15) {
                                    Text("Popularity")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                Color.orange.opacity(0.4),
                                                lineWidth: 11
                                            )
                                        Circle()
                                            .trim(from: 0, to: Double(detail.popularity) / 100.0)
                                            .stroke(
                                                Color.orange,
                                                lineWidth: 11
                                            )
                                        Text("\(detail.popularity)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }.frame(width: 50, height: 50)
                                }
                            }
                            
                            // Album Covers
                            Text("Popular Albums")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top,20)
                            HStack(spacing: 10) {
                                ForEach(detail.albumCovers, id: \.self) { cover in
                                    AsyncImage(url: URL(string: cover)) { image in image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    } placeholder: {
                                        Color.gray
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        } // VStack Ending
                        .padding(16)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.bottom,20)
                    }
                    
                } // ScrollView ending
                .padding(.leading) // left
                .padding(.trailing) // right
            } // else Ending
        }
    }
}

extension SpotifyTab {
    func formatFollowers(_ followers: String) -> String {
        // Reference OpenAI ChatGPT to construct formatFollowers calculation dealing with million and thousands
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let number = formatter.number(from: followers.replacingOccurrences(of: ",", with: ""))?.doubleValue ?? 0
        if number >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: number / 1_000_000.0)) ?? "0")M"
        } else {
            return "\(formatter.string(from: NSNumber(value: number / 1_000.0)) ?? "0")K"
        }
    }
}

//
//struct SpotifyTab_Previews: PreviewProvider {
//  static var previews: some View {
//      SpotifyTab(spotifyDetails: [
//          SpotifyDetail(name: "Taylor Swift", artistImage: "https://i.scdn.co/image/ab6761610000e5eb5a00969a4698c3132a15fbb0", followers: "72715051", popularity: 100, spotifyLink: "https://open.spotify.com/artist/06HL4z0CvFAxyc27GXpf02", albumCovers: ["https://i.scdn.co/image/ab67616d0000b273e0b60c608586d88252b8fbc0", "https://i.scdn.co/image/ab67616d0000b2734a97c76d7b4f6530f439c249", "https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5"]),
//          SpotifyDetail(name: "HAIM", artistImage: "https://i.scdn.co/image/ab6761610000e5eba688abfbbed1037befa47232", followers: "1,252,828", popularity: 66, spotifyLink: "https://open.spotify.com/artist/4Ui2kfOqGujY81UcPrb5KE", albumCovers: ["https://i.scdn.co/image/ab67616d0000b273667f8cfd1be0d0cc2b825e25", "https://i.scdn.co/image/ab67616d0000b2731bff3b5284c581b83e918d19", "https://i.scdn.co/image/ab67616d0000b2731f2842bb6040d15821cb81bb"]),
//          SpotifyDetail(name: "HAIM", artistImage: "https://i.scdn.co/image/ab6761610000e5eba688abfbbed1037befa47232", followers: "1,252,828", popularity: 66, spotifyLink: "https://open.spotify.com/artist/4Ui2kfOqGujY81UcPrb5KE", albumCovers: ["https://i.scdn.co/image/ab67616d0000b273667f8cfd1be0d0cc2b825e25", "https://i.scdn.co/image/ab67616d0000b2731bff3b5284c581b83e918d19", "https://i.scdn.co/image/ab67616d0000b2731f2842bb6040d15821cb81bb"])
//      ])
//  }
//}




class FavoritesClass {
    private static let favoritesKey = "favorites"
    static func isEventFavorite(event: EventDetail) -> Bool {
            let currentFavorites = getFavorites()
            return currentFavorites.contains { $0.eventId == event.eventId }
    }
    static func saveFavorite(event: EventDetail) {
        var favorites = getFavorites()
        favorites.append(event)
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
    }
    static func removeFavorite(event: EventDetail) {
        var favorites = getFavorites()
        favorites.removeAll { $0.eventId == event.eventId }
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
    }
    static func getFavorites() -> [EventDetail] {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decodedData = try? JSONDecoder().decode([EventDetail].self, from: data) {
            return decodedData
        }
        return []
    }
}



// reference from https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
struct Toast<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    var body: some View {
        if self.isShowing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isShowing = false
            }
        }
        return GeometryReader {  geometry in
            ZStack(alignment: .bottom) {
                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    self.text
                }
                .frame(width: 250,
                       height: 70)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .onAppear {
                    // reference from https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                      withAnimation {
                        self.isShowing = false
                      }
                    }
                }
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

// Reference continued for toast
extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}
