const express = require('express');
const axios = require('axios');

const router = express.Router();

function getDate(current){
    var date ='';
    if (current.dates.start.hasOwnProperty("localDate") && current.dates.start.hasOwnProperty("localTime")){
        date += String(current.dates.start.localDate) +' '+ String(current.dates.start.localTime);
    } else if (!current.dates.start.hasOwnProperty("localDate") && current.dates.start.hasOwnProperty("localTime")){
        date += String(current.dates.start.localTime);
    } else if (current.dates.start.hasOwnProperty("localDate") && !current.dates.start.hasOwnProperty("localTime")){
        date += String(current.dates.start.localDate);
    } else{
        return '';
    }
    return date;  
}
function getOnlyDate(current){
    if ( current.hasOwnProperty("dates") && current.dates.hasOwnProperty("start") && current.dates.start.hasOwnProperty("localDate")){
        return String(current.dates.start.localDate);}
}

function getArtistTeam(current){
    var artistTeam = '';
    if (!current._embedded.hasOwnProperty("attractions") || !current._embedded.attractions.hasOwnProperty(0)){
        return '';
    } else {
        for (var i=0; i<(current._embedded.attractions.length); i++){
            if (current._embedded.attractions[i].hasOwnProperty("name")){
                artistTeam += current._embedded.attractions[i].name ;
                if (i < (current._embedded.attractions.length-1)){
                    artistTeam += ' | ';                   
                }
            }
        }
    }
    return artistTeam ;
}

function getVenue(current){
    var venue = '';
    if (!current._embedded.venues[0].hasOwnProperty("name") || !current._embedded.hasOwnProperty("venues")){
        return '';
    }
    return current._embedded.venues[0].name ;     
}
function getGenre(current){
    var genre ='';
    var validList = [];
    if (current.classifications[0].hasOwnProperty("segment") && current.classifications[0].segment.hasOwnProperty("name") && current.classifications[0].segment.name !== "Undefined"){
        validList.push(current.classifications[0].segment.name);}
    if (current.classifications[0].hasOwnProperty("genre") && current.classifications[0].genre.hasOwnProperty("name") && current.classifications[0].genre.name !== "Undefined"){
        validList.push(current.classifications[0].genre.name);}
    if (current.classifications[0].hasOwnProperty("subGenre") && current.classifications[0].subGenre.hasOwnProperty("name")&& current.classifications[0].subGenre.name !== "Undefined"){
        validList.push(current.classifications[0].subGenre.name);}
    if (current.classifications[0].hasOwnProperty("type") && current.classifications[0].type.hasOwnProperty("name") && current.classifications[0].type.name !== "Undefined"){
        validList.push(current.classifications[0].type.name);}
    if (current.classifications[0].hasOwnProperty("subType") && current.classifications[0].subType.hasOwnProperty("name") && current.classifications[0].subType.name !== "Undefined"){
        validList.push(current.classifications[0].subType.name);}
    if (validList.length ===0){return '';}
    const uniqueSet = new Set(validList);
    validList.length = 0;
    uniqueSet.forEach((value) => validList.push(value));
    for (let i = 0; i < validList.length; i++) {
        genre += validList[i];
        if (i < (validList.length-1)){
            genre += ' | ';
        }
    }
    return genre;
}
function getPriceRange(current){
    if (current.hasOwnProperty("priceRanges")){
        if (current.priceRanges[0].hasOwnProperty("max") && current.priceRanges[0].hasOwnProperty("min")){
            if (!current.priceRanges[0].hasOwnProperty("currency")){
                return current.priceRanges[0].min + '-' +current.priceRanges[0].max;
            } else{
                return current.priceRanges[0].min + '-' +current.priceRanges[0].max}
        } else {return '';}
    } else {return '';}
}
function getTicketstatus(current){
    var color = {onsale: ['On Sale','green'], postponed: ['Postponed','orange'], rescheduled: ['Rescheduled','orange'], offsale: ['Off Sale','red'], cancelled: ['Canceled','black']};
    if (current.hasOwnProperty("dates") && current.dates.hasOwnProperty("status") && current.dates.status.hasOwnProperty("code")){
        return {color: color[current.dates.status.code][1], status: color[current.dates.status.code][0]}
    } else{return '';}
    // '<div class="text-data" > <div class="title" >Ticket Status</div> <div class="ticketstatus-box" style="display: flex; align-items: center;"> <div class="status-text" style="background-color:'+
}

function getBuyTicket(current){
    if (current.hasOwnProperty("url")){
        return current.url;
    } else{return '';}
}
function getSeatmap(current){
    if (current.hasOwnProperty("seatmap") && current.seatmap.hasOwnProperty("staticUrl")){
        return current.seatmap.staticUrl;
    } else{return '';}
}



// for artist/team api
function getArtistsMusicRelatedArray(eventData) {
    const artistsMusicRelated = [];
  
    if (eventData && eventData._embedded && eventData._embedded.attractions) {
      const attractions = eventData._embedded.attractions;
      for (let i = 0; i < attractions.length; i++) {
        const attraction = attractions[i];
        const classifications = attraction.classifications;

        // Check if the attraction is music-related
        if (classifications && classifications.length > 0 && classifications[0].segment && classifications[0].segment.name === 'Music') {
          // Add the attraction name to the array of music-related artists
          artistsMusicRelated.push(attraction.name);
        }
      }
    }
  
    return artistsMusicRelated;
  }

router.get('/', async (req, res) => {
    const {eventID}  = req.query;
    const eventDetailAPI = 'https://app.ticketmaster.com/discovery/v2/events/'+eventID+'?apikey=..&';
    const response = await axios.get(eventDetailAPI);
    const eventData = response.data;    

    // event id 
    const eventDetails = {
        eventId: eventData.id,
        eventName: eventData.name || 'No Event Name Data',
        onlydate: getOnlyDate(eventData),
        date: getDate(eventData), // date time
        genre: getGenre(eventData),
        venue: getVenue(eventData),
        priceRange: getPriceRange(eventData),
        ticketStatus: getTicketstatus(eventData), // {status: str, color: str}
        buyTicketUrl: getBuyTicket(eventData),
        seatMapUrl: getSeatmap(eventData),
        artistsMusicRelated: getArtistsMusicRelatedArray(eventData)
    };
    res.json(eventDetails);
    }
);

module.exports = router;


    

// Exporting router for usage in other modules

