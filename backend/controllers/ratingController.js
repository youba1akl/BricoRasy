const Rating = require("../models/Rating");

// 🔹 Créer un rating (avis d'un utilisateur sur un artisan)
exports.createRating = async (req, res) => {
try {
const { userId, artisanId, stars, comment } = req.body;

const newRating = new Rating({ userId, artisanId, stars, comment });
await newRating.save();

res.status(201).json(newRating);
} catch (err) {
res.status(500).json({ error: "Erreur lors de la création du rating." });
}
};

// 🔹 Obtenir tous les ratings pour un artisan
exports.getRatings = async (req, res) => {
try {
const { artisanId } = req.query;
if (!artisanId)
    return res.status(400).json({ error: "artisanId est requis" });

const ratings = await Rating.find({ artisanId }).populate(
    "userId",
    "fullname"
);
res.json(ratings);
} catch (err) {
res
    .status(500)
    .json({ error: "Erreur lors de la récupération des ratings." });
}
};

// 🔹 Calculer la moyenne des ratings d'un artisan
exports.getAverageRating = async (req, res) => {
try {
const { artisanId } = req.params;
const ratings = await Rating.find({ artisanId });

if (ratings.length === 0)
    return res
    .status(404)
    .json({ error: "Aucun rating trouvé pour cet artisan." });

const average =
    ratings.reduce((sum, rating) => sum + rating.stars, 0) / ratings.length;
res.json({ averageRating: average });
} catch (err) {
res
    .status(500)
    .json({ error: "Erreur lors du calcul de la moyenne des ratings." });
}
};
