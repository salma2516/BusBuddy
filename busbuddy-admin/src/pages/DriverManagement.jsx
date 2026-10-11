import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./DriverManagement.css";

function DriverManagement() {

  const [drivers, setDrivers] = useState([]);

  const [search, setSearch] = useState("");

  const [editId, setEditId] = useState(null);

  const [formData, setFormData] = useState({

    name: "",
    email: "",
    phone: "",
    password: ""

  });

  const fetchDrivers = async () => {

    try {

      const response = await axios.get(
        "http://localhost:5000/api/drivers"
      );

      setDrivers(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchDrivers();

  }, []);

  const addDriver = async () => {

    try {

      await axios.post(
        "http://localhost:5000/api/drivers/add",
        formData
      );

      fetchDrivers();

      setFormData({
        name: "",
        email: "",
        phone: "",
        password: ""
      });

    } catch (error) {

      console.log(error);

    }

  };

  const editDriver = (driver) => {

    setEditId(driver.id);

    setFormData({

      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      password: ""

    });

  };

  const updateDriver = async () => {

    try {

      await axios.put(
        `http://localhost:5000/api/drivers/update/${editId}`,
        formData
      );

      setEditId(null);

      fetchDrivers();

    } catch (error) {

      console.log(error);

    }

  };

  const deleteDriver = async (id) => {

    try {

      await axios.delete(
        `http://localhost:5000/api/drivers/delete/${id}`
      );

      fetchDrivers();

    } catch (error) {

      console.log(error);

    }

  };

  const filteredDrivers =
    drivers.filter((driver) =>
      driver.name
        .toLowerCase()
        .includes(search.toLowerCase())
    );

  return (

    <div className="bus-layout">

      <Sidebar />

      <div className="bus-content">

        <Navbar />

        <h1>👨‍✈️ Driver Management</h1>

        <div className="form-container">

          <input
            type="text"
            placeholder="Driver Name"
            value={formData.name}
            onChange={(e) =>
              setFormData({
                ...formData,
                name: e.target.value
              })
            }
          />

          <input
            type="email"
            placeholder="Email"
            value={formData.email}
            onChange={(e) =>
              setFormData({
                ...formData,
                email: e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="Phone"
            value={formData.phone}
            onChange={(e) =>
              setFormData({
                ...formData,
                phone: e.target.value
              })
            }
          />

          <input
            type="password"
            placeholder="Password"
            value={formData.password}
            onChange={(e) =>
              setFormData({
                ...formData,
                password: e.target.value
              })
            }
          />

          {editId ? (

            <button
              className="action-btn"
              onClick={updateDriver}
            >
              Update Driver
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={addDriver}
            >
              Add Driver
            </button>

          )}

        </div>

        <input
          type="text"
          placeholder="Search Driver"
          className="search-box"
          value={search}
          onChange={(e) =>
            setSearch(e.target.value)
          }
        />

        <div className="stats-cards">

          <div className="stat-card">
            <h3>Total Drivers</h3>
            <p>{drivers.length}</p>
          </div>

        </div>

        <div className="table-container">

          <table>

            <thead>

              <tr>

                <th>ID</th>

                <th>Name</th>

                <th>Email</th>

                <th>Phone</th>

                <th>Actions</th>

              </tr>

            </thead>

            <tbody>

              {filteredDrivers.map(
                (driver) => (

                  <tr key={driver.id}>

                    <td>{driver.id}</td>

                    <td>{driver.name}</td>

                    <td>{driver.email}</td>

                    <td>{driver.phone}</td>

                    <td>

                      <button
                        className="edit-btn"
                        onClick={() =>
                          editDriver(driver)
                        }
                      >
                        Edit
                      </button>

                      <button
                        className="delete-btn"
                        onClick={() =>
                          deleteDriver(driver.id)
                        }
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

export default DriverManagement;