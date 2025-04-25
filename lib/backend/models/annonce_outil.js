const mongoose=require("mongoose");

const outilSchema=mongoose.Schema({
    titre: { type: String, required: true },
    date_creation: { type: Date, required: true },        
    date_expiration: { type: Date},
    description: { type: String },                         
    localisation: { type: String, required: true },
    prix: { type: mongoose.Schema.Types.Decimal128, required: true }, 
    type_annonce: { type: String, required: true },
    duree_location:{type:String},
    photo: { type: String }  
});


const outil_model=mongoose.model('annonce_outil',outilSchema);

module.exports=outil_model;