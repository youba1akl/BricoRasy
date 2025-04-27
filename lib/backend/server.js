const express = require("express"); 
const dbConnect = require("./dbConnect"); 

const app = express();
const cors    = require('cors');
const annonces_bricole_Route=require('./models/apianno');
const annonces_outil_Route=require('./models/api_outil');

app.use(cors());
app.use(express.json());

const port = 8000;
const Database_url = 'mongodb+srv://sidalialili694:NQMHfLg7_86Lrd@cluster0.xyvhhrm.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0' ;

dbConnect(Database_url); 
app.use(annonces_bricole_Route);
app.use(annonces_outil_Route);


app.listen(port, () => console.log(`Server listening on ${port}`)); 
