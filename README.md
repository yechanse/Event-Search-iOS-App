# Ticketmaster Event Search - iOS App

This project is an iOS app for event searching, developed using SwiftUI. It allows users to search for events, view event details, and obtain information about artists, venues, and albums. The app integrates with various APIs to fetch event data and provide additional functionalities.


## Demo (Click the URL below to view the project demo on YouTube)
<img src="https://github.com/yechanse/Event-Search-iOS-App/assets/122432845/cf013550-9599-43f5-b6be-90037508421a" alt="iOS App Project Demo Video" width="300" height="600" />

<br>
https://youtu.be/WTNoXApsUcg

<br><br>
## Features

- Event Search: Allows users to search for events using keywords and location.
- Auto Complete Search: Provides suggestions and auto-completion for search queries.
- General Event Info: Retrieves general information about events, including distance, category, and location.
- Event Details: Displays detailed information about a selected event.
- Venue Info: Retrieves information about a specific venue.
- Artist & Album Info: Fetches information about artists and albums.
- Location Detection: Utilizes the Ipinfo API to find the user's location based on their IP address.
- Social Media Integration: Integrates with the Twitter and Facebook APIs to allow users to share event information.
- Spotify Integration: Utilizes the Spotify API to fetch artist and album data.


## Technologies Used

| Area     | Technologies         |
| -------- | -------------------- |
| Backend  | Node.js + Express.js |
| Frontend | SwiftUI              |
<br><br>
## Server side code

### Library Used

| Libraries Used | Purpose                                         |
| -------------- | ----------------------------------------------- |
| `axios`        | For making API calls to the Finnhub API         |
| `cors`         | To handle cross-origin-resource-sharing issues  |
| `nodemon`      | For hot reloading of the node server            |
| `express`      | For making use of the Express Node.js framework |

### APIs
- Ticketmaster API: Integrates with the Ticketmaster service to fetch event data.
- Google Maps API: Utilized for location-based features and mapping functionalities.
- Ipinfo API: Used for location detection based on the user's IP address.
- Twitter API: Integrated for social media sharing functionality.
- Facebook API: Integrated for social media sharing functionality.
- Spotify API: Utilized for fetching artist and album data.

### API endpoints
The iOS application communicates with the backend using the following major API endpoints:
<br>

| Purpose                 | Endpoint                   | Query Params                                           | Example                                                                                                                   |
| ----------------------- | -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| Auto Complete Search    | /api/autocomplete          | keyword                                                | [autocomplete](https://cs571hw8-381320.wn.r.appspot.com/api/autocomplete?keyword=Ed%20Sheeran)                                       |
| General Event Result      | /api/eventresult           | keyword, distance, category, location, autoDetectLocation | [eventresult](https://cs571hw8-381320.wn.r.appspot.com/api/eventresult?keyword=Ed%20Sheeran&distance=50&category=default&location=34.0294,-118.2871&autoDetectLocation=true) |
| Event Details           | /api/eventdetail           | eventID                                                | [eventdetail](https://cs571hw8-381320.wn.r.appspot.com/api/eventdetail?eventID=vvG1IZ9KBiqNAT)                                |
| Venue Info              | /api/venue                 | venueName                                              | [venue](https://cs571hw8-381320.wn.r.appspot.com/api/venue?venueName=Hollywood%20Pantages%20Theatre)                    |
| Artist, Teams & Album Info     | /api/spotify               | artists                                                | [spotify](https://cs571hw8-381320.wn.r.appspot.com/api/spotify?artists=[%22Taylor%20Swift%22,%20%22HAIM%22])               |

