const express = require("express");

const router = express.Router();

const ticketController =
require("../controllers/ticketController");

// =====================================
// GET ALL TICKETS
// =====================================

router.get(
  "/",
  ticketController.getTickets
);

// =====================================
// GET TICKET BY ID
// =====================================

router.get(
  "/:id",
  ticketController.getTicketById
);

// =====================================
// ADD TICKET
// =====================================

router.post(
  "/add",
  ticketController.addTicket
);

// =====================================
// UPDATE TICKET
// =====================================

router.put(
  "/update/:id",
  ticketController.updateTicket
);

// =====================================
// DELETE TICKET
// =====================================

router.delete(
  "/delete/:id",
  ticketController.deleteTicket
);

module.exports = router;