type InfoCardProps = {
  className?: string;
  title: string;
  message: string;
};

export const InfoCard = ({ className, title, message }: InfoCardProps) => (
  <div className={`info-card ${className}`}>
    <h3>{title}</h3>
    <div>{message}</div>
  </div>
);