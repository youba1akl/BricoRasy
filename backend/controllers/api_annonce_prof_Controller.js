const Annonce = require('../models/annonce_bricole_prof');

// POST /api/annonce/professionnel
exports.create_annonce_prof = async (req, res) => {
  try {
    const filenames = (req.files || []).map(f => f.filename);

    // Normalize `type` field into an array
    let types = req.body.type;
    if (!types) {
      types = [];
    } else if (typeof types === 'string') {
      types = types.split(',').map(s => s.trim()).filter(s => s);
    }

    const {
      name,
      description = '',
      price,
      localisation,
      date_creation,
      date_expiration
    } = req.body;

    const newAnnonce = new Annonce({
      name,
      description,
      price,
      localisation,
      date_creation:   new Date(date_creation),
      date_expiration: new Date(date_expiration),
      photo:           filenames,
      types
    });

    const saved = await newAnnonce.save();
    res.status(201).json(saved);
  } catch (error) {
    console.error('Error creating annonce:', error);
    res.status(400).json({ error: error.message });
  }
};

// GET /api/annonce/professionnel
exports.getAnnonce_prof = async (req, res) => {
  try {
    const annonces = await Annonce.find().sort({ date_creation: -1 });
    res.json(annonces);
  } catch (error) {
    console.error('Failed to fetch annonces:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des annonces.' });
  }
};
