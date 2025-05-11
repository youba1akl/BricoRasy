// backend/routes/postRoute.js
const express = require("express");
const router = express.Router();
const postController = require("../controllers/postController");
const uploadPostImages = require('../middleware/postUploads'); // Your multer middleware for post images
const authMiddleware = require('../middleware/auth'); // Assuming you have this for protected routes

// Create a new post - Requires auth, handles image uploads
router.post("/", authMiddleware, uploadPostImages, postController.createPost);

// Get all posts (public or filtered by artisanId) - Could be public or require auth
router.get("/", postController.getPosts);

// Get a specific post by ID - Could be public or require auth
router.get("/:id", postController.getPostById);

// Update a post - Requires auth, handles image uploads if new images are sent
router.put("/:id", authMiddleware, uploadPostImages, postController.updatePost);

// Delete a post - Requires auth
router.delete("/:id", authMiddleware, postController.deletePost);

// Like/Unlike a post - Requires auth
router.patch("/:id/like", authMiddleware, postController.likeUnlikePost); // Use PATCH

// Add a comment to a post - Requires auth
router.post("/:id/comment", authMiddleware, postController.addComment);

module.exports = router;