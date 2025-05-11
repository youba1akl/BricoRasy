const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  annonceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Annonce', // or your annonce model
    required: true
  },
  from: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  to: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true,
    trim: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Message', messageSchema);
