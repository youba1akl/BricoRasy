const Annonce = require('../models/annonce_bricole_prof');
const mongoose = require('mongoose');
const path = require("path");
const multer = require("multer");

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

// POST /api/annonce/professionnel
exports.create_annonce_prof = async (req, res) => {
  try {
    const files     = req.files || [];
    const filenames = files.map(f => f.filename);

    // **Now pulling both numtel _and_ mail from body**
    let {
      titre,
      description = '',
      prix,
      localisation,
      numtel,
     idc,
      date_creation,
      date_expiration,
      type_annonce
    } = req.body;

    // Normalize `type_annonce` into array
    if (!type_annonce) {
      type_annonce = [];
    } else if (typeof type_annonce === 'string') {
      type_annonce = type_annonce.split(',')
                                   .map(s => s.trim())
                                   .filter(s => s);
    }

    // Server-side guard: fail if any required field is missing
    if (
      !titre ||
      !localisation ||
      !prix ||
      !Array.isArray(type_annonce) ||
      type_annonce.length === 0 ||
      !date_expiration ||
      !numtel ||
      !idc
    ) {
      return res.status(400).json({
        error:
          "Champs manquants : titre, localisation, type_annonce, prix, date_expiration, numtel et mail sont obligatoires."
      });
    }

    const newAnnonce = new Annonce({
      name:            titre,
      description,
      creator: req.user._id,
      prix,
      localisation,
      numtel,         // ← your phone field
      idc,           // ← your email field
      date_creation:   new Date(date_creation),
      date_expiration: new Date(date_expiration),
      photo:           filenames,
      types:           type_annonce
    });

    const saved = await newAnnonce.save();
    const savedJson = saved.toJSON();
    res.status(201).json({
      ...savedJson,
      id: saved._id
    });
  } catch (error) {
    console.error('Error creating annonce_professionnel:', error);
    res.status(400).json({ error: error.message });
  }
};
// GET all
exports.getAnnonce_prof = async (req, res) => {
  try {
    const annonces = await Annonce.find({ visible: true }).sort({ date_creation: -1 });
    const transformed = annonces.map(a => {
      const j = a.toJSON();
      return { ...j, id: a._id };
    });
    res.json(transformed);
  } catch (error) {
    console.error('Failed to fetch annonces_professionnel:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des annonces.' });
  }
};

// GET by id
exports.getAnnonceProfById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    const svc = await Annonce.findById(id);
    if (!svc) return res.status(404).json({ message: 'Annonce non trouvée' });
    const j = svc.toJSON();
    res.json({ ...j, id: svc._id });
  } catch (error) {
    console.error('Error fetching professional service by ID:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};



exports.deactivateAnnonceBricole = async (req, res) => {
  const annonce = await Annonce.findById(req.params.id);
  if (!annonce) return res.status(404).json({ error: "Non trouvée" });
  if (annonce.creator.toString() !== req.user._id.toString()) {
    return res.status(403).json({ error: "Accès refusé" });
  }
  annonce.visible = false;
  await annonce.save();
  res.json({ message: "Annonce désactivée" });
};



exports.getMyAnnonceProf = async (req, res) => {
  try {
    const userId = req.user._id;
    const annonces = await Annonce
      .find({ creator: userId })
      .sort({ date_creation: -1 });
    res.json(annonces);
  } catch (err) {
    console.error('Erreur récupération mes annonces pro :', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};