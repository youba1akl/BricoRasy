const express = require('express');
const multer  = require('multer');
const path    = require('path');
const auth    = require("../middleware/auth");
const router = express.Router();
const {
  upload,
  createAnnonceOutil,
  getOutil,
  deleteAnnonceOutil
} = require('../controllers/api_outil');




router.post(
  '/outil', auth,
  upload,
  createAnnonceOutil
);

router.get('/outil', auth,getOutil);
router.delete("/bricole/:id", auth, deleteAnnonceOutil);
module.exports = router;