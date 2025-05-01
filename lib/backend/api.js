const express=require('express');
const router  = express.Router();
const annonce = require('../models/annonce_bricole');
router.get('/api/annonces/bricole',async(req,res)=>{
try {
    const data=await annonce.find().sort({ date_creation: -1 });
    res.json(annonce);
} catch (error) {
    console.error('Failed to fetch annonces:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des annonces.' });
}
})

module.exports=router;