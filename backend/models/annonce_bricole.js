const mongoose = require("mongoose");

const annonceSchema = new mongoose.Schema({
  titre: {
    type: String,
    required: true,
    trim: true,
  },
  date_creation: {
    type: Date,
    required: true,
  },
  date_expiration: {
    type: Date,
    required: true,
  },
  description: {
    type: String,
    default: "",
  },
  localisation: {
    type: String,
    required: true,
    trim: true,
  },
  prix: {
    type: mongoose.Schema.Types.Decimal128,
    required: true,
  },
  type_annonce: {
    type: String,
    required: true,
  },

  // ← add these two new required fields
  phone: {
    type: String,
    required: true,
    trim: true,
  },
  mail: {
    type: String,
    required: true,
    trim: true,
  },

  photo: {
    type: [String],
    default: [],
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model("AnnonceBricole", annonceSchema);
