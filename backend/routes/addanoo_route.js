const express = require("express");
const router  = express.Router();
const auth    = require("../middleware/auth");
const {
  upload,
  createAnnonceBricole,
  getAnnonceBricole,
  deactivateAnnonceBricole
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

router.delete("/bricole/:id", auth, deactivateAnnonceBricole);


module.exports = router;
