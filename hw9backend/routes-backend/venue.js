const express = require('express');
const axios = require('axios');

const router = express.Router();



router.get('/', async (req, res) => {
    const { venueName } = req.query;

    const vname = venueName;

    axios.get(`https://app.ticketmaster.com/discovery/v2/venues?apikey=....&&keyword=${venueName}`)
    .then(function (response) {
      // console.log("백앤드 베뉴에서 Response 받았습니다.\n\n", response, "\n\n");
      const venues = response.data._embedded ? response.data._embedded.venues : [];
      const processedVenues = [];

      for (let i = 0; i < venues.length; i++) {
        // Venue Name(0)
        const venue = venues[i];

       
        // Address (0)
        const addressArr = [];
        if (venue.address && venue.address.line1) {
          addressArr .push(venue.address.line1);
        }
        if (venue.city && venue.city.name) {
          addressArr .push(venue.city.name);
        }
        if (venue.state && venue.state.name) {
          addressArr.push(venue.state.name);
        }
        const address = addressArr.length > 0 ? addressArr.join(', ') : '';

        // Phone Number
        const phoneNumberRegex = /\(\s*\d{3}\s*\)\s*\d{3}[- ]?\d{4}/g;
        const phoneNumberMatch = venue.boxOfficeInfo?.phoneNumberDetail?.match(phoneNumberRegex);
        const phoneNumber = phoneNumberMatch ? phoneNumberMatch[0] : '';

        // Open Hours
        const openHours = venue.boxOfficeInfo ? venue.boxOfficeInfo.openHoursDetail : '';

        // General Rule
        const generalRule = venue.generalInfo ? venue.generalInfo.generalRule : '';

        // Child Rule
        const childRule = venue.generalInfo ? venue.generalInfo.childRule : '';
        const latitude = venue.location? venue.location.latitude: '';
        const longitude = venue.location? venue.location.longitude: '';
        processedVenues.push({
          venueName: venueName, 
          address: address,
          phoneNumber: phoneNumber,
          openHours: openHours,
          generalRule: generalRule,
          childRule: childRule,
          latitude: latitude,
          longitude, longitude
        });
      }
      if (processedVenues.length === 0){res.send("")
      } else {res.send(processedVenues);}
    })
    .catch(function(error) {
        console.log(error);
        res.send([]);
    });
});

// Exporting router for usage in other modules
module.exports = router;

