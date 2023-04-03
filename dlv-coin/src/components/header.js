import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import {Link} from "react-router-dom";

function Header() {
  return (
    <header class="p-3 bg-dark text-white">
    <div class="container">
      <div class="d-flex flex-wrap align-items-center justify-content-center justify-content-lg-start">
        <a href="/" class="d-flex align-items-center mb-2 mb-lg-0 text-white text-decoration-none">
           <h1>DeliverCoin</h1>
        </a>

        <ul class="nav col-12 col-lg-auto me-lg-auto mb-2 justify-content-center mb-md-0">
        
          <li><Link to='/'><a href="#" class="nav-link px-2 text-secondary">Home</a></Link></li>
          <li><Link to="/status"><a href="#" class="nav-link px-2 text-white">Status</a></Link></li>
          
        </ul>

        

        <div class="text-end">
          <Link to="/register"><button type="button" class="btn btn-outline-light me-2">Login</button></Link>
          <Link to="/register"><button type="button" class="btn btn-warning">Sign-up</button></Link>
        </div>
      </div>
    </div>
  </header>
  );
}

export default Header;