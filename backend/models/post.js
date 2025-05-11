const mongoose = require("mongoose");

const postSchema = new mongoose.Schema(
{
artisanId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
},
description: {
    type: String,
    required: true,
},
images: [
    {
    type: String, // URLs des images
    },
],
likes: [
    {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User", // utilisateurs qui ont liké
    },
],
comments: [
    {
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
    },
    comment: {
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
timestamps: true,
}
);

const Post = mongoose.model("Post", postSchema);

module.exports = Post;
