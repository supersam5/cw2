import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import Header from '../src/components/header';
import Container from 'react-bootstrap/Container';

function App(props) {
  return (

    <div className="App">
      <Header></Header>
      {props.children}
    </div>
  );
}

export default App;
