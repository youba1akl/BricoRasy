const mongoose=require('mongoose');

const shemaBricole_prof=new mongoose.Schema({
    name:{type:String,required:true},
    description:{type:String},
    price:{ type: mongoose.Schema.Types.Decimal128, required: true }, 
    localisation:{type:String,required:true},
    date_creation: { type: Date, required: true },
    date_expiration: { type: Date, required: true },
    photo:  { type: [String], default: [] },
    type: [String],           
    enum: ['Plombier', 'Maçon', 'Jardinier', 'Autre'],
    validate: [(arr) => arr.length > 0, 'Au moin un seul devara etre selectionne']
});

const annonce_bricole_prof_model=mongoose.model('annonce_professionnel',shemaBricole_prof);
module.exports=annonce_bricole_prof_model;