const mongoose=require("mongoose");

const annonceSchema = new mongoose.Schema({
    titre: { type: String, required: true },
    date_creation: { type: Date, required: true },        
    date_expiration: { type: Date, required: true },
    description: { type: String },                         
    localisation: { type: String, required: true },
    prix: { type: mongoose.Schema.Types.Decimal128, required: true }, 
    type_annonce: { type: String, required: true },
    photo: { type: String }                                
  });

  const annonce_bricole_model=mongoose.model('annonce_bricole',annonceSchema);
  module.exports = annonce_bricole_model;
