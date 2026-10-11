import { useState } from "react";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";

import "./Settings.css";

function Settings() {

  const [showPopup, setShowPopup] = useState(false);

  const [profile, setProfile] = useState({
    name: "Admin",
    email: "admin@busbuddy.com",
    phone: "9876543210",
    password: ""
  });

  const handleUpdate = () => {

    setShowPopup(true);

  };

  return (

    <div className="bus-layout">

      <Sidebar />

      <div className="bus-content">

        <Navbar />

        <div className="page-header">

          <h1>⚙ Settings</h1>

        </div>

        {/* Statistics Cards */}

        <div className="stats-cards">

          <div className="stat-card">
            <h3>Role</h3>
            <p>Admin</p>
          </div>

          <div className="stat-card">
            <h3>Status</h3>
            <p>Active</p>
          </div>

          <div className="stat-card">
            <h3>System</h3>
            <p>Bus Buddy</p>
          </div>

        </div>

        {/* Settings Form */}

        <div className="form-container">

          <input
            type="text"
            placeholder="Name"
            value={profile.name}
            onChange={(e) =>
              setProfile({
                ...profile,
                name: e.target.value
              })
            }
          />

          <input
            type="email"
            placeholder="Email"
            value={profile.email}
            onChange={(e) =>
              setProfile({
                ...profile,
                email: e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="Phone Number"
            value={profile.phone}
            onChange={(e) =>
              setProfile({
                ...profile,
                phone: e.target.value
              })
            }
          />

          <input
            type="password"
            placeholder="New Password"
            value={profile.password}
            onChange={(e) =>
              setProfile({
                ...profile,
                password: e.target.value
              })
            }
          />

          <button
            className="action-btn"
            onClick={handleUpdate}
          >
            Update Profile
          </button>

        </div>

        {/* Custom Popup */}

        {showPopup && (

          <div className="popup-overlay">

            <div className="popup-box">

              <div className="popup-icon">
                ✅
              </div>

              <h2>Profile Updated</h2>

              <p>
                Your profile has been updated successfully.
              </p>

              <button
                className="popup-btn"
                onClick={() =>
                  setShowPopup(false)
                }
              >
                OK
              </button>

            </div>

          </div>

        )}

      </div>

    </div>

  );

}

export default Settings;