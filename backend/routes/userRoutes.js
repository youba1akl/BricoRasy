// routes/userRoutes.js
const express = require('express');
const {
  registerUser,
  loginUser,
  sendOTP,
  verifyOTP,
  getArtisans
} = require('../controllers/userController');  // ← correct relative path

const router = express.Router();               // ← THIS must be express.Router()

router.post('/register',   registerUser);
router.post('/login',      loginUser);
router.post('/send-otp',   sendOTP);
router.post('/verify-otp', verifyOTP);

// THIS line must reference the function you exported
router.get('/artisans',    getArtisans);

module.exports = router;
