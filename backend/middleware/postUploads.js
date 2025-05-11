// backend/middleware/postUploads.js
const multer = require('multer');
const path = require('path');
const fs = require('fs'); // To ensure directory exists

const UPLOADS_POSTS_DIR = path.join(__dirname, "../uploads/posts");

// Ensure the uploads/posts directory exists
if (!fs.existsSync(UPLOADS_POSTS_DIR)) {
  fs.mkdirSync(UPLOADS_POSTS_DIR, { recursive: true });
  console.log(`Created directory: ${UPLOADS_POSTS_DIR}`);
}

const postStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_POSTS_DIR);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    // Use a more descriptive fieldname part if you want, or keep it simple
    cb(null, 'post-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const imageFileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Le fichier n\'est pas une image! (jpeg, png, gif)'), false);
  }
};

// Configure multer instance for multiple images from a field named 'images'
const uploadPostImages = multer({
  storage: postStorage,
  fileFilter: imageFileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB per file
    files: 5                     // Max 5 files
  }
}).array('images', 5); // Field name in form-data MUST be 'images', max 5 files

module.exports = uploadPostImages;