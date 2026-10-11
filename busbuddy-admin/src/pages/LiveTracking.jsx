import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";


import {
  MapContainer,
  TileLayer,
  Marker,
  Popup
} from "react-leaflet";

import L from "leaflet";

import "./LiveTracking.css";

delete L.Icon.Default.prototype._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",

  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",

  shadowUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png"
});

function LiveTracking() {

  const [locations, setLocations] = useState([]);
  const [search, setSearch] = useState("");

  const fetchLocations = async () => {

    try {

      const response = await axios.get(
        "http://localhost:5000/api/location"
      );

      setLocations(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchLocations();

    const interval = setInterval(
      fetchLocations,
      5000
    );

    return () => clearInterval(interval);

  }, []);

  const filteredLocations =
    locations.filter((bus) =>
      bus.bus_id
        ?.toString()
        .includes(search)
    );

  return (

    <div className="tracking-layout">

      <Sidebar />

      <div className="tracking-content">

        <Navbar />

        <div className="page-header">

          <h1>
            📍 Live Tracking
          </h1>

        </div>

        {/* Statistics */}

        <div className="stats-cards">

          <div className="stat-card">
            <h3>Total Buses</h3>
            <p>{locations.length}</p>
          </div>

          <div className="stat-card">
            <h3>Running</h3>
            <p>
              {
                locations.filter(
                  (b) => b.speed > 0
                ).length
              }
            </p>
          </div>

          <div className="stat-card">
            <h3>Stopped</h3>
            <p>
              {
                locations.filter(
                  (b) => b.speed === 0
                ).length
              }
            </p>
          </div>

        </div>

        {/* Search */}

        <input
          type="text"
          className="search-box"
          placeholder="Search Bus ID..."
          value={search}
          onChange={(e) =>
            setSearch(e.target.value)
          }
        />

        {/* Table */}

        <div className="table-container">

          <h2>
            Live Bus Details
          </h2>

          <table>

            <thead>

              <tr>

                <th>Bus ID</th>

                <th>Latitude</th>

                <th>Longitude</th>

                <th>Speed</th>

                <th>Status</th>

              </tr>

            </thead>

            <tbody>

              {filteredLocations.map((bus) => (

                <tr key={bus.id}>

                  <td>{bus.bus_id}</td>

                  <td>{bus.latitude}</td>

                  <td>{bus.longitude}</td>

                  <td>{bus.speed}</td>

                  <td>

                    <span
                      className={
                        bus.speed > 0
                          ? "status active"
                          : "status stopped"
                      }
                    >

                      {
                        bus.speed > 0
                          ? "Running"
                          : "Stopped"
                      }

                    </span>

                  </td>

                </tr>

              ))}

            </tbody>

          </table>

        </div>

        {/* Map */}

        <div className="map-card">

          <h2>
            🗺️ Live Bus Map
          </h2>

          <MapContainer
            center={[13.0827, 80.2707]}
            zoom={10}
            style={{
              height: "500px",
              width: "100%"
            }}
          >

            <TileLayer
              attribution="OpenStreetMap"
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            {filteredLocations.map((bus) => (

              <Marker
                key={bus.id}
                position={[
                  parseFloat(bus.latitude),
                  parseFloat(bus.longitude)
                ]}
              >

                <Popup>

                  <strong>
                    Bus ID:
                  </strong>

                  {" "}
                  {bus.bus_id}

                  <br />

                  <strong>
                    Speed:
                  </strong>

                  {" "}
                  {bus.speed}
                  km/h

                </Popup>

              </Marker>

            ))}

          </MapContainer>

        </div>

      </div>

    </div>

  );

}

export default LiveTracking;