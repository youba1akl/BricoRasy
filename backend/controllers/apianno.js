const path = require("path");
const AnnonceModel = require("../models/annonce_bricole");  // <-- rename to avoid collision

// Multer setup
const multer  = require("multer");
const storage = multer.diskStorage({
  destination: (req, file, cb) =>
    cb(null, path.join(__dirname, "../uploads")),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
// export `upload` as a single middleware instead of `.array()` inline
exports.upload = multer({ storage }).array("photo", 5);

/**
 * @desc    Create a new bricole annonce
 * @route   POST /api/annonce/bricole
 */
exports.createAnnonceBricole = async (req, res) => {
  try {
    const files = req.files || [];
    const filenames = files.map(f => f.filename);

    const {
      titre,
      localisation,
      description = "",
      prix,
      type_annonce,
      date_creation,
      date_expiration,
    } = req.body;

    // Basic server-side validation:
    if (!titre || !localisation || !prix || !type_annonce || !date_expiration) {
      return res.status(400).json({ error: "Champs manquants" });
    }

    const annonce = new AnnonceModel({
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation:   new Date(date_creation),
      date_expiration: new Date(date_expiration),
      photo:           filenames,
    });

    const saved = await annonce.save();
    res.status(201).json(saved);

  } catch (err) {
    console.error("Erreur création annonce :", err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * @desc    List all bricole annonces
 * @route   GET /api/annonce/bricole
 */
exports.getAnnonceBricole = async (req, res) => {
  try {
    const all = await AnnonceModel.find()
      .sort({ date_creation: -1 });
    res.json(all);

  } catch (err) {
    console.error("Erreur lecture annonces :", err);
    res.status(500).json({ error: "Erreur serveur lors de récupération" });
  }
};
