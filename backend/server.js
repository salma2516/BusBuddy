const express = require("express");
const http = require("http");
const cors = require("cors");
const dotenv = require("dotenv");
const { Server } = require("socket.io");

// ======================
// CONFIGURATION
// ======================

dotenv.config();

// ======================
// DATABASE
// ======================

const db = require("./config/db");

// ======================
// ROUTES
// ======================

const authRoutes = require("./routes/authRoutes");
const locationRoutes = require("./routes/locationRoutes");
const districtRoutes = require("./routes/districtRoutes");
const stopRoutes = require("./routes/stopRoutes");
const ticketRoutes = require("./routes/ticketRoutes");

const passengerRoutes = require("./routes/passengerRoutes");
const busRoutes = require("./routes/busRoutes");
const driverRoutes = require("./routes/driverRoutes");
const conductorRoutes = require("./routes/conductorRoutes");
const complaintRoutes = require("./routes/complaintRoutes");
const revenueRoutes = require("./routes/revenueRoutes");
const dashboardRoutes = require("./routes/dashboardRoutes");
const settingsRoutes = require("./routes/settingsRoutes");

// ======================
// EXPRESS APP
// ======================

const app = express();

// ======================
// HTTP SERVER
// ======================

const server = http.createServer(app);

// ======================
// SOCKET.IO
// ======================

const io = new Server(server, {

  cors: {

    origin: "*",

    methods: ["GET", "POST"]

  }

});

// ======================
// MIDDLEWARE
// ======================

app.use(cors());

app.use(express.json());

app.use(express.urlencoded({
  extended: true
}));

// ======================
// DATABASE CONNECTION
// ======================

db.getConnection()

  .then((connection) => {

    console.log(
      "✅ MySQL Connected Successfully"
    );

    connection.release();

  })

  .catch((err) => {

    console.log(
      "❌ Database Connection Failed"
    );

    console.log(err);

  });

// ======================
// API ROUTES
// ======================

// AUTH

app.use(
  "/api/auth",
  authRoutes
);

// LOCATION

app.use(
  "/api/location",
  locationRoutes
);

// DISTRICTS

app.use(
  "/api/districts",
  districtRoutes
);

// STOPS

app.use(
  "/api/stops",
  stopRoutes
);

// TICKETS

app.use(
  "/api/tickets",
  ticketRoutes
);

// CONDUCTORS
app.use(
  "/api/conductors",
  conductorRoutes
);

// PASSENGERS

app.use(
  "/api/passengers",
  passengerRoutes
);

// BUSES

app.use(
  "/api/buses",
  busRoutes
);

// DRIVERS

app.use(
  "/api/drivers",
  driverRoutes
);

// COMPLAINTS

app.use(
  "/api/complaints",
  complaintRoutes
);

// REVENUE

app.use(
  "/api/revenue",
  revenueRoutes
);

// DASHBOARD

app.use(
  "/api/dashboard",
  dashboardRoutes
);

// SETTINGS

app.use(
  "/api/settings",
  settingsRoutes
);

// ======================
// ROOT ROUTE
// ======================

app.get("/", (req, res) => {

  res.status(200).json({

    success: true,

    project: "BusBuddy 2.0",

    message:
      "BusBuddy Backend Running Successfully"

  });

});

// ======================
// SOCKET.IO EVENTS
// ======================

io.on("connection", (socket) => {

  console.log(
    `🟢 User Connected: ${socket.id}`
  );

  // ======================
  // LIVE BUS TRACKING
  // ======================

  socket.on(
    "bus-location-update",
    async (data) => {

      try {

        console.log(
          "📍 Location Received:",
          data
        );

        io.emit(
          "receive-location",
          {

            busId: data.busId,

            latitude:
              data.latitude,

            longitude:
              data.longitude,

            speed:
              data.speed,

            timestamp:
              new Date()

          }
        );

      } catch (error) {

        console.log(
          "❌ Location Socket Error"
        );

        console.log(error);

      }

    }
  );

  // ======================
  // ANNOUNCEMENTS
  // ======================

  socket.on(
    "send-announcement",
    (data) => {

      io.emit(
        "receive-announcement",
        data
      );

    }
  );

  // ======================
  // NEW COMPLAINT
  // ======================

  socket.on(
    "new-complaint",
    (data) => {

      io.emit(
        "complaint-alert",
        data
      );

    }
  );

  // ======================
  // NEW TICKET BOOKED
  // ======================

  socket.on(
    "ticket-booked",
    (data) => {

      io.emit(
        "ticket-update",
        data
      );

    }
  );

  // ======================
  // DISCONNECT
  // ======================

  socket.on(
    "disconnect",
    () => {

      console.log(
        `🔴 User Disconnected: ${socket.id}`
      );

    }
  );

});

// ======================
// ERROR HANDLER
// ======================

app.use((err, req, res, next) => {

  console.log(err);

  res.status(500).json({

    success: false,

    message:
      "Internal Server Error"

  });

});

// ======================
// PORT
// ======================

const PORT =
  process.env.PORT || 5000;

// ======================
// START SERVER
// ======================

server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server Running On Port ${PORT}`);
  console.log(`🌐 Network: http://10.131.101.232:${PORT}`);
});
