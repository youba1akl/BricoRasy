const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    fullname: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    phone: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ["simple", "artisan"],
      default: "simple",
    },
    profilePicture: {
      type: String,
      default: "",
    },
    job: {
      type: String,
      default: "",
    },
    localisation: {
      type: String,
      default: "",
    },
    birthdate: {
      type: Date,
    },
    genre: {
      type: String,
      enum: ["Homme", "Femme"],
      required: true,
    },

    // Champs spécifiques à l'artisan
    services: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Service",
      },
    ],
    posts: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Post",
      },
    ],
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("User", userSchema);

module.exports = User;
