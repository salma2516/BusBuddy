const db = require("../config/db");

// =====================================
// GET ALL CONDUCTORS
// =====================================

exports.getConductors = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM conductors
      ORDER BY id DESC
      `
    );

    res.status(200).json(rows);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch conductors"
    });

  }

};

// =====================================
// GET CONDUCTOR BY ID
// =====================================

exports.getConductorById = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM conductors
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        success: false,
        message: "Conductor not found"
      });

    }

    res.status(200).json(rows[0]);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch conductor"
    });

  }

};

// =====================================
// ADD CONDUCTOR
// =====================================

exports.addConductor = async (req, res) => {

  try {

    const {
      name,
      email,
      phone,
      status
    } = req.body;

    if (
      !name ||
      !email ||
      !phone
    ) {

      return res.status(400).json({
        success: false,
        message: "Name, Email and Phone are required"
      });

    }

    const [result] = await db.query(
      `
      INSERT INTO conductors
      (
        name,
        email,
        phone,
        status
      )
      VALUES (?, ?, ?, ?)
      `,
      [
        name,
        email,
        phone,
        status || "ACTIVE"
      ]
    );

    res.status(201).json({
      success: true,
      message: "Conductor Added Successfully",
      conductorId: result.insertId
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
// UPDATE CONDUCTOR
// =====================================

exports.updateConductor = async (req, res) => {

  try {

    const {
      name,
      email,
      phone,
      status
    } = req.body;

    const [result] = await db.query(
      `
      UPDATE conductors
      SET
      name = ?,
      email = ?,
      phone = ?,
      status = ?
      WHERE id = ?
      `,
      [
        name,
        email,
        phone,
        status,
        req.params.id
      ]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Conductor not found"
      });

    }

    res.status(200).json({
      success: true,
      message: "Conductor Updated Successfully"
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
// DELETE CONDUCTOR
// =====================================

exports.deleteConductor = async (req, res) => {

  try {

    const [result] = await db.query(
      `
      DELETE FROM conductors
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Conductor not found"
      });

    }

    res.status(200).json({
      success: true,
      message: "Conductor Deleted Successfully"
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};
