const express = require("express");

const router = express.Router();

const db = require("../config/db");

// ========================================
// GET STOPS BY DISTRICT
// ========================================

router.get("/:districtId", async (req, res) => {

  try {

    const districtId = req.params.districtId;

    console.log(
      " Fetching Stops For District:",
      districtId
    );

    // ========================================
    // FETCH STOPS
    // ========================================

    const [rows] = await db.query(

      `
      SELECT *
      FROM stops
      WHERE district_id = ?
      ORDER BY stop_name ASC
      `,

      [districtId]
    );

    // ========================================
    // RESPONSE
    // ========================================

    res.status(200).json({

      success: true,

      totalStops: rows.length,

      stops: rows,
    });

  } catch (error) {

    console.log("❌ STOP FETCH ERROR");

    console.log(error);

    res.status(500).json({

      success: false,

      message: "Server Error",
    });
  }
});

// ========================================
// EXPORT ROUTER
// ========================================

module.exports = router;