// middleware/auth.js
const jwt = require('jsonwebtoken');
const User = require('../models/user'); // Ensure path to User model is correct

const JWT_SECRET = process.env.JWT_SECRET || 'MaPhraseSecreteDeTest123!'; // Consistent with controller

module.exports = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      // Changed error message to be more standard for unauthorized
      return res.status(401).json({ message: 'Accès non autorisé. Token manquant.' });
    }

    const decoded = jwt.verify(token, JWT_SECRET); // Use the same secret
    const user = await User.findById(decoded.id).select('-password'); // Exclude password

    if (!user) {
      // If token is valid but user doesn't exist (e.g., deleted user)
      return res.status(401).json({ message: 'Accès non autorisé. Utilisateur non trouvé.' });
    }

    req.user = user; // Attach the full user object (without password) to req.user
    req.token = token; // Optional: make token available if needed by subsequent handlers
    next();
  } catch (error) {
    // Handle different JWT errors more specifically if needed
    if (error.name === 'JsonWebTokenError') {
        return res.status(401).json({ message: 'Accès non autorisé. Token invalide.' });
    }
    if (error.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Accès non autorisé. Token expiré.' });
    }
    console.error("Auth Middleware Error:", error);
    res.status(401).json({ message: 'Accès non autorisé. Authentification échouée.' });
  }
};