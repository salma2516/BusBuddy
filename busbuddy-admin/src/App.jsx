import { BrowserRouter, Routes, Route } from "react-router-dom";

import Dashboard from "./pages/Dashboard";
import BusManagement from "./pages/BusManagement";
import DriverManagement from "./pages/DriverManagement";
import ConductorManagement from "./pages/ConductorManagement";
import PassengerManagement from "./pages/PassengerManagement";
import TicketManagement from "./pages/TicketManagement";
import ComplaintManagement from "./pages/ComplaintManagement";
import LiveTracking from "./pages/LiveTracking";
import RevenueAnalytics from "./pages/RevenueAnalytics";
import Settings from "./pages/Settings";

function App() {
  return (
    <BrowserRouter>

      <Routes>

        {/* Dashboard */}
        <Route
          path="/"
          element={<Dashboard />}
        />

        {/* Bus Management */}
        <Route
          path="/buses"
          element={<BusManagement />}
        />

        {/* Driver Management */}
        <Route
          path="/drivers"
          element={<DriverManagement />}
        />

        {/* Conductor Management */}
        <Route
          path="/conductors"
          element={<ConductorManagement />}
        />

        {/* Passenger Management */}
        <Route
          path="/passengers"
          element={<PassengerManagement />}
        />

        {/* Ticket Management */}
        <Route
          path="/tickets"
          element={<TicketManagement />}
        />

        {/* Complaint Management */}
        <Route
          path="/complaints"
          element={<ComplaintManagement />}
        />

        {/* Live Tracking */}
        <Route
          path="/tracking"
          element={<LiveTracking />}
        />

        {/* Revenue Analytics */}
        <Route
          path="/revenue"
          element={<RevenueAnalytics />}
        />

        {/* Settings */}
        <Route
          path="/settings"
          element={<Settings />}
        />

      </Routes>

    </BrowserRouter>
  );
}

export default App;