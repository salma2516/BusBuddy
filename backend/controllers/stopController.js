const db = require("../config/db");

// =========================
// GET STOPS BY DISTRICT
// =========================

exports.getStopsByDistrict = async (req, res) => {

  try {

    const { districtId } = req.params;

    const [stops] = await db.query(

      `
      SELECT DISTINCT stop_name
      FROM stops
      WHERE district_id = ?
      ORDER BY stop_name ASC
      `,
      [districtId]
    );

    res.status(200).json({

      success: true,
      data: stops,
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({

      success: false,
      message: "Server Error",
    });
  }
};