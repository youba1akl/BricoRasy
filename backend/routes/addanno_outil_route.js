const express = require('express');
const multer  = require('multer');
const path    = require('path');
const router = express.Router();
const outil = require('../controllers/api_outil');


const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename:    (req, file, cb) => cb(null, `${Date.now()}${path.extname(file.originalname)}`)
});
const upload = multer({ storage: storage });

router.post(
  '/outil',
  upload.array('photo', 5),
  outil.createAnnonceOutil
);

router.get('/outil',outil.getOutil);
module.exports = router;