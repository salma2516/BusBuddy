const db = require("../config/db");

exports.getRevenue =
async(req,res)=>{

  try{

    const [rows] =
    await db.query(`
      SELECT
      SUM(fare) AS totalRevenue
      FROM tickets
      WHERE payment_status='PAID'
    `);

    res.json(rows[0]);

  }catch(error){

    res.status(500).json(error);

  }

};