const express = require("express");
const router = express.Router();

const passengerController =
require("../controllers/passengerController");

router.get(
"/",
passengerController.getPassengers
);

router.post(
"/add",
passengerController.addPassenger
);

module.exports = router;