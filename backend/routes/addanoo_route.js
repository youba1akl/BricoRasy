const express = require('express');
const multer  = require('multer');
const path    = require('path');
const router  = express.Router();
const createAnnonceBricole= require('../controllers/annonceBricoleController');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}${ext}`);
  }
});
const upload = multer({ storage });

router.post(
  '/api/annonces/bricole',
  upload.array('photo', 5),
  createAnnonceBricole
);

module.exports = router;
