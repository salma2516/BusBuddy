import "./Popup.css";

function Popup({
  show,
  type,
  title,
  message,
  onClose
}) {

  if (!show) return null;

  const icon =
    type === "delete"
      ? "🗑️"
      : type === "update"
      ? "✏️"
      : "✅";

  return (

    <div className="popup-overlay">

      <div className="popup-box">

        <div className="popup-icon">
          {icon}
        </div>

        <h2>{title}</h2>

        <p>{message}</p>

        <button
          className="popup-btn"
          onClick={onClose}
        >
          OK
        </button>

      </div>

    </div>

  );

}

export default Popup;