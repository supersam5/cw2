import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import {Link} from "react-router-dom";

function Header() {
  return (
    <header className="p-3 bg-dark text-white">
    <div className="container">
      <div className="d-flex flex-wrap align-items-center justify-content-center justify-content-lg-start">
        <a href="/" className="d-flex align-items-center mb-2 mb-lg-0 text-white text-decoration-none">
           <h1>DeliverCoin</h1>
        </a>

        <ul className="nav col-12 col-lg-auto me-lg-auto mb-2 justify-content-center mb-md-0">
        
          <li><a href="#" className="nav-link px-2 text-secondary"><Link to='/'>Home</Link></a></li>
          <li><a href="#" className="nav-link px-2 text-white"><Link to="/status">Status</Link></a></li>
          
        </ul>

        

        <div className="text-end">
          <button type="button" NamName="btn btn-outline-light me-2"><Link to="/register">Login</Link></button>
          <button type="button" className="btn btn-warning"><Link to="/register">Sign-up</Link></button>
        </div>
      </div>
    </div>
  </header>
  );
}

export default Header;