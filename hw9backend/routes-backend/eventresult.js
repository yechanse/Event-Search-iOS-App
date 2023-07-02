const express = require('express');
const axios = require('axios');
const geohash = require('ngeohash');

const router = express.Router();

router.get('/', async (req, res) => {
    const { keyword, distance, category, location } = req.query;
    const [latitude = 0, longitude = 0] = location ? location.split(',').map(parseFloat) : [0, 0];
    // console.log(latitude, longitude, "-");
    const geoResult = geohash.encode(latitude, longitude);
    const segmentIDdict = {
        default: '',
        music: 'KZFzniwnSyZfZ7v7nJ',
        sports: 'KZFzniwnSyZfZ7v7nE',
        arts: 'KZFzniwnSyZfZ7v7na',
        film: 'KZFzniwnSyZfZ7v7nn',
        miscellaneous: 'KZFzniwnSyZfZ7v7n1'
    };   
    try{
        const response = await axios.get(`https://app.ticketmaster.com/discovery/v2/events.json?apikey=...&keyword=${keyword}&segmentId=${segmentIDdict[category]}&radius=${distance}&unit=miles&geoPoint=${geoResult}`);
        // console.log(keyword, distance, geoResult, category, segmentIDdict[category], "-------------------", response);//
        const events = response.data._embedded && response.data._embedded.hasOwnProperty('events') ? response.data._embedded.events : [];

        // Processing events data to extract the required fields and limiting the results to maximum of 20 events
        const processedEvents = [];
        for (let i = 0; i < events.length && i < 20; i++) {
            if (events[i].hasOwnProperty('name')){
                const event = events[i];
                const processedEvent = {
                    eventID: event.id || '',
                    date: `${event.dates.start.localDate || ''}`,
                    dateTime: `${event.dates.start.localTime || ''}`,
                    icon: event.images && event.images.length > 0 ? event.images[0].url : '',
                    name: event.name || '',
                    genre: event.classifications && event.classifications.length > 0 ? event.classifications[0].segment.name || '' : '',
                    venue: event._embedded && event._embedded.venues && event._embedded.venues.length > 0 ? event._embedded.venues[0].name || '' : ''
                };
            console.log("여기", processedEvent);
            processedEvents.push(processedEvent);
            }
        }
        processedEvents.sort((a, b) => {
            const dateA = a.date;
            const dateTimeA = a.dateTime || '00:00:00';
            const dateB = b.date;
            const dateTimeB = b.dateTime || '00:00:00';
            const A_time = new Date(`${dateA}T${dateTimeA}`);
            const B_time = new Date(`${dateB}T${dateTimeB}`);
            return A_time - B_time;
        });
        res.json(processedEvents);
    } catch (error) {
        res.json([]);
        console.error(error);
        // res.status(500).json({ error: 'An error occurred while fetching events' });
    }
});

// Exporting router for usage in other modules
module.exports = router;
