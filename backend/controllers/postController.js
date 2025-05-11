// backend/controllers/postController.js
const Post = require("../models/post");
const User = require("../models/user"); // To check if artisanId is valid
const fs = require('fs'); // For deleting files if needed
const path = require('path'); // For constructing file paths

// Helper function to remove uploaded files in case of error during DB save
const removeUploadedFilesOnError = (files) => {
    if (files && files.length > 0) {
        files.forEach(file => {
            fs.unlink(file.path, (err) => { // file.path is where multer saved it
                if (err) console.error("Error deleting uploaded file on error:", file.path, err);
                else console.log("Cleaned up uploaded file on error:", file.path);
            });
        });
    }
};

exports.createPost = async (req, res) => {
  // Log incoming request parts for debugging multipart issues
  // console.log("Create Post Request Headers:", req.headers);
  // console.log("Create Post Request Body:", req.body);
  // console.log("Create Post Request Files:", req.files);

  try {
    const { artisanId, title, description, phone, email } = req.body;
    let imagePaths = [];

    // If multer processed files and they are in req.files
    if (req.files && req.files.length > 0) {
      // Construct full URLs for the images
      // The base URL should be your server's address accessible by the client
      const serverBaseUrl = process.env.API_URL || `${req.protocol}://${req.get('host')}`;
      imagePaths = req.files.map(file => `${serverBaseUrl}/uploads/posts/${file.filename}`);
    } else if (req.body.images && Array.isArray(req.body.images)) {
      // Fallback if frontend sends pre-uploaded URLs (less likely with current setup)
      imagePaths = req.body.images;
    }

    if (!artisanId || !title || !description) {
      removeUploadedFilesOnError(req.files); // Clean up if validation fails early
      return res.status(400).json({ error: "Artisan ID, titre et description sont obligatoires." });
    }

    const artisanUser = await User.findById(artisanId);
    if (!artisanUser || artisanUser.role !== 'artisan') {
      removeUploadedFilesOnError(req.files); // Clean up
      return res.status(400).json({ error: "L'ID d'artisan fourni est invalide ou l'utilisateur n'est pas un artisan." });
    }

    const newPost = new Post({
      artisanId,
      title,
      description,
      images: imagePaths,
      phone: phone || artisanUser.phone,
      email: email || artisanUser.email,
    });

    await newPost.save();

    const populatedPost = await Post.findById(newPost._id)
                                    .populate({
                                        path: "artisanId",
                                        select: "fullname profilePicture job localisation email phone", // Select fields you need
                                    });

    res.status(201).json(populatedPost);
  } catch (err) {
    console.error("Erreur lors de la création du post:", err);
    removeUploadedFilesOnError(req.files); // Clean up files if DB save fails
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }
    res.status(500).json({ error: "Erreur serveur lors de la création du post." });
  }
};

exports.getPosts = async (req, res) => {
  try {
    const { artisanId } = req.query;
    const filter = artisanId ? { artisanId: artisanId } : {};

    const posts = await Post.find(filter)
      .populate({
          path: "artisanId",
          select: "fullname profilePicture job localisation email phone", // Consistent population
      })
      .sort({ createdAt: -1 });

    res.status(200).json(posts);
  } catch (err) {
    console.error("Erreur lors de la récupération des posts:", err);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des posts." });
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id)
                           .populate({
                                path: "artisanId",
                                select: "fullname profilePicture job localisation email phone",
                           })
                           .populate({ // Example for populating comment user details
                                path: "comments.userId",
                                select: "fullname profilePicture"
                           });

    if (!post) {
      return res.status(404).json({ error: "Post non trouvé." });
    }
    res.status(200).json(post);
  } catch (err) {
    console.error("Erreur lors de la récupération du post:", err);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

exports.updatePost = async (req, res) => {
  try {
    const postId = req.params.id;
    // const currentUserId = req.user._id; // Assuming authMiddleware sets req.user

    const postToUpdate = await Post.findById(postId);
    if (!postToUpdate) {
      removeUploadedFilesOnError(req.files); // If files were uploaded for a non-existent post
      return res.status(404).json({ error: "Post non trouvé pour la mise à jour." });
    }

    // Authorization: Only the owner can update
    // if (postToUpdate.artisanId.toString() !== currentUserId.toString()) {
    //   removeUploadedFilesOnError(req.files);
    //   return res.status(403).json({ error: "Non autorisé à modifier ce post." });
    // }

    let imagePaths = postToUpdate.images || []; // Start with existing images

    // If new files are uploaded, they will be in req.files
    if (req.files && req.files.length > 0) {
      const serverBaseUrl = process.env.API_URL || `${req.protocol}://${req.get('host')}`;
      const newUploadedPaths = req.files.map(file => `${serverBaseUrl}/uploads/posts/${file.filename}`);

      // Logic for handling image updates:
      // Option 1: Replace all existing images with new ones (simple)
      //   // TODO: Delete old images from filesystem if they are replaced
      //   postToUpdate.images.forEach(oldImageUrl => {
      //     const oldFilename = path.basename(oldImageUrl);
      //     fs.unlink(path.join(__dirname, "../uploads/posts", oldFilename), err => {
      //       if (err) console.error("Error deleting old image:", oldFilename, err);
      //     });
      //   });
      //   imagePaths = newUploadedPaths;

      // Option 2: Add new images to existing ones (client needs to manage which ones to keep/remove)
      //   This usually involves the client sending a list of existing image URLs to keep.
      //   For now, let's assume if req.files exist, they are the NEW set of images.
      //   It's often simpler for the client to send the full desired list of image URLs in req.body.images
      //   and handle uploads separately if new files are added.
      //   If req.body.images is also sent, that usually implies the client manages the URLs.

      // For this example, let's assume new files simply ADD to or REPLACE,
      // and the client sends the full list of desired image URLs in req.body.images if it wants to manage them.
      // If req.files exist, we use those. Otherwise, we use req.body.images.
      imagePaths = newUploadedPaths; // If files uploaded, they become the new image set.
                                     // Client must re-send old image URLs if they should be kept and no new files uploaded.
    } else if (req.body.images !== undefined) {
      // If no files uploaded, but req.body.images is sent (array of URLs/paths)
      imagePaths = req.body.images;
    }


    // Update fields from req.body
    const { title, description, phone, email } = req.body;
    postToUpdate.title = title !== undefined ? title : postToUpdate.title;
    postToUpdate.description = description !== undefined ? description : postToUpdate.description;
    postToUpdate.images = imagePaths; // Set the new or existing image paths

    // Default to artisan's main contact if post-specific one is cleared
    const artisanUser = await User.findById(postToUpdate.artisanId);
    postToUpdate.phone = phone !== undefined ? (phone || (artisanUser ? artisanUser.phone : "")) : postToUpdate.phone;
    postToUpdate.email = email !== undefined ? (email || (artisanUser ? artisanUser.email : "")) : postToUpdate.email;


    const updatedPost = await postToUpdate.save();
    const populatedPost = await Post.findById(updatedPost._id)
                                      .populate("artisanId", "fullname profilePicture job localisation email phone");


    res.status(200).json(populatedPost);
  } catch (err) {
    console.error("Erreur lors de la mise à jour du post:", err);
    removeUploadedFilesOnError(req.files); // Clean up any uploaded files if update failed
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }
    res.status(500).json({ error: "Erreur serveur lors de la mise à jour." });
  }
};

exports.deletePost = async (req, res) => {
  try {
    const postId = req.params.id;
    // const currentUserId = req.user._id; // Assuming authMiddleware

    const postToDelete = await Post.findById(postId);
    if (!postToDelete) {
      return res.status(404).json({ error: "Post non trouvé pour la suppression." });
    }

    // Authorization
    // if (postToDelete.artisanId.toString() !== currentUserId.toString()) {
    //   return res.status(403).json({ error: "Non autorisé à supprimer ce post." });
    // }

    // Delete images from filesystem if they exist
    if (postToDelete.images && postToDelete.images.length > 0) {
      postToDelete.images.forEach(imageUrl => {
        try {
          const urlParts = imageUrl.split('/');
          const filename = urlParts[urlParts.length -1]; // Get filename from URL
          const filePath = path.join(__dirname, "../uploads/posts", filename);
          if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
            console.log("Deleted image file:", filePath);
          } else {
            console.log("Image file not found for deletion:", filePath);
          }
        } catch (fileErr) {
            console.error("Error deleting image file:", imageUrl, fileErr);
        }
      });
    }

    await Post.findByIdAndDelete(postId);
    res.status(200).json({ message: "Post supprimé avec succès." });
  } catch (err) {
    console.error("Erreur lors de la suppression du post:", err);
    res.status(500).json({ error: "Erreur serveur lors de la suppression." });
  }
};

// --- Likes and Comments (Basic Implementations - Ensure userId comes from authenticated req.user) ---
exports.likeUnlikePost = async (req, res) => {
    try {
        const postId = req.params.id;
        const userId = req.user._id; // <--- Get userId from authenticated user

        if (!userId) return res.status(401).json({ error: "Authentification requise." });

        const post = await Post.findById(postId);
        if (!post) return res.status(404).json({ error: "Post non trouvé." });

        const index = post.likes.indexOf(userId);
        if (index === -1) {
            post.likes.push(userId);
        } else {
            post.likes.splice(index, 1);
        }
        const savedPost = await post.save();
        const populatedPost = await Post.findById(savedPost._id).populate("artisanId", "fullname profilePicture job");

        res.status(200).json(populatedPost);
    } catch (err) {
        console.error("Erreur like/unlike:", err);
        res.status(500).json({ error: "Erreur serveur." });
    }
};

exports.addComment = async (req, res) => {
    try {
        const postId = req.params.id;
        const userId = req.user._id; // <--- Get userId from authenticated user
        const { comment } = req.body;

        if (!userId) return res.status(401).json({ error: "Authentification requise." });
        if (!comment) return res.status(400).json({ error: "Le commentaire ne peut pas être vide." });

        const post = await Post.findById(postId);
        if (!post) return res.status(404).json({ error: "Post non trouvé." });

        const userCommenting = await User.findById(userId).select("fullname profilePicture"); // Get commenter's info
        if (!userCommenting) return res.status(404).json({ error: "Utilisateur du commentaire non trouvé." });

        const newComment = {
            userId,
            comment,
            userName: userCommenting.fullname,
            userProfilePicture: userCommenting.profilePicture || "",
            // createdAt is defaulted by schema
        };
        post.comments.push(newComment);
        await post.save();

        // Return only the newly added comment, populated
        const addedComment = post.comments[post.comments.length - 1];
        // Manually populate userId for the single comment if needed, or repopulate the whole post for consistency
        const populatedComment = {
            ...addedComment.toObject(), // Convert Mongoose subdocument to plain object
            userId: userCommenting // Replace userId ObjectId with populated user object
        };

        res.status(201).json(populatedComment);
    } catch (err) {
        console.error("Erreur ajout commentaire:", err);
        res.status(500).json({ error: "Erreur serveur." });
    }
};