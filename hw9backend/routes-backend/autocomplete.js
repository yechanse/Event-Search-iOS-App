const express = require('express');
const axios = require('axios');

const router = express.Router();

router.get('/', async (req, res) => {
    const { keyword } = req.query;
    try {
    const response = await axios.get(`https://app.ticketmaster.com/discovery/v2/suggest?apikey=..&keyword=${keyword}`);
    const attractions = response.data._embedded?.attractions
        ?.filter(attraction => attraction.hasOwnProperty('name') && attraction.name !== null && attraction.name.trim() !== '')
        ?.map(attraction => attraction.name) || [];
    res.json(attractions);
    } catch (error) {
        console.log(error);
    }}
    );

module.exports = router;
