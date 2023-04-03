import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import OrderTracking from './orderstatus';
import { useState } from 'react';

function StatusBoard() {
  let {orders,getOrders} = useState();
  
  return (
    <div className="Home">
      <OrderTracking/>
    </div>
  );
}

export default StatusBoard;