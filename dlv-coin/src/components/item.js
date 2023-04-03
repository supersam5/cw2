import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';

import React, { useState } from "react";
import { Form, Button, Card ,Badge} from "react-bootstrap";
import Web3 from "web3";



const ItemCard = ({ name, merchant, price, isAvailable,isPurchaser,isMerchant}) => {
    let imgSrc = "../../assets/img/item1.jpg";
    return (
      <Card className="mb-3">
        <div className="row no-gutters">
          <div className="col-md-4">
            <Card.Img
              variant="left"
              src= {{imgSrc}}
              alt="placeholder image"
              style={{"object-fit":"contain",width:"150px",height:"150px"}}
            />
          </div>
          <div className="col-md-8">
            <Card.Body>
              <Card.Title>{name}</Card.Title>
              <Card.Subtitle className="mb-2 text-muted">
                {merchant} {isAvailable && isMerchant && (<Badge variant="secondary">You</Badge>)}
              </Card.Subtitle>
              <Card.Text>PRICE: {price} $DLV</Card.Text>
              {isAvailable && isPurchaser &&(
                <Button variant="primary">Request Delivery</Button>
              )}
              {!isAvailable && isPurchaser &&(
                <Button variant="secondary">Unavailable</Button>
              )}
              {!isAvailable && isMerchant &&(
                <Badge variant="secondary">Sold</Badge>
              )}
              

            </Card.Body>
          </div>
        </div>
      </Card>
    );
  };
  
  export default ItemCard;
  
  
  
  
  