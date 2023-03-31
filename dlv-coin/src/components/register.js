import '../App.css';
import 'bootstrap/dist/css/bootstrap.min.css';

import React, { useState } from "react";
import { Form, Button } from "react-bootstrap";
import Web3 from "web3";

const RegisterForm = () => {
  const [name, setName] = useState("");
  const [connectedAddress, setConnectedAddress] = useState("");

  const connectToMetamask = async () => {
    // Check if Web3 has been injected by the browser (Metamask)
    if (window.ethereum) {
      try {
        // Request account access if needed
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const web3 = new Web3(window.ethereum);
        // Get the connected wallet address
        const accounts = await web3.eth.getAccounts();
        setConnectedAddress(accounts[0]);
      } catch (error) {
        console.error(error);
      }
    } else {
      alert("Please install Metamask to use this feature.");
    }
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    console.log(`Name: ${name}, Connected Address: ${connectedAddress}`);
    // Do something with the name and connected address
  };

  return (
    <div>
      <h2>Connect your wallet to register</h2>
      <Form onSubmit={handleSubmit}>
        <Form.Group>
          <Form.Label>Name</Form.Label>
          <Form.Control
            type="text"
            value={name}
            onChange={(event) => setName(event.target.value)}
            placeholder="Enter your name"
          />
        </Form.Group>
        <Button variant="primary" onClick={connectToMetamask}>
          Connect Wallet
        </Button>{" "}
        {connectedAddress && (
          <span>
            Connected to wallet address: <strong>{connectedAddress}</strong>
          </span>
        )}
      </Form>
    </div>
  );
};



export default RegisterForm;