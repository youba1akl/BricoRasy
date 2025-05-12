const mongoose = require("mongoose");

const ratingSchema = new mongoose.Schema(
{
userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
},
artisanId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
},
stars: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
},
},
{
timestamps: true,
}
);

const Rating = mongoose.model("Rating", ratingSchema);

module.exports = Rating;
