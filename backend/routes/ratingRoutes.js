const express = require("express");
const router = express.Router();
const ratingController = require("../controllers/ratingController");

router.post("/", ratingController.createRating);
router.get("/", ratingController.getRatings);
router.get("/average/:artisanId", ratingController.getAverageRating);

module.exports = router;
