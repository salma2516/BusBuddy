const db = require("../config/db");

// =====================================
// GET ALL LIVE LOCATIONS
// =====================================

exports.getLocations = async (req, res) => {

  try {

    const [rows] = await db.query(`
      SELECT
        l.bus_id,
        b.bus_number,
        b.bus_name,
        l.latitude,
        l.longitude,
        l.speed,
        l.updated_at
      FROM live_locations l
      JOIN buses b
      ON l.bus_id = b.id
      ORDER BY l.updated_at DESC
    `);

    res.status(200).json(rows);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};

// =====================================
// UPDATE BUS LOCATION
// =====================================

exports.updateLocation = async (req, res) => {

  try {

    const {
      bus_id,
      latitude,
      longitude,
      speed
    } = req.body;

    if (
      !bus_id ||
      latitude === undefined ||
      longitude === undefined
    ) {

      return res.status(400).json({
        success: false,
        message:
          "bus_id, latitude and longitude are required"
      });

    }

    await db.query(
      `
      INSERT INTO live_locations
      (
        bus_id,
        latitude,
        longitude,
        speed
      )
      VALUES (?, ?, ?, ?)

      ON DUPLICATE KEY UPDATE

      latitude = VALUES(latitude),
      longitude = VALUES(longitude),
      speed = VALUES(speed),
      updated_at = CURRENT_TIMESTAMP
      `,
      [
        bus_id,
        latitude,
        longitude,
        speed || 0
      ]
    );

    res.status(200).json({
      success: true,
      message: "Location Updated Successfully"
    });

  } catch (error) {

    console.log("LOCATION ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message
    });

  }

};
