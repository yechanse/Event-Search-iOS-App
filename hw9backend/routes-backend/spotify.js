

// Client ID     ...
// Client Secret ... 

// curl -X POST "https://accounts.spotify.com/api/token" \
// -H "Content-Type: application/x-www-form-urlencoded" \
// -d "grant_type=client_credentials&client_id=...&client_secret=..."


// https://developer.spotify.com/documentation/web-api/tutorials/getting-started#request-an-access-token
// The response will return an access token valid for 1 hour:


const express = require('express');
const axios = require('axios');
const qs = require('querystring');


const SpotifyWebApi = require('spotify-web-api-node');

const router = express.Router();

// Initialize the SpotifyWebApi object with your client id and client secret
const spotifyApi = new SpotifyWebApi({
    clientId: '...',
    clientSecret: '...'
});

async function fetchAccessToken() {
    const clientId = '...';
    const clientSecret = '...';
    const authString = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
    try {
        const response = await axios.post(
            'https://accounts.spotify.com/api/token',
            qs.stringify({ grant_type: 'client_credentials' }),
            {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    Authorization: `Basic ${authString}`,
                },
            }
        );
        return response.data.access_token;
    } catch (error) {
        console.error('Error fetching access token:', error.message);
        throw error;
    }
}

// albums
async function fetchAlbumCovers(artistId) {
    try {
        const { body } = await spotifyApi.getArtistAlbums(artistId, { limit: 50 }); // Fetch up to 50 albums
        const albums = body.items;
        if (!albums || albums.length === 0) {
            // console.log("empty album");
            return [];}

        // Sort albums by popularity
        albums.sort((a, b) => b.popularity - a.popularity);
        // Extract the cover images for the top 3 albums
        const top3AlbumCovers = albums.slice(0, 3).map(album => !album.images[0] || album.images[0].url ? album.images[0].url : '' ) .filter(url => url !== '');;
        return top3AlbumCovers;
    } catch (error) {
        console.error('Error fetching album covers:', error.message);
        // throw error;
        return [];
    }
}


router.get('/', async (req, res) => {
    const artists = JSON.parse(req.query.artists); // artists is an array that has artist names (ex) [ 'P!NK', 'Pat Benatar & Neil Giraldo', 'Grouplove', 'KidCutUp' ] 
    
    if (!artists || artists === []){
        res.send(); } // if empty array, just send empty array

    try {
        //  Retrieve a new access token if the current one has expired or is not set
        // if (!spotifyApi.getAccessToken()) {
        // console.log("Access token not set or has expired, retrieving new token");
        const accessToken = await fetchAccessToken();
        // console.log("New access token retrieved:", accessToken);
        spotifyApi.setAccessToken(accessToken);
        // console.log("Token are set now,,,,, artists:", artists);
        // }
        // spotifyApi.setAccessToken('...');
            
        const artistResults = [];
        for (const artistName of artists) {
            // Search for the artist by name
            const { body } = await spotifyApi.searchArtists(artistName);
            
            // Extract the artist information from the response
            const artist = body.artists.items.find(item => item.name.toLowerCase() === artistName.toLowerCase());

            if (artist) {
                const name = artist.name;
                const artistImage = artist.images && artist.images.length > 0 ? artist.images[0].url : ""; // null; 
                const followers = artist.followers.total.toLocaleString() || '';
                const popularity = artist.popularity || '';
                const spotifyLink = artist.external_urls.spotify || '';
                const spotifyArtistID = artist.id;
                const albumCovers = await fetchAlbumCovers(spotifyArtistID);

                // console.log("Artist found:", name, artistImage, followers, popularity, spotifyLink, albumCovers);
                
                artistResults.push({
                    name,
                    artistImage,
                    followers,
                    popularity,
                    spotifyLink,
                    albumCovers
                });
            } 
            else { 
                console.log("Artist not found");    
                // artistResults.push({ error: `Artist '${artistName}' not found` });
            }
        }
        res.send(artistResults);
    } catch (error) {
        // console.log("Error searching for artist:", error.message);
        res.send({ error: error.message });
    }
});
  
// Exporting router for usage in other modules
module.exports = router;

