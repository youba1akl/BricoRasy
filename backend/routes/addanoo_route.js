const express = require("express");
const router  = express.Router();
const auth    = require("../middleware/auth");
const {
  upload,
  createAnnonceBricole,
  getAnnonceBricole,
  deleteAnnonceBricole
} = require("../controllers/apianno");

router.post(
  "/bricole", auth,
  upload,
  
  createAnnonceBricole
);


router.get(
  "/bricole", auth,
  getAnnonceBricole
);

router.delete("/bricole/:id", auth, deleteAnnonceBricole);


module.exports = router;
