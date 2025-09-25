// Reusable card component to display any piece of information
export const InfoCard = ({ className, title, message }) => (
  <div className={`info-card ${className}`}>
    <h3>{title}</h3>
    <div>{message}</div>
  </div>
);