const bcrypt = require("bcryptjs");
const User = require("../models/user");
const sendEmail = require("../utils/sendemail");

// Stockage temporaire des OTP
let otpStore = {};

// @desc    Inscrire un nouvel utilisateur
// @route   POST /api/users/register
// @access  Public
const registerUser = async (req, res) => {
  const {
    fullname,
    email,
    password,
    phone,
    role,
    job,
    localisation,
    genre,
    birthdate,
    photo,
  } = req.body;

  try {
    // Vérifier si l'utilisateur existe déjà
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: "Cet email est déjà utilisé." });
    }

    // Hacher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Créer le nouvel utilisateur
    const user = await User.create({
      fullname,
      email,
      password: hashedPassword,
      phone,
      role,
      job,
      localisation,
      genre,
      birthdate,
      photo,
    });

    res.status(201).json({
      _id: user._id,
      fullname: user.fullname,
      email: user.email,
      phone: user.phone,
      role: user.role,
      job: user.job,
      localisation: user.communs,
      genre: user.genre,
      birthdate: user.birthdate,
      photo: user.photo,
      createdAt: user.createdAt,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

// @desc    Connecter un utilisateur
// @route   POST /api/users/login
// @access  Public
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res
        .status(400)
        .json({ message: "Email ou mot de passe incorrect" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res
        .status(400)
        .json({ message: "Email ou mot de passe incorrect" });
    }

    res.json({
      _id: user._id,
      fullname: user.fullname,
      email: user.email,
      phone: user.phone,
      role: user.role,
      job: user.job,
      localisation: user.communs,
      genre: user.genre,
      birthdate: user.birthdate,
      photo: user.photo,
      createdAt: user.createdAt,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

// @desc    Envoyer un code OTP
// @route   POST /api/users/send-otp
// @access  Public
const sendOTP = async (req, res) => {
  const { email } = req.body;

  try {
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    otpStore[email] = otp;

    await sendEmail(
      email,
      "Votre code OTP BricoRasy",
      `Votre code de vérification est : ${otp}`
    );

    res.status(200).json({ message: "OTP envoyé avec succès" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur lors de l'envoi de l'OTP" });
  }
};

// @desc    Vérifier le code OTP
// @route   POST /api/users/verify-otp
// @access  Public
const verifyOTP = (req, res) => {
  const { email, otp } = req.body;

  try {
    if (otpStore[email] && otpStore[email] === otp) {
      delete otpStore[email];
      res.status(200).json({ message: "OTP vérifié avec succès" });
    } else {
      res.status(400).json({ message: "OTP incorrect" });
    }
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ message: "Erreur lors de la vérification de l'OTP" });
  }
};

module.exports = { registerUser, loginUser, sendOTP, verifyOTP };
