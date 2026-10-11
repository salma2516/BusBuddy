import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";
import "./Dashboard.css";
import { useNavigate } from "react-router-dom";
import { useState, useEffect } from "react";
import axios from "axios";

function Dashboard() {

  const navigate = useNavigate();

  const [stats, setStats] = useState({
    buses: 0,
    drivers: 0,
    conductors: 0,
    passengers: 0,
    tickets: 0,
    complaints: 0,
    revenue: 0
  });

  const [loading, setLoading] =
    useState(true);

  const fetchDashboardData =
    async () => {

      try {

        const response =
          await axios.get(
            "http://localhost:5000/api/dashboard"
          );

        setStats(response.data);

      } catch (error) {

        console.error(
          "Dashboard API Error:",
          error
        );

      } finally {

        setLoading(false);

      }

    };

  useEffect(() => {

    fetchDashboardData();

    const interval =
      setInterval(
        fetchDashboardData,
        10000
      );

    return () =>
      clearInterval(interval);

  }, []);

  if (loading) {

    return (
      <div
        style={{
          padding: "30px",
          fontSize: "20px"
        }}
      >
        Loading Dashboard...
      </div>
    );

  }

  return (

    <div className="dashboard-layout">

      <Sidebar />

      <div className="main-content">

        <Navbar />

        {/* Running Announcement */}

        <div className="announcement-bar">

          <marquee scrollAmount="8">

            📍 Live Tracking Active |
            👨‍✈️ Drivers: {stats.drivers} |
            🎫 Tickets: {stats.tickets} |
            👥 Passengers: {stats.passengers} |
            💰 Revenue: ₹{stats.revenue} |
            🚏 Smart Transport Management Running

          </marquee>

        </div>

        {/* Dashboard Cards */}

        <div className="cards">

          <div
            className="dashboard-card"
            onClick={() => navigate("/buses")}
          >
            <h2>🚌</h2>
            <h3>Total Buses</h3>
            <p>{stats.buses}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/drivers")}
          >
            <h2>👨‍✈️</h2>
            <h3>Total Drivers</h3>
            <p>{stats.drivers}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/conductors")}
          >
            <h2>🎫</h2>
            <h3>Conductors</h3>
            <p>{stats.conductors}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/passengers")}
          >
            <h2>👥</h2>
            <h3>Passengers</h3>
            <p>{stats.passengers}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/tickets")}
          >
            <h2>🎟️</h2>
            <h3>Tickets</h3>
            <p>{stats.tickets}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/complaints")}
          >
            <h2>⚠️</h2>
            <h3>Complaints</h3>
            <p>{stats.complaints}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/tracking")}
          >
            <h2>📍</h2>
            <h3>Live Tracking</h3>
            <p>Active</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/revenue")}
          >
            <h2>💰</h2>
            <h3>Revenue</h3>
            <p>₹{stats.revenue}</p>
          </div>

          <div
            className="dashboard-card"
            onClick={() => navigate("/settings")}
          >
            <h2>⚙️</h2>
            <h3>Settings</h3>
            <p>Admin</p>
          </div>

        </div>

      </div>

    </div>

  );

}

export default Dashboard;
