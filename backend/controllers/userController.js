// backend/controllers/userController.js
require('dotenv').config(); // Ensure JWT_SECRET is loaded from .env
const bcrypt    = require("bcryptjs");
const jwt       = require("jsonwebtoken");
const User      = require("../models/user");
const sendEmail = require("../utils/sendemail");
const fs        = require('fs'); // For file system operations (deleting old image)
const path      = require('path'); // For path operations

// Temporary in-memory OTP store
const otpStore = {};

const JWT_SECRET = process.env.JWT_SECRET || 'MaPhraseSecreteDeTest123!'; // Use environment variable
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1h';

/**
 * @desc    Register a new user
 * @route   POST /api/users/register
 */
exports.registerUser = async (req, res) => {
  const {
    fullname, email, password, phone,
    role, job, localisation, genre,
    birthdate
    // 'photo' or 'profilePicture' will be handled if sent as a file by multer
    // For now, assuming it might be a URL sent in body if not using file upload on register
  } = req.body;

  let profilePicturePath = req.body.photo || req.body.profilePicture || ""; // Default if sent as URL

  // If multer processed a file for profile picture on registration
  if (req.file && req.file.fieldname === 'profilePictureFile') { // Check fieldname if using specific multer for profile pic
    const serverBaseUrl = process.env.API_URL || `${req.protocol}://${req.get('host')}`;
    profilePicturePath = `${serverBaseUrl}/uploads/profiles/${req.file.filename}`;
  }

  try {
    if (await User.findOne({ email })) {
      // If a file was uploaded but user exists, delete the uploaded file
      if (req.file) fs.unlinkSync(req.file.path);
      return res.status(400).json({ message: "Cet email est déjà utilisé." });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      fullname, email, password: hashedPassword,
      phone, role, job, localisation,
      genre, birthdate, profilePicture: profilePicturePath, // Use the determined path
    });

    const token = jwt.sign(
      { id: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.status(201).json({
      token,
      user: {
        _id:          user._id,
        fullname:     user.fullname,
        email:        user.email,
        phone:        user.phone,
        role:         user.role,
        job:          user.job,
        localisation: user.localisation,
        genre:        user.genre,
        birthdate:    user.birthdate,
        profilePicture: user.profilePicture, // Send back the correct field name
        tarifs:       user.tarifs, // Send tarifs if any (will be empty for new user)
        createdAt:    user.createdAt,
      }
    });
  } catch (err) {
    console.error("Erreur Register User:", err);
    // If a file was uploaded but DB save failed, delete the uploaded file
    if (req.file) fs.unlinkSync(req.file.path);
    res.status(500).json({ message: "Erreur serveur lors de l'inscription." });
  }
};

/**
 * @desc    Authenticate user + return a JWT
 * @route   POST /api/users/login
 */
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect." });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect." });
    }
    const token = jwt.sign(
      { id: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    res.json({
      token,
      user: { // Ensure this matches your LoggedInUser model in Flutter
        _id:          user._id,
        fullname:     user.fullname,
        email:        user.email,
        phone:        user.phone,
        role:         user.role,
        job:          user.job,
        localisation: user.localisation,
        genre:        user.genre,
        birthdate:    user.birthdate,
        profilePicture: user.profilePicture, // Use profilePicture consistently
        tarifs:       user.tarifs,
        createdAt:    user.createdAt,
      }
    });
  } catch (err) {
    console.error("Erreur Login User:", err);
    res.status(500).json({ message: "Erreur serveur lors de la connexion." });
  }
};

/**
 * @desc    Get current logged-in user's profile
 * @route   GET /api/users/me
 * @access  Private (requires authMiddleware)
 */
exports.getMyProfile = async (req, res) => {
    try {
        // req.user is populated by authMiddleware
        const user = await User.findById(req.user.id).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé.' });
        }
        // Return all fields needed by LoggedInUser in Flutter
        res.json({
            _id: user._id,
            fullname: user.fullname,
            email: user.email,
            phone: user.phone,
            role: user.role,
            job: user.job,
            localisation: user.localisation,
            genre: user.genre,
            birthdate: user.birthdate,
            profilePicture: user.profilePicture,
            tarifs: user.tarifs,
            createdAt: user.createdAt,
        });
    } catch (error) {
        console.error("Erreur getMyProfile:", error);
        res.status(500).json({ message: 'Erreur serveur.' });
    }
};


/**
 * @desc    Update current logged-in user's profile (including artisan fields like tarifs)
 * @route   PUT /api/users/me/profile  (or PUT /api/users/profile if ID comes from auth token)
 * @access  Private (requires authMiddleware and potentially multer for profilePictureFile)
 */
exports.updateMyProfile = async (req, res) => {
  try {
    const userId = req.user.id; // From authMiddleware
    const userToUpdate = await User.findById(userId);

    if (!userToUpdate) {
      if (req.file) fs.unlinkSync(req.file.path); // Clean up uploaded file if user not found
      return res.status(404).json({ message: "Utilisateur non trouvé." });
    }

    // Fields that can be updated by any user
    const allowedUserUpdates = ['fullname', 'phone', 'localisation', 'birthdate', 'genre'];
    // Fields specific to artisans (or that artisans can update)
    const allowedArtisanUpdates = ['job', 'tarifs'];

    const updates = {};

    // Process text fields from req.body
    for (const key in req.body) {
      if (allowedUserUpdates.includes(key)) {
        updates[key] = req.body[key];
      }
      if (userToUpdate.role === 'artisan' && allowedArtisanUpdates.includes(key)) {
        if (key === 'tarifs') {
          if (Array.isArray(req.body.tarifs)) {
            // Basic validation for tarif items
            updates.tarifs = req.body.tarifs.map(t => ({
              serviceName: t.serviceName || '', // Ensure required fields have defaults if not sent
              price: t.price || '',
              _id: t._id || undefined // Keep existing _id if sent (for subdocument updates)
            })).filter(t => t.serviceName && t.price); // Filter out empty tarifs
          } else if (req.body.tarifs === null || req.body.tarifs === '') {
            updates.tarifs = []; // Allow clearing tarifs
          }
        } else {
          updates[key] = req.body[key];
        }
      }
    }

    // Handle profile picture update
    let oldProfilePicturePath = userToUpdate.profilePicture; // Keep track of old image

    if (req.file && req.file.fieldname === 'profilePictureFile') { // Check fieldname from multer
      const serverBaseUrl = process.env.API_URL || `${req.protocol}://${req.get('host')}`;
      updates.profilePicture = `${serverBaseUrl}/uploads/profiles/${req.file.filename}`;
      console.log("New profile picture path:", updates.profilePicture);
    } else if (req.body.profilePicture === '') { // Client explicitly wants to delete picture
      updates.profilePicture = ''; // Or set to your default image path if you have one
      console.log("Profile picture flagged for deletion.");
    }
    // If updates.profilePicture is now different from oldProfilePicturePath, and old one existed, delete it
    if (updates.profilePicture !== undefined && updates.profilePicture !== oldProfilePicturePath && oldProfilePicturePath && oldProfilePicturePath.startsWith(process.env.API_URL || `${req.protocol}://${req.get('host')}`)) {
        try {
            const filename = path.basename(new URL(oldProfilePicturePath).pathname); // Get filename from URL
            const localPath = path.join(__dirname, '../uploads/profiles', filename); // Construct local path
            if (fs.existsSync(localPath)) {
                fs.unlinkSync(localPath);
                console.log("Deleted old profile picture:", localPath);
            }
        } catch (e) {
            console.error("Error deleting old profile picture:", e);
        }
    }


    const updatedUser = await User.findByIdAndUpdate(userId, { $set: updates }, {
      new: true,
      runValidators: true,
    }).select("-password");

    if (!updatedUser) {
      if (req.file) fs.unlinkSync(req.file.path); // Clean up if update failed after upload
      return res.status(404).json({ message: "Mise à jour échouée, utilisateur non trouvé." });
    }
    res.status(200).json({
        _id:          updatedUser._id,
        fullname:     updatedUser.fullname,
        email:        updatedUser.email, // Email typically not updatable this way
        phone:        updatedUser.phone,
        role:         updatedUser.role,
        job:          updatedUser.job,
        localisation: updatedUser.localisation,
        genre:        updatedUser.genre,
        birthdate:    updatedUser.birthdate,
        profilePicture: updatedUser.profilePicture,
        tarifs:       updatedUser.tarifs,
        createdAt:    updatedUser.createdAt,
        updatedAt:    updatedUser.updatedAt, // Include updatedAt
    });

  } catch (error) {
    console.error("Erreur updateMyProfile:", error);
    if (req.file) fs.unlinkSync(req.file.path); // Generic cleanup for any error after upload
    if (error.name === 'ValidationError') {
      return res.status(400).json({ message: error.message });
    }
    res.status(500).json({ message: "Erreur serveur lors de la mise à jour du profil." });
  }
};


/**
 * @desc    Send an OTP to the given email
 * @route   POST /api/users/send-otp
 */
exports.sendOTP = async (req, res) => {
  try {
    const { email } = req.body;
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    otpStore[email] = otp;

    await sendEmail(
      email,
      "Votre code OTP BricoRasy",
      `Votre code de vérification est : ${otp}`
    );

    res.json({ message: "OTP envoyé avec succès" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur lors de l'envoi de l'OTP" });
  }
};

/** 
 * @desc    Verify the OTP for the given email
 * @route   POST /api/users/verify-otp
 */
exports.verifyOTP = (req, res) => {
  const { email, otp } = req.body;
  try {
    if (otpStore[email] === otp) {
      delete otpStore[email];
      return res.json({ message: "OTP vérifié avec succès" });
    }
    res.status(400).json({ message: "OTP incorrect" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur lors de la vérification de l'OTP" });
  }
};

/** 
 * @desc    Get all users whose role is “artisan”
 * @route   GET /api/users/artisans
 */
exports.getArtisans = async (req, res) => {
  try {
    const artisans = await User
      .find({ role: "artisan" })
      .select("-password");
    res.json(artisans);
  } catch (err) {
    console.error("Error fetching artisans:", err);
    res.status(500).json({ error: "Erreur serveur lors de récupération." });
  }
};


/**
 * @desc    Get a specific user by ID (can be an artisan or simple user)
 * @route   GET /api/users/:userId
 * @access  Public (or protected)
 */
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId)
                           .select("-password")
                           .populate("posts") // Example: if you want to show posts count or snippets
                           .populate("services"); // Example

    if (!user) {
      return res.status(404).json({ message: "Utilisateur non trouvé." });
    }
    // Return the user object, client can decide how to display based on role
    res.status(200).json({ // Mirroring the login/register response structure for consistency
        _id:          user._id,
        fullname:     user.fullname,
        email:        user.email,
        phone:        user.phone,
        role:         user.role,
        job:          user.job,
        localisation: user.localisation,
        genre:        user.genre,
        birthdate:    user.birthdate,
        profilePicture: user.profilePicture,
        tarifs:       user.tarifs,
        // services:    user.services, // Uncomment if needed by client
        // posts:       user.posts,    // Uncomment if needed by client
        createdAt:    user.createdAt,
        updatedAt:    user.updatedAt,
    });
  } catch (err) {
    console.error("Erreur getUserById:", err);
    if (err.kind === 'ObjectId') {
        return res.status(400).json({ message: "ID utilisateur invalide." });
    }
    res.status(500).json({ message: "Erreur serveur." });
  }
};