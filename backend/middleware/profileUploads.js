// backend/middleware/profileUploads.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const UPLOADS_PROFILES_DIR = path.join(__dirname, "../uploads/profiles");

if (!fs.existsSync(UPLOADS_PROFILES_DIR)) {
  fs.mkdirSync(UPLOADS_PROFILES_DIR, { recursive: true });
}

const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOADS_PROFILES_DIR),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const imageFileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) cb(null, true);
  else cb(new Error('Seules les images sont autorisées!'), false);
};

// For single profile picture upload
const uploadProfilePicture = multer({
  storage: profileStorage,
  fileFilter: imageFileFilter,
  limits: { fileSize: 2 * 1024 * 1024 } // 2MB limit for profile pic
}).single('profilePictureFile'); // Field name client sends for the file

module.exports = uploadProfilePicture;