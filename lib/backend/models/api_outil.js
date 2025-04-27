const express = require('express');
const multer  = require('multer');
const path    = require('path');

const router = express.Router(); 
const annonce_outil=require('./Schemas/annonce_outil');
const outil_model = require('./Schemas/annonce_outil');

const storage=multer.diskStorage({
    destination:(req,file,cb)=>(null,'uploads/'),
    filename:(req,file, cb)=>{
        const ext=path.extname(file.originalname);//extension
        cb(null,`${Date.now()}${ext}`);
    }
});

const upload=multer({storage});

router.post('/api/annonces/outil',upload.array('photo',5),
    async(req,res)=>{
        try {
            const filenames=req.files.map(f=>f.filename);
            const annonce=new outil_model({
                titre:req.body.titre,
                localisation:req.body.localisation,
                description:req.body.description,
                prix:           req.body.prix,
                type_annonce:   req.body.type_annonce,
                date_creation:  new Date(req.body.date_creation),
                
                photo:          filenames,  
                dure_location:req.body.dure_location,

            });
            const saved=await annonce.save();
            res.status(201).json(saved);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    });

    module.exports=router;