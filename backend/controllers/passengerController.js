const db = require("../config/db");

exports.getPassengers = async (req, res) => {
  try {

    const [rows] = await db.query(`
      SELECT *
      FROM users
      WHERE role='PASSENGER'
    `);

    res.json(rows);

  } catch (error) {

    res.status(500).json(error);

  }
};

exports.addPassenger = async (req, res) => {

  try {

    const {
      name,
      email,
      phone,
      password
    } = req.body;

    await db.query(
      `
      INSERT INTO users
      (name,email,phone,password,role)
      VALUES (?,?,?,?, 'PASSENGER')
      `,
      [name,email,phone,password]
    );

    res.json({
      message: "Passenger Added"
    });

  } catch(error){

    res.status(500).json(error);

  }
};