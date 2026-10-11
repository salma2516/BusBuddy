const express = require("express");
const router = express.Router();

const busController =
require("../controllers/busController");

router.get("/", busController.getBuses);

router.post(
  "/add",
  busController.addBus
);

router.put(
  "/update/:id",
  busController.updateBus
);

router.delete(
  "/delete/:id",
  busController.deleteBus
);

module.exports = router;