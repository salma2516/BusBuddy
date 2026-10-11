import { Link } from "react-router-dom";
import "./Sidebar.css";

function Sidebar() {

  return (

    <aside className="sidebar">

      <div className="sidebar-header">

        <h1>🚌 BusBuddy</h1>

        <p>
          Smart Transportation System
        </p>

      </div>

      <nav className="sidebar-menu">

        <Link to="/">
          🏠 Dashboard
        </Link>

        <Link to="/buses">
          🚌 Bus Management
        </Link>

        <Link to="/drivers">
          👨‍✈️ Driver Management
        </Link>

        <Link to="/conductors">
          🎫 Conductor Management
        </Link>

        <Link to="/passengers">
          👥 Passenger Management
        </Link>

        <Link to="/tickets">
          🎟️ Ticket Management
        </Link>

        <Link to="/complaints">
          ⚠️ Complaint Management
        </Link>

        <Link to="/tracking">
          📍 Live Tracking
        </Link>

        <Link to="/revenue">
          💰 Revenue Analytics
        </Link>

        <Link to="/settings">
          ⚙️ Settings
        </Link>

      </nav>

      <div className="sidebar-footer">

        <hr />

        <p>
          Admin Dashboard
        </p>

        <p>
          © 2026 BusBuddy
        </p>

      </div>

    </aside>

  );

}

export default Sidebar;