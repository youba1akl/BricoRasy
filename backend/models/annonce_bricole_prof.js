// backend/models/annonce_bricole_prof.js (or annonce_professionnel.js)
const mongoose = require('mongoose');

const schemaBricoleProf = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Le nom (titre) de l'annonce est requis"]
  },
  description: {
    type: String,
    default: ''
  },
  prix: {
    type: mongoose.Schema.Types.Decimal128,
    required: [true, "Le prix est requis"]
  },
  localisation: {
    type: String,
    required: [true, "La localisation est requise"]
  },
  numtel: {
    type: String,
    default: ''
  },
  date_creation: {
    type: Date,
    required: [true, "La date de création est requise"]
  },
  date_expiration: {
    type: Date,
    required: [true, "La date d'expiration est requise"]
  },
  photo: {
    type: [String],
    default: []
  },
  types: {
    type: [String],
    enum: ['Plombier', 'Maçon', 'Jardinier', 'Électricien', 'Peintre', 'Autre'], // Note: Corrected 'PlOkayombier'
    validate: {
      validator: function(arr) {
        return Array.isArray(arr) && arr.length > 0;
      },
      message: 'Au moins un type/métier doit être sélectionné'
    },
    required: [true, 'Au moins un type/métier doit être sélectionné']
  }
  // userId: {
  //   type: mongoose.Schema.Types.ObjectId,
  //   ref: 'User', // Good practice to add ref
  //   required: true
  // }
}, {
  timestamps: true
});

schemaBricoleProf.set('toJSON', {
  virtuals: true, // Ensure virtuals like 'id' are included if you define them
  transform: (doc, ret) => {
    // Ensure _id is transformed to id
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v; // Remove version key

    if (ret.prix && ret.prix.$numberDecimal) {
      ret.prix = parseFloat(ret.prix.$numberDecimal).toString();
    } else if (ret.prix) { // If somehow it's already a number (e.g. during creation if not Decimal128)
      ret.prix = parseFloat(ret.prix).toString();
    }
    return ret;
  }
});

module.exports = mongoose.model('annonce_professionnel', schemaBricoleProf);