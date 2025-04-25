const mongoose = require("mongoose");

const dbConnect = async (Database_url) => {
    try {
        await mongoose.connect(Database_url);
        console.log('DB connected');
    } catch (error) {
        console.error('DB connection error:', error);
    }
};

module.exports = dbConnect;
