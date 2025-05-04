const express = require('express');
const multer  = require('multer');
const path    = require('path');
const { create_annonce_prof, getAnnonce_prof } = require('../controllers/api_annonce_prof_Controller');

const router = express.Router();

// Multer setup for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
const upload = multer({ storage });

// POST   /api/annonce/professionnel
router.post('/professionnel', upload.array('photo', 5), create_annonce_prof);

// GET    /api/annonce/professionnel
router.get('/professionnel', getAnnonce_prof);

module.exports = router;
