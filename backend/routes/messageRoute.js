const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { createMessage, getConversations, getChat } = require('../controllers/messageController');

router.post('/', auth, createMessage);
router.get('/conversations', auth, getConversations);
router.get('/:annonceId/:peerId', auth, getChat);

module.exports = router;
