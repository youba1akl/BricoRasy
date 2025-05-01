
const annonceBricoleModel = require('../models/annonce_bricole');


exports.createAnnonceBricole = async (req, res) => {
  try {
    const filenames = req.files.map(f => f.filename);
    const {
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation,
      date_expiration
    } = req.body;

    const newAnnonce = new annonceBricoleModel({
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation:    new Date(date_creation),
      date_expiration:  new Date(date_expiration),
      photo:            filenames
    });

    const saved = await newAnnonce.save();
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};