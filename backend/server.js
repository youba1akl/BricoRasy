// backend/server.js
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const path = require("path");
const http = require("http");                     // ← ajouté
const { Server } = require("socket.io");           // ← ajouté

const connectDB = require("./config/db");
const userRoutes     = require("./routes/userRoutes");
const serviceRoutes  = require("./routes/serviceRoutes");
const postRoutes     = require("./routes/postRoutes");
const ratingRoutes   = require("./routes/ratingRoutes");
const reportRoute    = require("./routes/reportRoute");
const annonceRoute   = require("./routes/addanoo_route");
const outilRoute     = require('./routes/addanno_outil_route');
const proRoute       = require('./routes/add_anno_profRoute');
const reviewRoute       = require('./routes/reviewRoute');

const { authorizeSocket } = require("./middleware/socketAuth"); // ← ajouté

dotenv.config();

const app = express();
const server = http.createServer(app);             // ← modifié
const io     = new Server(server, {
  cors: { origin: "*" }
});
app.set('io', io);


// Middlewares HTTP
app.use(express.json());
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Connexion DB
connectDB();

// Routes REST
app.use("/api/reports", reportRoute);
app.use("/api/posts", postRoutes);
app.use("/api/ratings", ratingRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/users", userRoutes);
app.use("/api/annonce", annonceRoute);
app.use("/api/annonce", outilRoute);
app.use("/api/annonce", proRoute);
+app.use("/api/reviews", require("./routes/reviewRoute"));
app.use('/api/messages', require('./routes/messageRoute'));
// ====== SOCKET.IO ======

// 1) Authentification des sockets via ton middleware
io.use(authorizeSocket);

// 2) Gestion de la connexion
io.on("connection", socket => {
  console.log(`Socket connectée : ${socket.id} (utilisateur ${socket.user.email})`);

  // Exemple : rejoindre une room d’annonce
  socket.on("joinAnnonce", annonceId => {
    socket.join(`annonce_${annonceId}`);
  });

  // Exemple : quitter la room
  socket.on("leaveAnnonce", annonceId => {
    socket.leave(`annonce_${annonceId}`);
  });

  // Exemple : envoyer un message dans la room
  socket.on("sendMessage", ({ annonceId, toUserId, content }) => {
    // tu peux sauvegarder le message en base ici…
    const payload = {
      from: socket.user.id,
      to: toUserId,
      content,
      annonceId,
      timestamp: new Date()
    };
    // puis diffuser à tous les connectés dans la room
    io.to(`annonce_${annonceId}`).emit("newMessage", payload);
  });

  socket.on("disconnect", () => {
    console.log(`Socket déconnectée : ${socket.id}`);
  });
});

// Démarrage du serveur HTTP + WebSocket
const PORT = 5000;
server.listen(PORT, () => console.log(`Serveur démarré sur le port ${PORT}`));
