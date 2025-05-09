const express = require("express");
const router  = express.Router();

const {
  upload,
  createAnnonceBricole,
  getAnnonceBricole
} = require("../controllers/apianno");

router.post(
  "/bricole",
  upload,
  createAnnonceBricole
);

router.get(
  "/bricole",
  getAnnonceBricole
);

module.exports = router;
