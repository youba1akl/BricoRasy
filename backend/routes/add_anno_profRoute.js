// backend/routes/add_anno_profRoute.js
const express = require('express');
const multer  = require('multer');
const path    = require('path');
const {upload, create_annonce_prof, getAnnonce_prof, getAnnonceProfById } = require('../controllers/api_annonce_prof_Controller');

const router = express.Router();



// POST   /api/annonce/professionnel (Mounted at /api/annonce in server.js)
router.post('/professionnel', upload, create_annonce_prof);

// GET    /api/annonce/professionnel (all)
router.get('/professionnel', getAnnonce_prof);

// GET    /api/annonce/professionnel/:id (single)
router.get('/professionnel/:id', getAnnonceProfById);

module.exports = router;