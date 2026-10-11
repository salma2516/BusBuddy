const express = require("express");
const router = express.Router();

const {
  register,
  login,
} = require("../controllers/authController");

const {
  verifyToken,
  authorizeRoles,
} = require("../middleware/authMiddleware");

// ======================
// AUTH ROUTES
// ======================

// Register
router.post("/register", register);

// Login
router.post("/login", login);

// ======================
// PROTECTED ROUTES
// ======================

// Admin Dashboard Route
router.get(
  "/admin-dashboard",
  verifyToken,
  authorizeRoles("ADMIN"),
  (req, res) => {
    res.json({
      success: true,
      message: "Welcome Admin",
    });
  }
);

// Driver Route
router.get(
  "/driver-dashboard",
  verifyToken,
  authorizeRoles("DRIVER"),
  (req, res) => {
    res.json({
      success: true,
      message: "Welcome Driver",
    });
  }
);

// Conductor Route
router.get(
  "/conductor-dashboard",
  verifyToken,
  authorizeRoles("CONDUCTOR"),
  (req, res) => {
    res.json({
      success: true,
      message: "Welcome Conductor",
    });
  }
);

// Passenger Route
router.get(
  "/passenger-dashboard",
  verifyToken,
  authorizeRoles("PASSENGER"),
  (req, res) => {
    res.json({
      success: true,
      message: "Welcome Passenger",
    });
  }
);

module.exports = router;