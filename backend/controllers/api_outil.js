const path       = require("path");
const multer     = require("multer");
const outilModel = require("../models/annonce_outil");

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) =>
    cb(null, path.join(__dirname, "../uploads")),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
exports.upload = multer({ storage }).array("photo", 5);

/**
 * @desc    Create a new “outil” annonce
 * @route   POST /api/annonce/outil
 * @access  Public
 */
exports.createAnnonceOutil = async (req, res) => {
  try {
    const files     = req.files || [];
    const filenames = files.map(f => f.filename);

    // Destructure incoming form fields
    const {
      titre,
      localisation,
      description = "",
      prix,
      type_annonce,
      date_creation,
      duree_location,   // matches schema
      phone,
      mail
    } = req.body;

    // Validate required fields
    if (
      !titre ||
      !localisation ||
      !prix ||
      !type_annonce ||
      !date_creation ||
      !duree_location ||
      !phone ||
      !mail
    ) {
      return res
        .status(400)
        .json({ error: "Tous les champs obligatoires doivent être fournis." });
    }

    // Build and save the new document
    const newAnnonce = new outilModel({
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation:  new Date(date_creation),
      duree_location,   // correct field name
      photo:          filenames,
      phone,
      mail,
    });

    const saved = await newAnnonce.save();
    res.status(201).json(saved);
  } catch (error) {
    console.error("Erreur création annonce outil :", error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @desc    List all “outil” annonces
 * @route   GET /api/annonce/outil
 * @access  Public
 */
exports.getOutil = async (req, res) => {
  try {
    const annonces = await outilModel
      .find()
      .sort({ date_creation: -1 });
    res.json(annonces);
  } catch (error) {
    console.error("Failed to fetch annonces outil:", error);
    res
      .status(500)
      .json({ error: "Erreur serveur lors de la récupération des annonces." });
  }
};
