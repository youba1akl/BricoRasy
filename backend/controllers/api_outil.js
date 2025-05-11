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
      idc
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
      !idc
    ) {
      return res
        .status(400)
        .json({ error: "Tous les champs obligatoires doivent être fournis." });
    }

    // Build and save the new document
    const newAnnonce = new outilModel({
      titre,
      localisation,
      creator: req.user._id,
      description,
      prix,
      type_annonce,
      date_creation:  new Date(date_creation),
      duree_location,   // correct field name
      photo:          filenames,
      phone,
      idc,
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
    const all = await outilModel
      .find({ visible: true })
      .sort({ date_creation: -1 });
    res.json(all);
  } catch (err) {
    console.error("Erreur lecture annonces :", err);
    res.status(500).json({ error: "Erreur serveur" });
  }
};


exports.deactivateAnnonceOutil = async (req, res) => {
  const annonce = await outilModel.findById(req.params.id);
  if (!annonce) return res.status(404).json({ error: "Non trouvée" });
  if (annonce.creator.toString() !== req.user._id.toString()) {
    return res.status(403).json({ error: "Accès refusé" });
  }
  annonce.visible = false;
  await annonce.save();
  res.json({ message: "Annonce désactivée" });
};

exports.getMyAnnonceOutil = async (req, res) => {
  try {
    const userId = req.user._id;
    const annonces = await outilModel
      .find({ creator: userId })
      .sort({ date_creation: -1 });
    res.json(annonces);
  } catch (err) {
    console.error('Erreur récupération mes annonces outil :', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};