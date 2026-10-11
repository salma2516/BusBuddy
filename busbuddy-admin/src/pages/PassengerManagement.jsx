import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./PassengerManagement.css";

function PassengerManagement() {

  const [passengers, setPassengers] = useState([]);

  const [search, setSearch] = useState("");

  const [editId, setEditId] = useState(null);

  const [formData, setFormData] = useState({

    name: "",
    email: "",
    phone: "",
    password: ""

  });

  const fetchPassengers = async () => {

    try {

      const response = await axios.get(
        "http://localhost:5000/api/passengers"
      );

      setPassengers(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchPassengers();

  }, []);

  const addPassenger = async () => {

    try {

      await axios.post(
        "http://localhost:5000/api/passengers/add",
        formData
      );

      fetchPassengers();

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

  const editPassenger = (passenger) => {

    setEditId(passenger.id);

    setFormData({

      name: passenger.name,
      email: passenger.email,
      phone: passenger.phone,
      password: ""

    });

  };

  const updatePassenger = async () => {

    try {

      await axios.put(
        `http://localhost:5000/api/passengers/update/${editId}`,
        formData
      );

      setEditId(null);

      fetchPassengers();

    } catch (error) {

      console.log(error);

    }

  };

  const deletePassenger = async (id) => {

    try {

      await axios.delete(
        `http://localhost:5000/api/passengers/delete/${id}`
      );

      fetchPassengers();

    } catch (error) {

      console.log(error);

    }

  };

  const filteredPassengers =
    passengers.filter((passenger) =>
      passenger.name
        .toLowerCase()
        .includes(search.toLowerCase())
    );

  return (

    <div className="bus-layout">

      <Sidebar />

      <div className="bus-content">

        <Navbar />

        <h1>👥 Passenger Management</h1>

        <div className="form-container">

          <input
            type="text"
            placeholder="Passenger Name"
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
              onClick={updatePassenger}
            >
              Update Passenger
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={addPassenger}
            >
              Add Passenger
            </button>

          )}

        </div>

        <input
          type="text"
          placeholder="Search Passenger"
          className="search-box"
          value={search}
          onChange={(e) =>
            setSearch(e.target.value)
          }
        />

        <div className="stats-cards">

          <div className="stat-card">

            <h3>Total Passengers</h3>

            <p>{passengers.length}</p>

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

              {filteredPassengers.map(
                (passenger) => (

                  <tr key={passenger.id}>

                    <td>{passenger.id}</td>

                    <td>{passenger.name}</td>

                    <td>{passenger.email}</td>

                    <td>{passenger.phone}</td>

                    <td>

                      <button
                        className="edit-btn"
                        onClick={() =>
                          editPassenger(passenger)
                        }
                      >
                        Edit
                      </button>

                      <button
                        className="delete-btn"
                        onClick={() =>
                          deletePassenger(passenger.id)
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

export default PassengerManagement;