const db = require("../config/db");

// =========================
// GET ALL DISTRICTS
// =========================

exports.getDistricts = async (req, res) => {

  try {

    const [districts] = await db.query(
      "SELECT * FROM districts ORDER BY district_name ASC"
    );

    res.status(200).json({
      success: true,
      data: districts,
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};