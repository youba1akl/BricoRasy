const express = require("express");
const router = express.Router();
const {
  registerUser,
  loginUser,
  sendOTP,
  verifyOTP,
} = require("../controllers/userController");

// Route pour inscrire un utilisateur
router.post("/register", registerUser);

// Route pour connecter un utilisateur
router.post("/login", loginUser);

// Route pour envoyer OTP
router.post("/send-otp", sendOTP);

// Route pour vérifier OTP
router.post("/verify-otp", verifyOTP);

module.exports = router;
