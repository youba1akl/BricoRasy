// controllers/userController.js
require('dotenv').config();
const bcrypt    = require("bcryptjs");
const jwt       = require("jsonwebtoken");
const User      = require("../models/user");
const sendEmail = require("../utils/sendemail");

// Temporary in-memory OTP store
const otpStore = {};



/** 
 * @desc    Register a new user
 * @route   POST /api/users/register
 */
exports.registerUser = async (req, res) => {
  const {
    fullname, email, password, phone,
    role, job, localisation, genre,
    birthdate, photo,
  } = req.body;

  try {
    if (await User.findOne({ email })) {
      return res.status(400).json({ message: "Cet email est déjà utilisé." });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      fullname, email, password: hashedPassword,
      phone, role, job, localisation,
      genre, birthdate, photo,
    });

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      'MaPhraseSecreteDeTest123!',
      '1h'
    );

    res.status(201).json({
      token,
      user: {
        _id:         user._id,
        fullname:    user.fullname,
        email:       user.email,
        phone:       user.phone,
        role:        user.role,
        job:         user.job,
        localisation:user.localisation,
        genre:       user.genre,
        birthdate:   user.birthdate,
        photo:       user.photo,
        createdAt:   user.createdAt,
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
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
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      'MaPhraseSecreteDeTest123!',
      { expiresIn: '1h' }
    );

    res.json({
      token,
      user: {
        _id:         user._id,
        fullname:    user.fullname,
        email:       user.email,
        phone:       user.phone,
        role:        user.role,
        job:         user.job,
        localisation:user.localisation,
        genre:       user.genre,
        birthdate:   user.birthdate,
        photo:       user.photo,
        createdAt:   user.createdAt,
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
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
