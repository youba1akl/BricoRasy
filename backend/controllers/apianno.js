
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

exports.getAnnonceBricole = async (req,res) =>{
  try {
    const annonces = await annonceBricoleModel.find().sort({ date_creation: -1 });
    res.json(annonces);
  } catch (error) {
    console.error('Failed to fetch annonces:', error);
    res
      .status(500)
      .json({ error: 'Erreur serveur lors de la récupération des annonces.' });
  }
}