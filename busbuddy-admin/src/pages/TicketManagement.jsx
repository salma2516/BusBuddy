import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./TicketManagement.css";

function TicketManagement() {

  const [tickets, setTickets] = useState([]);

  const [search, setSearch] = useState("");

  const [editId, setEditId] = useState(null);

  const [formData, setFormData] = useState({
    passenger_id: "",
    bus_id: "",
    from_stop: "",
    to_stop: "",
    seats: 1,
    amount: "",
    payment_status: "PAID",
    status: "ACTIVE"
  });

  const fetchTickets = async () => {

    try {

      const response = await axios.get(
        "http://localhost:5000/api/tickets"
      );

      setTickets(response.data);

    } catch (error) {

      console.log(error);

    }

  };

  useEffect(() => {

    fetchTickets();

  }, []);

  const addTicket = async () => {

    try {

      await axios.post(
        "http://localhost:5000/api/tickets/add",
        {
          ...formData,
          source_stop: formData.from_stop,
          destination_stop: formData.to_stop,
          fare: formData.amount
        }
      );

      fetchTickets();

      setFormData({
        passenger_id: "",
        bus_id: "",
        from_stop: "",
        to_stop: "",
        seats: 1,
        amount: "",
        payment_status: "PAID",
        status: "ACTIVE"
      });

      alert("Ticket Added Successfully");

    } catch (error) {

      console.log(error);

      alert("Failed To Add Ticket");

    }

  };

  const editTicket = (ticket) => {

    setEditId(ticket.id);

    setFormData({
      passenger_id: ticket.passenger_id,
      bus_id: ticket.bus_id,
      from_stop: ticket.from_stop,
      to_stop: ticket.to_stop,
      seats: ticket.seats,
      amount: ticket.amount,
      payment_status: ticket.payment_status,
      status: ticket.status
    });

  };

  const updateTicket = async () => {

    try {

      await axios.put(
        `http://localhost:5000/api/tickets/update/${editId}`,
        {
          ...formData,
          source_stop: formData.from_stop,
          destination_stop: formData.to_stop,
          fare: formData.amount
        }
      );

      setEditId(null);

      fetchTickets();

      setFormData({
        passenger_id: "",
        bus_id: "",
        from_stop: "",
        to_stop: "",
        seats: 1,
        amount: "",
        payment_status: "PAID",
        status: "ACTIVE"
      });

      alert("Ticket Updated Successfully");

    } catch (error) {

      console.log(error);

    }

  };

  const deleteTicket = async (id) => {

    try {

      await axios.delete(
        `http://localhost:5000/api/tickets/delete/${id}`
      );

      fetchTickets();

      alert("Ticket Deleted Successfully");

    } catch (error) {

      console.log(error);

    }

  };

  const filteredTickets =
    tickets.filter((ticket) =>
      String(ticket.passenger_id)
        .includes(search)
    );

  return (

    <div className="bus-layout">

      <Sidebar />

      <div className="bus-content">

        <Navbar />

        <div className="page-header">

          <h1>🎟️ Ticket Management</h1>

        </div>

        {/* Form */}

        <div className="form-container">

          <input
            type="number"
            placeholder="Passenger ID"
            value={formData.passenger_id}
            onChange={(e) =>
              setFormData({
                ...formData,
                passenger_id: e.target.value
              })
            }
          />

          <input
            type="number"
            placeholder="Bus ID"
            value={formData.bus_id}
            onChange={(e) =>
              setFormData({
                ...formData,
                bus_id: e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="From Stop"
            value={formData.from_stop}
            onChange={(e) =>
              setFormData({
                ...formData,
                from_stop: e.target.value
              })
            }
          />

          <input
            type="text"
            placeholder="To Stop"
            value={formData.to_stop}
            onChange={(e) =>
              setFormData({
                ...formData,
                to_stop: e.target.value
              })
            }
          />

          <input
            type="number"
            placeholder="Seats"
            value={formData.seats}
            onChange={(e) =>
              setFormData({
                ...formData,
                seats: e.target.value
              })
            }
          />

          <input
            type="number"
            placeholder="Amount"
            value={formData.amount}
            onChange={(e) =>
              setFormData({
                ...formData,
                amount: e.target.value
              })
            }
          />

          <select
            value={formData.payment_status}
            onChange={(e) =>
              setFormData({
                ...formData,
                payment_status: e.target.value
              })
            }
          >
            <option value="PAID">
              PAID
            </option>

            <option value="PENDING">
              PENDING
            </option>

          </select>

          {editId ? (

            <button
              className="action-btn"
              onClick={updateTicket}
            >
              Update Ticket
            </button>

          ) : (

            <button
              className="action-btn"
              onClick={addTicket}
            >
              Add Ticket
            </button>

          )}

        </div>

        {/* Search */}

        <input
          type="text"
          placeholder="Search Passenger ID"
          className="search-box"
          value={search}
          onChange={(e) =>
            setSearch(e.target.value)
          }
        />

        {/* Statistics */}

        <div className="stats-cards">

          <div className="stat-card">
            <h3>Total Tickets</h3>
            <p>{tickets.length}</p>
          </div>

          <div className="stat-card">
            <h3>Active Tickets</h3>
            <p>
              {
                tickets.filter(
                  t => t.status === "ACTIVE"
                ).length
              }
            </p>
          </div>

          <div className="stat-card">
            <h3>Total Revenue</h3>
            <p>
              ₹{
                tickets.reduce(
                  (sum, t) =>
                    sum + Number(t.amount || 0),
                  0
                )
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
                <th>Passenger ID</th>
                <th>Bus ID</th>
                <th>From Stop</th>
                <th>To Stop</th>
                <th>Seats</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Actions</th>

              </tr>

            </thead>

            <tbody>

              {filteredTickets.map((ticket) => (

                <tr key={ticket.id}>

                  <td>{ticket.id}</td>

                  <td>{ticket.passenger_id}</td>

                  <td>{ticket.bus_id}</td>

                  <td>{ticket.from_stop}</td>

                  <td>{ticket.to_stop}</td>

                  <td>{ticket.seats}</td>

                  <td>₹{ticket.amount}</td>

                  <td>{ticket.status}</td>

                  <td>

                    <button
                        className="edit-btn"
                            onClick={() => editTicket(ticket)}
                    >
                        Edit
                    </button>

                    <button
                        className="delete-btn"
                            onClick={() => deleteTicket(ticket.id)}
                    >
                        Delete
                    </button>

                  </td>

                </tr>

              ))}

            </tbody>

          </table>

        </div>

      </div>

    </div>

  );

}

export default TicketManagement;