const mongoose = require("mongoose");

const tarifItemSchema = new mongoose.Schema({
  serviceName: {
    type: String,
    required: [true, "Le nom du service est obligatoire pour un tarif."],
    trim: true,
  },
  price: { // Can be a range like "1000 - 2000 DA" or "Contactez-moi"
    type: String,
    required: [true, "Le prix/tarif est obligatoire."],
    trim: true,
  }
  // Mongoose adds _id to subdocuments by default, which is fine.
});

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
  tarifs: [tarifItemSchema],

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
