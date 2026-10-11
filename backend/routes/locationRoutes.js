const express = require("express");

const router = express.Router();

const locationController =
require("../controllers/locationController");

// =========================
// PUBLIC ROUTES
// =========================

router.get(
  "/",
  locationController.getLocations
);

router.post(
  "/update",
  locationController.updateLocation
);

module.exports = router;