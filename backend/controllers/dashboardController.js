const db = require("../config/db");

exports.getDashboard = async (req, res) => {

try {

const [[buses]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM buses
`);

const [[drivers]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM users
  WHERE role = 'DRIVER'
`);

const [[conductors]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM conductors
`);

const [[passengers]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM users
  WHERE role = 'PASSENGER'
`);

const [[tickets]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM tickets
`);

const [[complaints]] = await db.query(`
  SELECT COUNT(*) AS total
  FROM complaints
`);

const [[revenue]] = await db.query(`
  SELECT IFNULL(SUM(fare),0) AS total
  FROM tickets
`);

res.status(200).json({
  success: true,
  buses: buses.total,
  drivers: drivers.total,
  conductors: conductors.total,
  passengers: passengers.total,
  tickets: tickets.total,
  complaints: complaints.total,
  revenue: revenue.total
});


} catch (error) {

console.log(error);

res.status(500).json({
  success: false,
  message: "Failed to load dashboard data",
  error: error.message
});

}

};
