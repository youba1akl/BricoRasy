// backend/routes/userRoutes.js
const express = require('express');
const router = express.Router(); // Ensure this is express.Router()

// Import all necessary controller functions
const {
  registerUser,
  loginUser,
  sendOTP,
  verifyOTP,
  getArtisans,
  getMyProfile,      // <-- NEW IMPORT
  updateMyProfile,   // <-- NEW IMPORT
  getUserById        // <-- NEW IMPORT
} = require('../controllers/userController');

const authMiddleware = require('../middleware/auth'); // Your existing auth middleware
const uploadProfilePicture = require('../middleware/profileUploads'); // Multer for profile pics (create this file)

// --- Public Routes ---
// For registration, decide if profile picture is uploaded at the same time or later
// Option A: Profile picture uploaded during registration
router.post('/register', uploadProfilePicture, registerUser);
// Option B: No profile picture during initial registration (URL might be sent in body or set later)
// router.post('/register', registerUser);

router.post('/login', loginUser);
router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);

// Route to get all artisans (can be public or protected based on your app needs)
// If it needs to be protected, add authMiddleware: router.get('/artisans', authMiddleware, getArtisans);
router.get('/artisans', getArtisans);


// --- Protected Routes (Require Authentication via authMiddleware) ---

// Get the profile of the currently logged-in user
router.get('/me', authMiddleware, getMyProfile);

// Update the profile of the currently logged-in user
// This route uses multer 'uploadProfilePicture' if the client might send a new profile picture file.
// The fieldname in multer config ('profilePictureFile') must match what client sends for the file.
router.put('/me/profile', authMiddleware, uploadProfilePicture, updateMyProfile);
// If the client ONLY sends a URL for profilePicture (or empty string to delete)
// and never a file directly to this endpoint, you can remove 'uploadProfilePicture' middleware:
// router.put('/me/profile', authMiddleware, updateMyProfile);


// Route to get a specific user by their ID
// This should generally be placed AFTER more specific routes like '/me' or '/artisans'
// to avoid '/me' being interpreted as a userId.
// This can be public or protected. If protected: router.get('/:userId', authMiddleware, getUserById);
router.get('/:userId', getUserById);


module.exports = router;