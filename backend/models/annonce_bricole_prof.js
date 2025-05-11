const mongoose = require('mongoose');

const schemaBricoleProf = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Le nom de l'annonce est requis"]
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
    required: [true, "Le numéro de téléphone est requis"],
    trim: true
  },
  idc: {
    type: String,
    required: [true, "L'adresse email est requise"],
    trim: true
  },
  date_creation: {
    type: Date,
    required: [true, "La date de création est requise"]
  },
  date_expiration: {
    type: Date,
    required: [true, "La date d'expiration est requise"]
  },
  creator: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  visible: {
    type: Boolean,
    default: true
  },
  photo: {
    type: [String],
    default: []
  },
  types: {
    type: [String],
    enum: ['Plombier', 'Maçon', 'Jardinier', 'Électricien', 'Peintre', 'Autre'],
    validate: {
      validator: arr => Array.isArray(arr) && arr.length > 0,
      message: 'Au moins un type/métier doit être sélectionné'
    },
    required: [true, 'Au moins un type/métier doit être sélectionné']
  }
}, {
  timestamps: true
});

schemaBricoleProf.set('toJSON', {
  virtuals: true,
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;

    if (ret.prix && ret.prix.$numberDecimal) {
      ret.prix = parseFloat(ret.prix.$numberDecimal).toString();
    }
    return ret;
  }
});

module.exports = mongoose.model('annonce_professionnel', schemaBricoleProf);
