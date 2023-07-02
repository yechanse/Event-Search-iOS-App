//#TICKETMASTER_KEY = "." #https://app.ticketmaster.com/discovery/v2/events.json?apikey=YOUR_API_KEY
//#GEOCODING_KEY = "." # https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=YOUR_API_KEY
//#IPINFO_TOKEN = "." #  https://ipinfo.io/?token=YOUR_TOKEN_ID


const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: false }));


const port = 3000;

// const port = process.env.PORT || 8080;

const autocompleteRouter = require('./routes-backend/autocomplete');
const eventResultRouter = require('./routes-backend/eventresult');
const eventDetailRouter = require('./routes-backend/eventdetail');
const venueRouter = require('./routes-backend/venue');
const spotifyRouter = require('./routes-backend/spotify');

app.use((req,res,next) =>{
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  next();
});

app.use('/api/autocomplete', autocompleteRouter);
app.use('/api/eventresult', eventResultRouter);
app.use('/api/eventdetail', eventDetailRouter);
app.use('/api/venue', venueRouter);
app.use('/api/spotify', spotifyRouter);


app.use(cors());

app.use(express.static(process.cwd()+"/dist/myproject8/"));

app.get('/', (req,res) => {
  console.log("//.....");
  res.sendFile(process.cwd()+"/dist/myproject8/index.html")
});

app.get('/search', (req,res) => {
  console.log("//search.....");
  res.sendFile(process.cwd()+"/dist/myproject8/index.html")
});

app.get('/favorites', (req,res) => {
  console.log("//favorites....");
  res.sendFile(process.cwd()+"/dist/myproject8/index.html")
});









app.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
  console.log("");
});