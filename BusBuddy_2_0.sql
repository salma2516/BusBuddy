USE busBuddy_2_0_db;

SELECT id, name, email, role
FROM users
WHERE role IN ('ADMIN', 'DRIVER', 'CONDUCTOR', 'PASSENGER');