const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { createService, getServices } = require('../controllers/serviceController');

router.get('/', getServices);
router.post('/', auth, createService);

module.exports = router;
