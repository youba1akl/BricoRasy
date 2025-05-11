const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const {
  createReview,
  getReviewsByArtisan
} = require('../controllers/reviewController');

// Créer un commentaire (authentifié)
router.post('/artisan/:artisanId', auth, createReview);

// Lister les commentaires pour un artisan
router.get('/artisan/:artisanId', getReviewsByArtisan);

module.exports = router;
