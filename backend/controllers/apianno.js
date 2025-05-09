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
      mail        // NEW
    } = req.body;

    // validation now includes phone + mail
    if (!titre ||
        !localisation ||
        !prix ||
        !type_annonce ||
        !date_expiration ||
        !phone ||    // NEW
        !mail) {     // NEW
      return res.status(400).json({ error: "Champs manquants" });
    }

    const annonce = new Annonce({
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      phone,       // NEW
      mail,        // NEW
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

exports.getAnnonceBricole = async (req, res) => {
  try {
    const all = await Annonce
      .find()
      .sort({ date_creation:-1 });
    res.json(all);
  } catch(err) {
    console.error("Erreur lecture annonces :", err);
    res.status(500).json({ error:"Erreur serveur" });
  }
};
