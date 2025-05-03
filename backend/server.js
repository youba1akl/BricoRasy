const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const connectDB = require("./config/db"); // importer
const userRoutes = require("./routes/userRoutes"); // 👈 importer les routes utilisateur
const serviceRoutes = require("./routes/serviceRoutes"); // 👈 importer les routes services
const postRoutes = require("./routes/postRoutes"); // 👈 importer les routes postes
const ratingRoutes = require("./routes/ratingRoutes"); // 👈 importer les routes rating
const reportRoute = require("./routes/reportRoute"); // 👈 importer les routes report
const annonceRoute=require("./routes/addanoo_route");
const outilRoute=require('./routes/addanno_outil_route')

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

// Connexion MongoDB
connectDB();

// Utiliser les routes report
app.use("/api/reports", reportRoute);
// Utiliser les routes poste
app.use("/api/posts", postRoutes);
// Utiliser les routes reting
app.use("/api/ratings", ratingRoutes);
// Utiliser les routes services
app.use("/api/services", serviceRoutes);
// Utiliser les routes utilisateur
app.use("/api/users", userRoutes);

//toutels les annonces ajout et geetter
app.use("/api/annonce",annonceRoute,outilRoute);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Serveur démarré sur le port ${PORT}`));
