// backend/server.js
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const path = require("path"); // For serving static files
const connectDB = require("./config/db");
const userRoutes = require("./routes/userRoutes");
const serviceRoutes = require("./routes/serviceRoutes");
const postRoutes = require("./routes/postRoutes");
const ratingRoutes = require("./routes/ratingRoutes");
const reportRoute = require("./routes/reportRoute");
const annonceRoute = require("./routes/addanoo_route");
const outilRoute = require('./routes/addanno_outil_route');
const proRoute = require('./routes/add_anno_profRoute');

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());


app.use(
  '/uploads',
  express.static(path.join(__dirname, 'uploads'))
);

connectDB();

app.use("/api/reports", reportRoute);
app.use("/api/posts", postRoutes);
app.use("/api/ratings", ratingRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/users", userRoutes);

// Combined route for different announcement types
// The specific paths like '/professionnel' are defined within each router (proRoute, outilRoute, etc.)
app.use("/api/annonce", annonceRoute); // Handles general /api/annonce paths (e.g., /bricole)
app.use("/api/annonce", outilRoute);   // Handles /api/annonce/outil paths
app.use("/api/annonce", proRoute);     // Handles /api/annonce/professionnel paths


const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Serveur démarré sur le port ${PORT}`));