const jwt = require("jsonwebtoken");

// ==============================
// VERIFY TOKEN MIDDLEWARE
// ==============================

exports.verifyToken = (req, res, next) => {
  try {
    // Get token from headers
    const authHeader = req.headers.authorization;

    // Check if token exists
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Access Denied. No Token Provided",
      });
    }

    // Extract token
    const token = authHeader.split(" ")[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user data to request
    req.user = decoded;

    next();

  } catch (error) {
    console.log(error);

    return res.status(401).json({
      success: false,
      message: "Invalid or Expired Token",
    });
  }
};

// ==============================
// ROLE AUTHORIZATION MIDDLEWARE
// ==============================

exports.authorizeRoles = (...roles) => {
  return (req, res, next) => {

    // Check user role
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: "Access Forbidden",
      });
    }

    next();
  };
};