const express = require("express");

const router = express.Router();

const {
  getDistricts,
} = require("../controllers/districtController");

// =========================
// GET DISTRICTS
// =========================

router.get("/", getDistricts);

module.exports = router;