const db = require("../config/db");

// =====================================
// GET ALL DRIVERS
// =====================================

exports.getDrivers = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM users
      WHERE role = 'DRIVER'
      ORDER BY id DESC
      `
    );

    res.status(200).json(rows);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch drivers"
    });

  }

};

// =====================================
// GET DRIVER BY ID
// =====================================

exports.getDriverById = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM users
      WHERE id = ?
      AND role = 'DRIVER'
      `,
      [req.params.id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        success: false,
        message: "Driver not found"
      });

    }

    res.status(200).json(rows[0]);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch driver"
    });

  }

};

// =====================================
// ADD DRIVER
// =====================================

exports.addDriver = async (req, res) => {

  try {

    const {
      name,
      email,
      phone,
      password
    } = req.body;

    if (
      !name ||
      !email ||
      !phone ||
      !password
    ) {

      return res.status(400).json({
        success: false,
        message: "All fields are required"
      });

    }

    const [result] = await db.query(
      `
      INSERT INTO users
      (
        name,
        email,
        phone,
        password,
        role
      )
      VALUES
      (
        ?, ?, ?, ?, 'DRIVER'
      )
      `,
      [
        name,
        email,
        phone,
        password
      ]
    );

    res.status(201).json({
      success: true,
      message: "Driver Added Successfully",
      driverId: result.insertId
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// UPDATE DRIVER
// =====================================

exports.updateDriver = async (req, res) => {

  try {

    const {
      name,
      email,
      phone
    } = req.body;

    await db.query(
      `
      UPDATE users
      SET
      name = ?,
      email = ?,
      phone = ?
      WHERE id = ?
      AND role = 'DRIVER'
      `,
      [
        name,
        email,
        phone,
        req.params.id
      ]
    );

    res.status(200).json({
      success: true,
      message: "Driver Updated Successfully"
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// DELETE DRIVER
// =====================================

exports.deleteDriver = async (req, res) => {

  try {

    await db.query(
      `
      DELETE FROM users
      WHERE id = ?
      AND role = 'DRIVER'
      `,
      [req.params.id]
    );

    res.status(200).json({
      success: true,
      message: "Driver Deleted Successfully"
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};
