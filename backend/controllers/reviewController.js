const Review = require('../models/review');
const mongoose = require('mongoose');

/**
 * POST /api/reviews/artisan/:artisanId
 * Crée un commentaire pour un artisan
 */
exports.createReview = async (req, res) => {
  try {
    const { artisanId } = req.params;
    const { comment } = req.body;
    const reviewer = req.user._id;

    if (!mongoose.Types.ObjectId.isValid(artisanId)) {
      return res.status(400).json({ message: 'ID artisan invalide' });
    }
    if (!comment || comment.trim() === '') {
      return res.status(400).json({ message: 'Le commentaire ne peut pas être vide' });
    }

    // Éventuelle règle : un seul commentaire par user par annonce
    const existing = await Review.findOne({ artisan: artisanId, reviewer });
    if (existing) {
      return res.status(400).json({ message: 'Vous avez déjà commenté cet artisan' });
    }

    const review = await Review.create({
      artisan: artisanId,
      reviewer,
      comment
    });

    res.status(201).json(review);
  } catch (err) {
    console.error('createReview:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

/**
 * GET /api/reviews/artisan/:artisanId
 * Récupère tous les commentaires pour un artisan
 */
exports.getReviewsByArtisan = async (req, res) => {
  try {
    const { artisanId } = req.params;
    if (!mongoose.Types.ObjectId.isValid(artisanId)) {
      return res.status(400).json({ message: 'ID artisan invalide' });
    }

    const reviews = await Review.find({ artisan: artisanId })
      .populate('reviewer', 'fullname profilePicture')
      .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (err) {
    console.error('getReviewsByArtisan:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
