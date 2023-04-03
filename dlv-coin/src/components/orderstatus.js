import React, { useState, useEffect } from 'react';
import '../css/orderstatus.css'

function OrderTracking() {
  const [orderStatus, setOrderStatus] = useState('Order Placed');
  
  useEffect(() => {
    // Here, you can make API calls to update the order status
    // based on the current status and delivery information
  }, [orderStatus]);

  return (
    <div class="order-status">
  <div class="status-item completed">
    <div class="status-circle"></div>
    <div class="status-label">Available</div>
  </div>
  <div class="status-line"></div>
  <div class="status-item completed">
    <div class="status-circle"></div>
    <div class="status-label">Order Placed</div>
  </div>
  <div class="status-line"></div>
  <div class="status-item active">
    <div class="status-circle"></div>
    <div class="status-label">Order Received</div>
  </div>
  <div class="status-line"></div>
  <div class="status-item">
    <div class="status-circle"></div>
    <div class="status-label">Item Dispatched</div>
  </div>
  <div class="status-line"></div>
  <div class="status-item">
    <div class="status-circle"></div>
    <div class="status-label">Delayed</div>
  </div>
  <div class="status-line"></div>
  <div class="status-item">
    <div class="status-circle"></div>
    <div class="status-label">Delayed</div>
  </div>
</div>

   
  );
}

export default OrderTracking;
