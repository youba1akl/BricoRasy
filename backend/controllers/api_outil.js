const outilModel = require('../models/annonce_outil');


exports.createAnnonceOutil = async (req, res) => {
  try {
    const filenames = req.files.map(f => f.filename);
    const {
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation,
      dure_location
    } = req.body;

    const newAnnonce = new outilModel({
      titre,
      localisation,
      description,
      prix,
      type_annonce,
      date_creation:  new Date(date_creation),
      photo:          filenames,
      dure_location
    });

    const saved = await newAnnonce.save();
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};


exports.getOutil=async(req,res)=>{
  try {
    const annonce=await outilModel.find().sort({ date_creation: -1 });
    res.json(annonce);
  } catch (error) {
    console.error('Failed to fetch annonces:', error);
    res
      .status(500)
      .json({ error: 'Erreur serveur lors de la récupération des annonces.' });
  }
}