import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import ItemCard from './item';
import { useEffect, useState } from 'react';
import { Col } from 'react-bootstrap';
import { Row } from 'react-bootstrap';


function Home() {
  let Purchaser = true;
  let Merchant = false;
  let testItemsData = [
    {
      "Name": "Item1",
      "Merchant": "0x748674988942hdvcvsdvjhfey",
      "IsAvailable": true,
      "price": 500
    },
    {
      "Name": "Item1",
      "Merchant": "0x748674988942hdvcvsdvjhfey",
      "IsAvailable": false,
      "price": 500
    },
    {
      "Name": "Item1",
      "Merchant": "0x748674988942hdvcvsdvjhfey",
      "IsAvailable": true,
      "price": 500
    }
  ]
  let testItems = [];
  testItemsData.forEach(itemData => {
    testItems.push(
      <Row>
        <ItemCard Key={testItems.length} name={itemData.Name} merchant={itemData.Merchant}
        price={itemData.price} isAvailable={itemData.IsAvailable} isMerchant={Merchant} isPurchaser={Purchaser}/>
      </Row>
      
    )
  });

  let [items, getItems ]  = useState(testItems);
  useEffect(
    ()=>{
      getItems(testItems)
    }
  )

  return (
    <div className="Home">
      <Col className='mb-5'>
      {items}
      </Col>
      
    </div>
  );
}

export default Home;