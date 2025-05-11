const Service = require("../models/Service");

// 🔹 Créer un service
exports.createService = async (req, res) => {
  try {
    const { artisanId, title, price } = req.body;

    const newService = new Service({ artisanId, title, price });
    await newService.save();

    res.status(201).json(newService);
  } catch (err) {
    res.status(500).json({ error: "Erreur lors de la création du service." });
  }
};

// 🔹 Obtenir tous les services (optionnellement par artisan)
exports.getServices = async (req, res) => {
  try {
    const { artisanId } = req.query;
    const filter = artisanId ? { artisanId } : {};

    const services = await Service.find(filter).populate("artisanId", "fullname");
    res.json(services);
  } catch (err) {
    res.status(500).json({ error: "Erreur lors de la récupération des services." });
  }
};

// 🔹 Modifier un service
exports.updateService = async (req, res) => {
  try {
    const updated = await Service.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    if (!updated) return res.status(404).json({ error: "Service non trouvé." });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: "Erreur lors de la mise à jour." });
  }
};

// 🔹 Supprimer un service
exports.deleteService = async (req, res) => {
  try {
    const deleted = await Service.findByIdAndDelete(req.params.id);

    if (!deleted) return res.status(404).json({ error: "Service non trouvé." });
    res.json({ message: "Service supprimé avec succès." });
  } catch (err) {
    res.status(500).json({ error: "Erreur lors de la suppression." });
  }
};
