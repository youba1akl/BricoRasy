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

exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "Utilisateur non trouvé" });
    }
    res.json(user);
  } catch (err) {
    console.error("Error fetching user by ID:", err);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// THIS line must reference the function you exported
router.get('/artisans',    getArtisans);



module.exports = router;
