const Report = require('../models/report');

exports.createReport = async (req, res) => {
  try {
    const { message, annonceId, userId } = req.body;

    const report = new Report({ message, annonceId, userId });
    await report.save();

    res.status(201).json({ message: "Signalement envoyé" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
