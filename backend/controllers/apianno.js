const path    = require("path");
const multer  = require("multer");
const Annonce = require("../models/annonce_bricole");

const storage = multer.diskStorage({
  destination: (req, file, cb) =>
    cb(null, path.join(__dirname,"../uploads")),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
exports.upload = multer({ storage }).array("photo", 5);

exports.createAnnonceBricole = async (req, res) => {
  try {
    const filenames = (req.files || []).map(f => f.filename);

    // ← pull phone + mail from body
    const {
      titre,
      localisation,
      description = "",
      prix,
      type_annonce,
      date_creation,
      date_expiration,
      phone,      // NEW
      idc        // NEW
    } = req.body;

    // validation now includes phone + mail
    if (!titre ||
        !localisation ||
        !prix ||
        !type_annonce ||
        !date_expiration ||
        !phone ||    // NEW
        !idc) {     // NEW
      return res.status(400).json({ error: "Champs manquants" });
    }

    const annonce = new Annonce({
      titre,
      localisation,
      description,
      prix,
      creator: req.user._id,
      type_annonce,
      phone,       // NEW
      idc,        // NEW
      date_creation:   new Date(date_creation),
      date_expiration: new Date(date_expiration),
      photo:           filenames,
    });
console.log(req.body); // ← ajoute ça temporairement
  console.log(req.files);
    const saved = await annonce.save();
    console.log(req.body); // ← ajoute ça temporairement
  console.log(req.files);
    res.status(201).json(saved);

  } catch (err) {
    console.error("Erreur création annonce :", err);
    res.status(500).json({ error: err.message });
  }
};

exports.getAnnonceBricole = async (req, res) => {
  try {
    const all = await Annonce
      .find({ visible: true })
      .sort({ date_creation: -1 });
    res.json(all);
  } catch (err) {
    console.error("Erreur lecture annonces :", err);
    res.status(500).json({ error: "Erreur serveur" });
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

exports.getMyAnnonceBricole = async (req, res) => {
  try {
    const userId = req.user._id;
    const annonces = await Annonce
      .find({ creator: userId })
      .sort({ date_creation: -1 });
    res.json(annonces);
  } catch (err) {
    console.error('Erreur récupération mes annonces bricole :', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};