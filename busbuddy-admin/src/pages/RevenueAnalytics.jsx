import { useEffect, useState } from "react";
import axios from "axios";

import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import Popup from "../components/Popup";

import "./RevenueAnalytics.css";

function RevenueAnalytics() {

  const [tickets, setTickets] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [popupType, setPopupType] = useState("");
  const [popupTitle, setPopupTitle] = useState("");
  const [popupMessage, setPopupMessage] = useState("");
  const [popupAction, setPopupAction] = useState(() => {});

  useEffect(() => {
    fetchTickets();
  }, []);

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

  const totalRevenue = tickets.reduce(
    (sum, ticket) =>
      sum + Number(ticket.amount || 0),
    0
  );

  const totalPassengers = tickets.reduce(
    (sum, ticket) =>
      sum + Number(ticket.seats || 0),
    0
  );

  const totalTrips = tickets.length;

  return (
    <div className="revenue-layout">

      <Sidebar />

      <div className="revenue-content">

        <Navbar />

        <h1 className="revenue-title">
          💰 Revenue Analytics
        </h1>

        {/* Revenue Cards */}

        <div className="revenue-cards">

          <div className="revenue-card">
            <h2>💰</h2>
            <h3>Total Revenue</h3>
            <p>₹{totalRevenue}</p>
          </div>

          <div className="revenue-card">
            <h2>🎟️</h2>
            <h3>Total Tickets</h3>
            <p>{tickets.length}</p>
          </div>

          <div className="revenue-card">
            <h2>🚌</h2>
            <h3>Total Trips</h3>
            <p>{totalTrips}</p>
          </div>

          <div className="revenue-card">
            <h2>👥</h2>
            <h3>Total Passengers</h3>
            <p>{totalPassengers}</p>
          </div>

        </div>

        {/* Revenue Table */}

        <div className="table-card">

          <h2>Conductor Ticket Revenue Report</h2>

          <table>

            <thead>
              <tr>
                <th>Ticket ID</th>
                <th>Passenger ID</th>
                <th>Bus ID</th>
                <th>From</th>
                <th>To</th>
                <th>Seats</th>
                <th>Amount</th>
              </tr>
            </thead>

            <tbody>

              {tickets.map((ticket) => (

                <tr key={ticket.id}>

                  <td>{ticket.id}</td>

                  <td>{ticket.passenger_id}</td>

                  <td>{ticket.bus_id}</td>

                  <td>{ticket.from_stop}</td>

                  <td>{ticket.to_stop}</td>

                  <td>{ticket.seats}</td>

                  <td>
                    ₹{ticket.amount}
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

export default RevenueAnalytics;