const express = require("express"); 
const dbConnect = require("./connection/dbConnect"); 
const { movieModel, createDoc } = require("./connection/models/movies");
const app = express();
const cors    = require('cors');
app.use(cors());
app.use(express.json());

const port = 8000;
const Database_url = process.env.Database_url || 'mongodb://127.0.0.1/movies';

dbConnect(Database_url); 
app.use(annoncesRoute);

// app.get("/", async (req, res) => {
//     try {
//         await createDoc(); 
//         res.send("Movie added to the database!");
//     } catch (error) {
//         res.status(500).send("Error adding movie");
//     }
// });
app.listen(port, () => console.log(`Server listening on ${port}`)); 
