// middleware/socketAuth.js
const jwt    = require('jsonwebtoken');
const User   = require('../models/user');

exports.authorizeSocket = async (socket, next) => {
  try {
    const token = socket.handshake.auth.token?.split(' ')[1];
    if (!token) return next(new Error('Authentification requise'));

    const payload = jwt.verify(token, 'MaPhraseSecreteDeTest123!');
    const user    = await User.findById(payload.id);
    if (!user) return next(new Error('Utilisateur introuvable'));

    socket.user = { id: user._id.toString(), email: user.email };
    next();
  } catch (err) {
    next(new Error('Token invalide'));
  }
};
