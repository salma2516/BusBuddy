const db = require("../config/db");

// =====================================
// GET ALL TICKETS
// =====================================

exports.getTickets = async (req, res) => {

  try {

    const [rows] = await db.query(`
      SELECT *
      FROM tickets
      ORDER BY id DESC
    `);

    res.status(200).json(rows);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch tickets"
    });

  }

};

// =====================================
// GET TICKET BY ID
// =====================================

exports.getTicketById = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM tickets
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        success: false,
        message: "Ticket not found"
      });

    }

    res.status(200).json(rows[0]);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// ADD TICKET
// =====================================

exports.addTicket = async (req, res) => {

  try {

    const {
      passenger_id,
      bus_id,
      source_stop,
      destination_stop,
      fare,
      payment_status,
      from_stop,
      to_stop,
      seats,
      amount,
      status
    } = req.body;

    if (
      !passenger_id ||
      !bus_id ||
      !source_stop ||
      !destination_stop ||
      !fare
    ) {

      return res.status(400).json({
        success: false,
        message:
          "Passenger ID, Bus ID, Source Stop, Destination Stop and Fare are required"
      });

    }

    const [result] = await db.query(
      `
      INSERT INTO tickets
      (
        passenger_id,
        bus_id,
        source_stop,
        destination_stop,
        fare,
        payment_status,
        from_stop,
        to_stop,
        seats,
        amount,
        status
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        passenger_id,
        bus_id,
        source_stop,
        destination_stop,
        fare,
        payment_status || "PAID",
        from_stop || source_stop,
        to_stop || destination_stop,
        seats || 1,
        amount || fare,
        status || "ACTIVE"
      ]
    );

    res.status(201).json({
      success: true,
      message: "Ticket Added Successfully",
      ticketId: result.insertId
    });

  } catch (error) {

    console.log("ADD TICKET ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// UPDATE TICKET
// =====================================

exports.updateTicket = async (req, res) => {

  try {

    const {
      passenger_id,
      bus_id,
      source_stop,
      destination_stop,
      fare,
      payment_status,
      from_stop,
      to_stop,
      seats,
      amount,
      status
    } = req.body;

    const [result] = await db.query(
      `
      UPDATE tickets
      SET
      passenger_id = ?,
      bus_id = ?,
      source_stop = ?,
      destination_stop = ?,
      fare = ?,
      payment_status = ?,
      from_stop = ?,
      to_stop = ?,
      seats = ?,
      amount = ?,
      status = ?
      WHERE id = ?
      `,
      [
        passenger_id,
        bus_id,
        source_stop,
        destination_stop,
        fare,
        payment_status,
        from_stop,
        to_stop,
        seats,
        amount,
        status,
        req.params.id
      ]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Ticket not found"
      });

    }

    res.status(200).json({
      success: true,
      message: "Ticket Updated Successfully"
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// DELETE TICKET
// =====================================

exports.deleteTicket = async (req, res) => {

  try {

    const [result] = await db.query(
      `
      DELETE FROM tickets
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Ticket not found"
      });

    }

    res.status(200).json({
      success: true,
      message: "Ticket Deleted Successfully"
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};