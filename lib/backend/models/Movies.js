const mongoose = require("mongoose");

const movieSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    ratings: { type: Number, required: true, min: 1, max: 5 },
    money: {
        type: mongoose.Decimal128,
        required: true,
        validate: {
            validator: v => parseFloat(v.toString()) > 10,
            message: props => `${props.value} is not greater than 10!`
        }
    },
    genre: [{ type: String }],
    isActive: { type: Boolean },
    comments: [
        {
            value: { type: String },
            published: { type: Date, default: Date.now }
        }
    ]
});

const movieModel = mongoose.model('movie', movieSchema);
const createDoc=async () => {
    try {
      const m1=  new movieModel({
            name:"snowfall",
            genre:['action'],
            money:1234,
            ratings:3,
            isActive:true,
            comments:[{value:'goof'}]
        })
        const res=await m1.save();
        console.log(res);
    } catch (error) {
        console.error();
    }
}
module.exports = {
    movieModel,
    createDoc
};