const express = require("express");

const router = express.Router();

const conductorController =
require("../controllers/conductorController");

// =====================================
// GET ALL CONDUCTORS
// =====================================

router.get(
  "/",
  conductorController.getConductors
);

// =====================================
// GET CONDUCTOR BY ID
// =====================================

router.get(
  "/:id",
  conductorController.getConductorById
);

// =====================================
// ADD CONDUCTOR
// =====================================

router.post(
  "/add",
  conductorController.addConductor
);

// =====================================
// UPDATE CONDUCTOR
// =====================================

router.put(
  "/update/:id",
  conductorController.updateConductor
);

// =====================================
// DELETE CONDUCTOR
// =====================================

router.delete(
  "/delete/:id",
  conductorController.deleteConductor
);

module.exports = router;
