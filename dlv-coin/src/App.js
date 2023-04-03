import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import Header from '../src/components/header';
import Container from 'react-bootstrap/Container';
import { Col } from 'react-bootstrap/Col';
import { Row } from 'react-bootstrap';

function App(props) {
  return (

    <div className="App">
      <Header></Header>
      <Container>
        <Row>
        {props.children}
        </Row>
      </Container>
      
    </div>
  );
}

export default App;
