// backend/models/post.js
const mongoose = require("mongoose");

const postSchema = new mongoose.Schema(
  {
    artisanId: { // This is the User ID of the artisan
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // References your existing User model
      required: true,
    },
    title: { // <-- NEW: Title for the post
      type: String,
      required: [true, "Le titre du poste est obligatoire."], // Added required message
      trim: true,
    },
    description: {
      type: String,
      required: [true, "La description du poste est obligatoire."],
      trim: true,
    },
    images: [ // Array of image URLs/paths
      {
        type: String,
      },
    ],
    phone: { // <-- NEW: Contact phone for this specific post (optional)
      type: String,
      trim: true,
      default: "", // Default to empty string if not provided
    },
    email: { // <-- NEW: Contact email for this specific post (optional)
      type: String,
      trim: true,
      lowercase: true, // Store emails in lowercase
      default: "",    // Default to empty string if not provided
    },
    likes: [ // Array of User IDs who liked the post
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    // Simple comments structure for now
    comments: [
      {
        userId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true,
        },
        comment: {
          type: String,
          required: true,
        },
        userName: { // Store username for easier display
            type: String,
            required: true,
        },
        userProfilePicture: { // Store profile picture URL for easier display
            type: String,
        },
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  {
    timestamps: true, // Adds createdAt and updatedAt automatically
  }
);

// Index for faster querying of posts by artisanId
postSchema.index({ artisanId: 1, createdAt: -1 });

const Post = mongoose.model("Post", postSchema);

module.exports = Post;