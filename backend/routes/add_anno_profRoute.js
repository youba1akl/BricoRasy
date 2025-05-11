// backend/routes/add_anno_profRoute.js
const express = require('express');
const multer  = require('multer');
const path    = require('path');
const auth    = require("../middleware/auth");
const {upload, create_annonce_prof, getAnnonce_prof, getAnnonceProfById,deactivateAnnonceBricole,getMyAnnonceProf } = require('../controllers/api_annonce_prof_Controller');

const router = express.Router();



// POST   /api/annonce/professionnel (Mounted at /api/annonce in server.js)
router.post('/professionnel', auth, upload, create_annonce_prof);

// GET    /api/annonce/professionnel (all)
router.get('/professionnel', auth, getAnnonce_prof);
router.get('/professionnel/mine', auth, getMyAnnonceProf);
// GET    /api/annonce/professionnel/:id (single)
router.get('/professionnel/:id', getAnnonceProfById);
router.patch("/professionnel/:id", auth, deactivateAnnonceBricole);

module.exports = router;