// backend/controllers/api_annonce_prof_Controller.js
const Annonce = require('../models/annonce_bricole_prof'); // Ensure this path is correct and Annonce is your Mongoose model for 'annonce_professionnel'
const mongoose = require('mongoose');

// Helper to construct image URLs (ensure API_BASE_URL is set in your .env)
const getFullImageUrl = (filename) => {
    if (!filename) return null;
    const apiBaseUrl = process.env.API_BASE_URL || 'http://127.0.0.1:5000'; // Default if not in .env
    // Check if filename is already a full URL
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
        return filename;
    }
    return `${apiBaseUrl}/uploads/${filename}`;
};

// POST /api/annonce/professionnel
exports.create_annonce_prof = async (req, res) => {
  try {
    const filenames = (req.files || []).map(f => f.filename);

    let typesArray = req.body.type_annonce;
    if (!typesArray) {
      typesArray = [];
    } else if (typeof typesArray === 'string') {
      typesArray = typesArray.split(',').map(s => s.trim()).filter(s => s);
    } else if (!Array.isArray(typesArray)) {
        typesArray = [String(typesArray)];
    }

    const {
      titre,
      description = '',
      prix, // This is req.body.prix
      localisation,
      numtel,
      date_creation,
      date_expiration
    } = req.body;

    const newAnnonce = new Annonce({
      name: titre, // Mapped from 'titre' in request to 'name' in model
      description,
      prix: prix, // Save req.body.prix to the 'prix' field in the model
      localisation,
      numtel,
      date_creation:   new Date(date_creation),
      date_expiration: new Date(date_expiration),
      photo:           filenames,
      types:           typesArray
    });

    const saved = await newAnnonce.save();
    // Assuming your model's toJSON handles price, but not _id to id explicitly
    const savedJson = saved.toJSON();
    res.status(201).json({
        ...savedJson,
        id: saved._id // Explicitly add 'id' field from '_id' for consistency if frontend expects 'id'
    });
  } catch (error) {
    console.error('Error creating annonce_professionnel:', error);
    res.status(400).json({ error: error.message });
  }
};

// GET /api/annonce/professionnel (all)
exports.getAnnonce_prof = async (req, res) => {
  try {
    const annonces = await Annonce.find().sort({ date_creation: -1 });
    const transformedAnnonces = annonces.map(annonce => {
        const annonceJson = annonce.toJSON(); // Applies the model's toJSON transform for price
        return {
            ...annonceJson,
            id: annonce._id, // Ensure 'id' field is populated from '_id'
            photo: annonceJson.photo && annonceJson.photo.length > 0
                   ? annonceJson.photo.map(p => getFullImageUrl(p))
                   : [getFullImageUrl('default_service_image.png')] // Provide a default image path
        };
    });
    res.json(transformedAnnonces);
  } catch (error) {
    console.error('Failed to fetch annonces_professionnel:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des annonces.' });
  }
};

// GET /api/annonce/professionnel/:id (single)
exports.getAnnonceProfById = async (req, res) => {
    try {
        const serviceId = req.params.id;

        if (!mongoose.Types.ObjectId.isValid(serviceId)) {
            return res.status(400).json({ message: 'Invalid service ID format' });
        }

        const service = await Annonce.findById(serviceId);

        if (!service) {
            return res.status(404).json({ message: 'Professional service not found' });
        }

        const serviceJson = service.toJSON(); // Applies model's toJSON for price transformation

        const responseService = {
            ...serviceJson, // Spreads all fields from serviceJson (including _id, name, price, etc.)
            id: service._id, // Explicitly set 'id' field from the original document's _id
                             // This ensures frontend gets 'id', even if toJSON doesn't add it.
            photo: serviceJson.photo && serviceJson.photo.length > 0
                   ? serviceJson.photo.map(p => getFullImageUrl(p))
                   : [getFullImageUrl('default_service_image.png')]
        };

        res.status(200).json(responseService);
    } catch (error) { // This is where an error from the 'try' block would be caught
        console.error('Error fetching professional service by ID:', error); // This would be approx line 91
        res.status(500).json({ message: 'Error fetching professional service details', error: error.message });
    }
};