const express=require('express');
const router=express.Router();

const annonce_prof_schema=require('../models/annonce_bricole_prof');

exports.create_annonce_prof=async (req,res)=>{
    try {
        const filenames = req.files.map(f => f.filename);
    const {
      name,
      description,
      price,
      localisation,
      date_creation,
      date_expiration,
      
      type,
     
    } = req.body;


    const newAnnonce=annonce_prof_schema({
        name,
      description,
      price,
      localisation,
      type,
        date_creation:   new Date(date_creation),
        date_expiration:    new Date(date_expiration),
        photo:            filenames
    });


    const saved=await newAnnonce.save();
    res.status(201).json(saved);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}


exports.getAnnonce_prof=async(req,res)=>{
    try {
        const annonce=await annonce_prof_schema.find().sort({ date_creation: -1 });
        res.json(annonces);
    } catch (error) {
        console.error('Failed to fetch annonces:', error);
        res
          .status(500)
          .json({ error: 'Erreur serveur lors de la récupération des annonces.' });
      
    }
}