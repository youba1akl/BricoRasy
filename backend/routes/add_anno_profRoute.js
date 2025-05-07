// backend/routes/add_anno_profRoute.js
const express = require('express');
const multer  = require('multer');
const path    = require('path');
const { create_annonce_prof, getAnnonce_prof, getAnnonceProfById } = require('../controllers/api_annonce_prof_Controller');

const router = express.Router();

// Multer setup for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure the uploads directory exists or create it
    // const fs = require('fs');
    // const dir = 'uploads/';
    // if (!fs.existsSync(dir)){
    //     fs.mkdirSync(dir, { recursive: true });
    // }
    cb(null, 'uploads/');
  },
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
const upload = multer({ storage });

// POST   /api/annonce/professionnel (Mounted at /api/annonce in server.js)
router.post('/professionnel', upload.array('photo', 5), create_annonce_prof);

// GET    /api/annonce/professionnel (all)
router.get('/professionnel', getAnnonce_prof);

// GET    /api/annonce/professionnel/:id (single)
router.get('/professionnel/:id', getAnnonceProfById);

module.exports = router;