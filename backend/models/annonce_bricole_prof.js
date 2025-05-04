const mongoose = require('mongoose');

const schemaBricoleProf = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  price: {
    type: mongoose.Schema.Types.Decimal128,
    required: true
  },
  localisation: {
    type: String,
    required: true
  },
  date_creation: {
    type: Date,
    required: true
  },
  date_expiration: {
    type: Date,
    required: true
  },
  photo: {
    type: [String],
    default: []
  },
  types: {
    type: [String],
    enum: ['Plombier', 'Maçon', 'Jardinier', 'Autre'],
    validate: {
      validator: arr => Array.isArray(arr) && arr.length > 0,
      message: 'Au moins un type doit être sélectionné'
    }
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('annonce_professionnel', schemaBricoleProf);
