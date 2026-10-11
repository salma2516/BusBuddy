import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";

import "./BusManagement.css";

function BusManagement() {

  const [buses, setBuses] = useState([]);

  const [search, setSearch] = useState("");

  const [editId, setEditId] =
    useState(null);

  const [formData, setFormData] =
    useState({
      bus_number: "",
      bus_name: "",
      capacity: "",
      status: "ACTIVE"
    });

  const fetchBuses = async () => {

    try {

      const response =
        await axios.get(
          "http://localhost:5000/api/buses"
        );

      setBuses(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchBuses();

  }, []);

  const addBus = async () => {

    try {

      await axios.post(
        "http://localhost:5000/api/buses/add",
        formData
      );

      fetchBuses();

      setFormData({
        bus_number: "",
        bus_name: "",
        capacity: "",
        status: "ACTIVE"
      });

    } catch (error) {

      console.log(error);

    }

  };

  const editBus = (bus) => {

    setEditId(bus.id);

    setFormData({
      bus_number: bus.bus_number,
      bus_name: bus.bus_name,
      capacity: bus.capacity,
      status: bus.status
    });

  };

  const updateBus = async () => {

    try {

      await axios.put(
        `http://localhost:5000/api/buses/update/${editId}`,
        formData
      );

      setEditId(null);

      fetchBuses();

      setFormData({
        bus_number: "",
        bus_name: "",
        capacity: "",
        status: "ACTIVE"
      });

    } catch (error) {

      console.log(error);

    }

  };

  const deleteBus = async (id) => {

    try {

      await axios.delete(
        `http://localhost:5000/api/buses/delete/${id}`
      );

      fetchBuses();

    } catch (error) {

      console.log(error);

    }

  };

  const filteredBuses =
    buses.filter((bus) =>
      bus.bus_number
        .toLowerCase()
        .includes(
          search.toLowerCase()
        )
    );

  return (

    <div className="bus-layout">

      <Sidebar />

      <div className="bus-content">

        <Navbar />

        <div className="page-header">

          <h1>🚌 Bus Management</h1>

        </div>

        {/* Add Bus Form */}

        <div className="form-container">

          <input
            type="text"
            placeholder="Bus Number"
            value={formData.bus_number}
            onChange={(e) =>
              setFormData({
                ...formData,
                bus_number:
                  e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="Bus Name"
            value={formData.bus_name}
            onChange={(e) =>
              setFormData({
                ...formData,
                bus_name:
                  e.target.value
              })
            }
          />

          <input
            type="number"
            placeholder="Capacity"
            value={formData.capacity}
            onChange={(e) =>
              setFormData({
                ...formData,
                capacity:
                  e.target.value
              })
            }
          />

          <select
            value={formData.status}
            onChange={(e) =>
              setFormData({
                ...formData,
                status:
                  e.target.value
              })
            }
          >
            <option value="ACTIVE">
              ACTIVE
            </option>

            <option value="MAINTENANCE">
              MAINTENANCE
            </option>

            <option value="INACTIVE">
              INACTIVE
            </option>
          </select>

          {editId ? (

            <button
              className="action-btn"
              onClick={updateBus}
            >
              Update Bus
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={addBus}
            >
              Add Bus
            </button>

          )}

        </div>

        {/* Search */}

        <input
          type="text"
          placeholder="Search Bus Number"
          className="search-box"
          value={search}
          onChange={(e) =>
            setSearch(
              e.target.value
            )
          }
        />

        {/* Statistics */}

        <div className="stats-cards">

          <div className="stat-card">
            <h3>Total Buses</h3>
            <p>{buses.length}</p>
          </div>

          <div className="stat-card">
            <h3>Active Buses</h3>
            <p>
              {
                buses.filter(
                  (bus) =>
                    bus.status ===
                    "ACTIVE"
                ).length
              }
            </p>
          </div>

          <div className="stat-card">
            <h3>Maintenance</h3>
            <p>
              {
                buses.filter(
                  (bus) =>
                    bus.status ===
                    "MAINTENANCE"
                ).length
              }
            </p>
          </div>

        </div>

        {/* Table */}

        <div className="table-container">

          <table>

            <thead>

              <tr>

                <th>ID</th>

                <th>Bus Number</th>

                <th>Bus Name</th>

                <th>Capacity</th>

                <th>Status</th>

                <th>Actions</th>

              </tr>

            </thead>

            <tbody>

              {filteredBuses.map(
                (bus) => (

                  <tr key={bus.id}>

                    <td>{bus.id}</td>

                    <td>
                      {bus.bus_number}
                    </td>

                    <td>
                      {bus.bus_name}
                    </td>

                    <td>
                      {bus.capacity}
                    </td>

                    <td>
                      {bus.status}
                    </td>

                    <td>

                      <button
                        className="edit-btn"
                        onClick={() => editBus(bus)}
                      >
                        Edit
                      </button>

                      <button
                        className="delete-btn"
                        onClick={() => deleteBus(bus.id)}
                      >
                        Delete
                      </button>

                    </td>

                  </tr>

                )
              )}

            </tbody>

          </table>

        </div>

      </div>

    </div>

  );

}

export default BusManagement;
