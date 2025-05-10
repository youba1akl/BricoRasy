const express = require('express');
const multer  = require('multer');
const path    = require('path');
const router = express.Router();
const {
  upload,
  createAnnonceOutil,
  getOutil
} = require('../controllers/api_outil');




router.post(
  '/outil',
  upload,
  createAnnonceOutil
);

router.get('/outil',getOutil);
module.exports = router;