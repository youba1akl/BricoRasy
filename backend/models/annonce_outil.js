const mongoose=require("mongoose");

const outilSchema=mongoose.Schema({
    titre: { type: String, required: true },
    date_creation: { type: Date, required: true },        
    
    description: { type: String },                         
    localisation: { type: String, required: true },
    prix: { type: mongoose.Schema.Types.Decimal128, required: true }, 
    type_annonce: { type: String, required: true },
    duree_location:{type:String},
    photo: {
        type: [String],
        default: [],
      },
      creator: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
      phone: {
    type: String,
    required: true,
    trim: true,
  },
  visible: {
    type: Boolean,
    default: true
  },
  idc: {
    type: String,
    required: true,
    trim: true,
  },},
  {
  timestamps: true

});


const outil_model=mongoose.model('annonce_outil',outilSchema);

module.exports=outil_model;