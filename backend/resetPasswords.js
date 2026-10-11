
const db = require("./config/db");
const bcrypt = require("bcryptjs");

const accounts = [
  {
    email: "admin@gmail.com",
    role: "ADMIN",
    newPassword: "AdminTemp@2026"
  },
  {
    email: "passenger@gmail.com",
    role: "PASSENGER",
    newPassword: "PassengerTemp@2026"
  },
  {
    email: "driver@gmail.com",
    role: "DRIVER",
    newPassword: "DriverTemp@2026"
  },
  {
    email: "conductor@gmail.com",
    role: "CONDUCTOR",
    newPassword: "ConductorTemp@2026"
  }
];

async function resetPasswords() {
  try {
    for (const account of accounts) {
      const [users] = await db.query(
        "SELECT id FROM users WHERE email = ? AND role = ?",
        [account.email, account.role]
      );

      if (users.length !== 1) {
        console.log(`Skipped ${account.role}: account not found`);
        continue;
      }

      const hash = await bcrypt.hash(account.newPassword, 10);

      await db.query(
        "UPDATE users SET password = ? WHERE id = ?",
        [hash, users[0].id]
      );

      console.log(`Reset successful: ${account.role}`);
    }
  } catch (error) {
    console.error("Reset failed:", error.message);
  } finally {
    await db.end();
  }
}

resetPasswords();
