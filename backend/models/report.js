const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  message: { type: String, required: true },
  annonceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Annonce', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Report', reportSchema);
