const express = require('express');
const multer  = require('multer');
const path    = require('path');

const router=require('router');
const annonce_bricole_model = require('./annonce_bricole');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename:    (req, file, cb) => {
      const ext = path.extname(file.originalname);
      cb(null, `${Date.now()}${ext}`);
    }
  });
  const upload = multer({ storage });

  router.post('/api/annonces/bricole',upload.array('photo',5),
        async(req,res)=>{
            try {
                const filenames=req.files.map(f=>f.filename);

                const annonce=new annonce_bricole_model({
                    titre:req.body.titre,
                    localisation:req.body.localisation,
                    description:req.body.description,
                    prix:           req.body.prix,
                    type_annonce:   req.body.type_annonce,
                    date_creation:  new Date(req.body.date_creation),
                    date_expiration:new Date(req.body.date_expiration),
                    photo:          filenames,    

                });

                const saved=await annonce.save();
                res.status(201).json(saved);
            } catch (error) {
                res.status(400).json({ error: err.message });
            }
        }
);
module.exports = router;
