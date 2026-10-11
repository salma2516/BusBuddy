import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./ConductorManagement.css";

function ConductorManagement() {

  const [conductors, setConductors] = useState([]);

  const [search, setSearch] = useState("");

  const [editId, setEditId] =
    useState(null);

  const [formData, setFormData] =
    useState({
      name: "",
      email: "",
      phone: "",
      status: "ACTIVE"
    });

  const fetchConductors = async () => {

    try {

      const response =
        await axios.get(
          "http://localhost:5000/api/conductors"
        );

      setConductors(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchConductors();

  }, []);

  const addConductor = async () => {

    try {

      await axios.post(
        "http://localhost:5000/api/conductors/add",
        formData
      );

      fetchConductors();

      setFormData({
        name: "",
        email: "",
        phone: "",
        status: "ACTIVE"
      });

    } catch (error) {

      console.log(error);

    }

  };

  const editConductor = (
    conductor
  ) => {

    setEditId(conductor.id);

    setFormData({
      name: conductor.name,
      email: conductor.email,
      phone: conductor.phone,
      status: conductor.status
    });

  };

  const updateConductor =
    async () => {

      try {

        await axios.put(
          `http://localhost:5000/api/conductors/update/${editId}`,
          formData
        );

        setEditId(null);

        fetchConductors();

        setFormData({
          name: "",
          email: "",
          phone: "",
          status: "ACTIVE"
        });

      } catch (error) {

        console.log(error);

      }

    };

  const deleteConductor =
    async (id) => {

      try {

        await axios.delete(
          `http://localhost:5000/api/conductors/delete/${id}`
        );

        fetchConductors();

      } catch (error) {

        console.log(error);

      }

    };

  const filteredConductors =
    conductors.filter(
      (conductor) =>
        conductor.name
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

          <h1>
            🎫 Conductor Management
          </h1>

        </div>

        {/* Form */}

        <div className="form-container">

          <input
            type="text"
            placeholder="Name"
            value={formData.name}
            onChange={(e) =>
              setFormData({
                ...formData,
                name:
                  e.target.value
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
                email:
                  e.target.value
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
                phone:
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

            <option value="INACTIVE">
              INACTIVE
            </option>

          </select>

          {editId ? (

            <button
              className="action-btn"
              onClick={
                updateConductor
              }
            >
              Update Conductor
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={
                addConductor
              }
            >
              Add Conductor
            </button>

          )}

        </div>

        {/* Search */}

        <input
          type="text"
          placeholder="Search Conductor"
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
            <h3>
              Total Conductors
            </h3>
            <p>
              {conductors.length}
            </p>
          </div>

          <div className="stat-card">
            <h3>
              Active Conductors
            </h3>
            <p>
              {
                conductors.filter(
                  (c) =>
                    c.status ===
                    "ACTIVE"
                ).length
              }
            </p>
          </div>

          <div className="stat-card">
            <h3>
              Inactive Conductors
            </h3>
            <p>
              {
                conductors.filter(
                  (c) =>
                    c.status ===
                    "INACTIVE"
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

                <th>Name</th>

                <th>Email</th>

                <th>Phone</th>

                <th>Status</th>

                <th>Actions</th>

              </tr>

            </thead>

            <tbody>

              {filteredConductors.map(
                (
                  conductor
                ) => (

                  <tr
                    key={
                      conductor.id
                    }
                  >

                    <td>
                      {
                        conductor.id
                      }
                    </td>

                    <td>
                      {
                        conductor.name
                      }
                    </td>

                    <td>
                      {
                        conductor.email
                      }
                    </td>

                    <td>
                      {
                        conductor.phone
                      }
                    </td>

                    <td>
                      {
                        conductor.status
                      }
                    </td>

                    <td>

                      <button
                        className="edit-btn"
                        onClick={() =>
                            editConductor(conductor)
                        }
                        >
                        Edit
                        </button>

                        <button
                        className="delete-btn"
                        onClick={() =>
                            deleteConductor(conductor.id)
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

export default ConductorManagement;