import React, { useState, useEffect } from 'react';
import '../css/orderstatus.css'

function OrderTracking() {
  const [orderStatus, setOrderStatus] = useState('Order Placed');

  useEffect(() => {
    // Here, you can make API calls to update the order status
    // based on the current status and delivery information
  }, [orderStatus]);

  return (
    <div className="order-status">
    <div className={"status-item completed"}>
      <div className="status-circle"></div>
      <div className="status-label">Available</div>
    </div>
    <div className="status-line"></div>
    <div className={"status-item " + (orderStatus === 'Order Placed' ? 'active' : '')}>
      <div className="status-circle"></div>
      <div className="status-label">Order Placed</div>
    </div>
    <div className="status-line"></div>
    <div className={"status-item " + (orderStatus === 'Order Received' ? 'active' : '')}>
      <div className="status-circle"></div>
      <div className="status-label">Order Received</div>
    </div>
    <div className="status-line"></div>
    <div className={"status-item " + (orderStatus === 'Item Dispatched' ? 'active' : '')}>
      <div className="status-circle"></div>
      <div className="status-label">Item Dispatched</div>
    </div>
    <div className="status-line"></div>
    <div className={"status-item " + (orderStatus === 'Delayed' ? 'active' : '')}>
      <div className="status-circle"></div>
      <div className="status-label">Delayed</div>
    </div>
    <div className="status-line"></div>
    <div className={"status-item " + (orderStatus === 'Delivered' ? 'active' : '')}>
      <div className="status-circle"></div>
      <div className="status-label">Delivered</div>
    </div>
  </div>


  );
}

export default OrderTracking;
