const express = require('express');
const router  = express.Router();

// Destructure exactly what your controller exports:
const {
  upload,
  createAnnonceBricole,
  getAnnonceBricole
} = require('../controllers/apianno');

// POST /api/annonce/bricole
//  • `upload` is the multer middleware array( 'photo', 5 )
//  • `createAnnonceBricole` is your handler
router.post(
  '/bricole',
  upload,
  createAnnonceBricole
);

// GET /api/annonce/bricole
router.get(
  '/bricole',
  getAnnonceBricole
);

module.exports = router;
