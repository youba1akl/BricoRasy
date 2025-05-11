const Post = require("../models/Post");

// 🔹 Créer un post
exports.createPost = async (req, res) => {
try {
const { artisanId, description, images } = req.body;

const newPost = new Post({ artisanId, description, images });
await newPost.save();

res.status(201).json(newPost);
} catch (err) {
res.status(500).json({ error: "Erreur lors de la création du post." });
}
};

// 🔹 Obtenir tous les posts (optionnellement par artisan)
exports.getPosts = async (req, res) => {
try {
const { artisanId } = req.query;
const filter = artisanId ? { artisanId } : {};

const posts = await Post.find(filter).populate("artisanId", "fullname");
res.json(posts);
} catch (err) {
res
    .status(500)
    .json({ error: "Erreur lors de la récupération des posts." });
}
};

// 🔹 Modifier un post
exports.updatePost = async (req, res) => {
try {
const updated = await Post.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
});

if (!updated) return res.status(404).json({ error: "Post non trouvé." });
res.json(updated);
} catch (err) {
res.status(500).json({ error: "Erreur lors de la mise à jour." });
}
};

// 🔹 Supprimer un post
exports.deletePost = async (req, res) => {
try {
const deleted = await Post.findByIdAndDelete(req.params.id);

if (!deleted) return res.status(404).json({ error: "Post non trouvé." });
res.json({ message: "Post supprimé avec succès." });
} catch (err) {
res.status(500).json({ error: "Erreur lors de la suppression." });
}
};
