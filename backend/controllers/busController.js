const db = require("../config/db");

// ==========================================
// GET ALL BUSES
// ==========================================

exports.getBuses = async (req, res) => {

  try {

    const [rows] = await db.query(
      "SELECT * FROM buses ORDER BY id DESC"
    );

    res.status(200).json(rows);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch buses"
    });

  }

};

// ==========================================
// GET BUS BY ID
// ==========================================

exports.getBusById = async (req, res) => {

  try {

    const id = req.params.id;

    const [rows] = await db.query(
      "SELECT * FROM buses WHERE id = ?",
      [id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        success: false,
        message: "Bus not found"
      });

    }

    res.status(200).json(rows[0]);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch bus"
    });

  }

};

// ==========================================
// ADD BUS
// ==========================================

exports.addBus = async (req, res) => {

  try {

    const {
      bus_number,
      bus_name,
      capacity,
      status
    } = req.body;

    if (
      !bus_number ||
      !bus_name ||
      !capacity
    ) {

      return res.status(400).json({
        success: false,
        message:
          "Bus Number, Bus Name and Capacity are required"
      });

    }

    const [result] = await db.query(

      `
      INSERT INTO buses
      (
        bus_number,
        bus_name,
        capacity,
        status
      )
      VALUES (?, ?, ?, ?)
      `,

      [
        bus_number,
        bus_name,
        capacity,
        status || "ACTIVE"
      ]

    );

    res.status(201).json({

      success: true,

      message: "Bus Added Successfully",

      busId: result.insertId

    });

  } catch (error) {

    console.error(error);

    res.status(500).json({

      success: false,

      message: error.message

    });

  }

};

// ==========================================
// UPDATE BUS
// ==========================================

exports.updateBus = async (req, res) => {

  try {

    const id = req.params.id;

    const {
      bus_number,
      bus_name,
      capacity,
      status
    } = req.body;

    if (
      !bus_number ||
      !bus_name ||
      !capacity
    ) {

      return res.status(400).json({

        success: false,

        message:
          "Bus Number, Bus Name and Capacity are required"

      });

    }

    const [result] = await db.query(

      `
      UPDATE buses
      SET
        bus_number = ?,
        bus_name = ?,
        capacity = ?,
        status = ?
      WHERE id = ?
      `,

      [
        bus_number,
        bus_name,
        capacity,
        status,
        id
      ]

    );

    if (result.affectedRows === 0) {

      return res.status(404).json({

        success: false,

        message: "Bus not found"

      });

    }

    res.status(200).json({

      success: true,

      message: "Bus Updated Successfully"

    });

  } catch (error) {

    console.error("UPDATE ERROR:", error);

    res.status(500).json({

      success: false,

      message: error.message

    });

  }

};

// ==========================================
// DELETE BUS
// ==========================================

exports.deleteBus = async (req, res) => {

  try {

    const id = req.params.id;

    const [result] = await db.query(
      "DELETE FROM buses WHERE id = ?",
      [id]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({

        success: false,

        message: "Bus not found"

      });

    }

    res.status(200).json({

      success: true,

      message: "Bus Deleted Successfully"

    });

  } catch (error) {

    console.error(error);

    res.status(500).json({

      success: false,

      message: error.message

    });

  }

};