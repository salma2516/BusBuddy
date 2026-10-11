import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./ComplaintManagement.css";

function ComplaintManagement() {

  const [complaints, setComplaints] =
    useState([]);

  const [search, setSearch] =
    useState("");

  const [editId, setEditId] =
    useState(null);

  const [formData, setFormData] =
    useState({

      user_id: "",

      complaint_text: "",

      status: "OPEN"

    });

  // ==========================
  // FETCH COMPLAINTS
  // ==========================

  const fetchComplaints =
    async () => {

      try {

        const response =
          await axios.get(
            "http://localhost:5000/api/complaints"
          );

        setComplaints(
          response.data
        );

      } catch (error) {

        console.log(error);

      }

    };

  useEffect(() => {

    fetchComplaints();

  }, []);

  // ==========================
  // ADD COMPLAINT
  // ==========================

  const addComplaint =
    async () => {

      try {

        await axios.post(
          "http://localhost:5000/api/complaints/add",
          formData
        );

        fetchComplaints();

        setFormData({

          user_id: "",

          complaint_text: "",

          status: "OPEN"

        });

      } catch (error) {

        console.log(error);

      }

    };

  // ==========================
  // EDIT COMPLAINT
  // ==========================

  const editComplaint =
    (complaint) => {

      setEditId(
        complaint.id
      );

      setFormData({

        user_id:
          complaint.user_id,

        complaint_text:
          complaint.complaint_text,

        status:
          complaint.status

      });

    };

  // ==========================
  // UPDATE COMPLAINT
  // ==========================

  const updateComplaint =
    async () => {

      try {

        await axios.put(
          `http://localhost:5000/api/complaints/update/${editId}`,
          formData
        );

        setEditId(null);

        fetchComplaints();

      } catch (error) {

        console.log(error);

      }

    };

  // ==========================
  // DELETE COMPLAINT
  // ==========================

  const deleteComplaint =
    async (id) => {

      try {

        await axios.delete(
          `http://localhost:5000/api/complaints/delete/${id}`
        );

        fetchComplaints();

      } catch (error) {

        console.log(error);

      }

    };

  // ==========================
  // SEARCH
  // ==========================

  const filteredComplaints =
    complaints.filter(
      (complaint) =>
        complaint.complaint_text
          ?.toLowerCase()
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
            ⚠️ Complaint Management
          </h1>

        </div>

        {/* FORM */}

        <div className="form-container">

          <input
            type="number"
            placeholder="User ID"
            value={formData.user_id}
            onChange={(e) =>
              setFormData({
                ...formData,
                user_id:
                  e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="Complaint"
            value={
              formData.complaint_text
            }
            onChange={(e) =>
              setFormData({
                ...formData,
                complaint_text:
                  e.target.value
              })
            }
          />

          <select
            value={
              formData.status
            }
            onChange={(e) =>
              setFormData({
                ...formData,
                status:
                  e.target.value
              })
            }
          >

            <option value="OPEN">
              OPEN
            </option>

            <option value="IN_PROGRESS">
              IN_PROGRESS
            </option>

            <option value="RESOLVED">
              RESOLVED
            </option>

          </select>

          {editId ? (

            <button
              className="action-btn"
              onClick={
                updateComplaint
              }
            >
              Update Complaint
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={
                addComplaint
              }
            >
              Add Complaint
            </button>

          )}

        </div>

        {/* SEARCH */}

        <input
          type="text"
          className="search-box"
          placeholder="Search Complaint"
          value={search}
          onChange={(e) =>
            setSearch(
              e.target.value
            )
          }
        />

        {/* STATISTICS */}

        <div className="stats-cards">

          <div className="stat-card">

            <h3>
              Total Complaints
            </h3>

            <p>
              {
                complaints.length
              }
            </p>

          </div>

          <div className="stat-card">

            <h3>
              Open
            </h3>

            <p>

              {
                complaints.filter(
                  (c) =>
                    c.status ===
                    "OPEN"
                ).length
              }

            </p>

          </div>

          <div className="stat-card">

            <h3>
              Resolved
            </h3>

            <p>

              {
                complaints.filter(
                  (c) =>
                    c.status ===
                    "RESOLVED"
                ).length
              }

            </p>

          </div>

        </div>

        {/* TABLE */}

        <div className="table-container">

          <table>

            <thead>

              <tr>

                <th>ID</th>

                <th>User ID</th>

                <th>Complaint</th>

                <th>Status</th>

                <th>Actions</th>

              </tr>

            </thead>

            <tbody>

              {filteredComplaints.map(
                (complaint) => (

                  <tr
                    key={
                      complaint.id
                    }
                  >

                    <td>
                      {
                        complaint.id
                      }
                    </td>

                    <td>
                      {
                        complaint.user_id
                      }
                    </td>

                    <td>
                      {
                        complaint.complaint_text
                      }
                    </td>

                    <td>
                      {
                        complaint.status
                      }
                    </td>

                    <td>

                      <button
                        className="edit-btn"
                        onClick={() =>
                          editComplaint(
                            complaint
                          )
                        }
                      >
                        Edit
                      </button>

                      <button
                        className="delete-btn"
                        onClick={() =>
                          deleteComplaint(
                            complaint.id
                          )
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

export default ComplaintManagement;
