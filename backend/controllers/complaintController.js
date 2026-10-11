const db = require("../config/db");

// ==========================================
// GET ALL COMPLAINTS
// ==========================================

exports.getComplaints = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM complaints
      ORDER BY id DESC
      `
    );

    res.status(200).json(rows);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch complaints"
    });

  }

};

// ==========================================
// GET COMPLAINT BY ID
// ==========================================

exports.getComplaintById = async (req, res) => {

  try {

    const [rows] = await db.query(
      `
      SELECT *
      FROM complaints
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        success: false,
        message: "Complaint not found"
      });

    }

    res.status(200).json(rows[0]);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch complaint"
    });

  }

};

// ==========================================
// ADD COMPLAINT
// ==========================================

exports.addComplaint = async (req, res) => {

  try {

    const {
      user_id,
      complaint_text,
      status
    } = req.body;

    if (
      !user_id ||
      !complaint_text
    ) {

      return res.status(400).json({
        success: false,
        message: "User ID and Complaint are required"
      });

    }

    const [result] = await db.query(
      `
      INSERT INTO complaints
      (
        user_id,
        complaint_text,
        status
      )
      VALUES (?, ?, ?)
      `,
      [
        user_id,
        complaint_text,
        status || "OPEN"
      ]
    );

    res.status(201).json({

      success: true,

      message: "Complaint Added Successfully",

      complaintId: result.insertId

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
// UPDATE COMPLAINT
// ==========================================

exports.updateComplaint = async (req, res) => {

  try {

    const {
      user_id,
      complaint_text,
      status
    } = req.body;

    const [result] = await db.query(
      `
      UPDATE complaints
      SET
      user_id = ?,
      complaint_text = ?,
      status = ?
      WHERE id = ?
      `,
      [
        user_id,
        complaint_text,
        status,
        req.params.id
      ]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Complaint not found"
      });

    }

    res.status(200).json({

      success: true,

      message: "Complaint Updated Successfully"

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
// DELETE COMPLAINT
// ==========================================

exports.deleteComplaint = async (req, res) => {

  try {

    const [result] = await db.query(
      `
      DELETE FROM complaints
      WHERE id = ?
      `,
      [req.params.id]
    );

    if (result.affectedRows === 0) {

      return res.status(404).json({
        success: false,
        message: "Complaint not found"
      });

    }

    res.status(200).json({

      success: true,

      message: "Complaint Deleted Successfully"

    });

  } catch (error) {

    console.error(error);

    res.status(500).json({

      success: false,

      message: error.message

    });

  }

};
