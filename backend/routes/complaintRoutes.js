const express = require("express");
const router = express.Router();

const complaintController =
require("../controllers/complaintController");

router.get(
  "/",
  complaintController.getComplaints
);

router.get(
  "/:id",
  complaintController.getComplaintById
);

router.post(
  "/add",
  complaintController.addComplaint
);

router.put(
  "/update/:id",
  complaintController.updateComplaint
);

router.delete(
  "/delete/:id",
  complaintController.deleteComplaint
);

module.exports = router;