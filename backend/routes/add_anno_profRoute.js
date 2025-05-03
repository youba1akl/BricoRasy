const express = require('express');
const multer  = require('multer');
const path    = require('path');

const router  = express.Router();

const Annonce = require('../controllers/api_annonce_prof_Controller');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
const upload = multer({ storage });

router.post('/professionnel',upload.array('photo', 5),Annonce.create_annonce_prof);
router.get('/professionnel',Annonce.getAnnonce_prof);