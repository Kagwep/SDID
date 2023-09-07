import React from 'react'

import { Provider, Account, Contract, CallData } from "starknet"
import SDID from './assets/SDID.json'
import axios from 'axios';

const privateKey = "0x259f4329e6f4590b9a164106cf6a659e";
const accountAddress = "0x7f61fa3893ad0637b2ff76fed23ebbb91835aacd4f743c2347716f856438429";
const contractAddress = "0x561e8423ca6c291e56b5085e4a823dc1918646d20d7d98acdbaa09649337ecf";



const App = () => {

  const provider = new Provider({ rpc: { nodeUrl: "http://127.0.0.1:5050/rpc" } })
  const account = new Account(provider, accountAddress, privateKey)
  const contract = new Contract(SDID.abi, contractAddress, provider)

  async function callContract() {
    // const new_contract = new Contract(abi, contractAddress, provider)
    const res = await contract.get_number()
    console.log(res.toString())

  }

  async function writeToContract() {
    contract.connect(account)
    


    const UserSpine = {
      first_name: 'John',
      last_name: 'Doe',
      phone_number: '07784389382',
      email: 'john@example.com',
      address: '3 123 56',
      secret_word : 'XXXXXXXX',
  };

    
    const  UserExperience =  {
      profile_picture: 'CID-ProfilePicture', // CID for the profile picture
      bio: 'CID-Bio', // CID for the bio
      social_media_links: 'CID-SocialMediaLinks', // CID for social media links
      languages: 'CID-Languages', // CID for languages
      hobbies: 'CID-Hobbies', // CID for hobbies
      interests: 'CID-Interests', // CID for interests
  };


  //  let userExperience =   UserExperience::default;

  
  const UserIdentity = {
      gender: 'Male', // Gender
      date_of_birth: '1990-01-01', // Date of birth
      nationality: 'Kenyan', // Nationality
      passport_number: 'ABC123456', // Passport number
      driver_license_number: 'XYZ789', // Driver's license number
      personal_identifier: '123456789', // Personal identifier
      unique_identifier: '987654321', // Unique identifier
  };

  const UserEngagement = {
      location: 'Unknown', // Location
      education: 'CID-Education', // CID for education
      occupation: 'CID-Occupation', // CID for occupation
      employer: 'CID-Employer', // CID for employer
      marital_status: 'Single', // Marital status
  };

  const UserFinancial = {
  user: accountAddress,
  stark_worth: 0,
  
  };

  const person =  {
      user_spine: UserSpine,
      user_experience: UserExperience,
      user_identity: UserIdentity,
      user_engagement: UserEngagement,
      user_financial:UserFinancial,
  };

    const myCall = await contract.set_person_tier_four(person);
    console.log('my call',myCall)
    const res = await contract.get_person_tier(myCall.transaction_hash);
    console.log("Invoke result: ", res.toString())
    // const txh = await provider.waitForTransaction(res.transaction_hash);
    // console.log("TX Hash: ", txh)
    callContract()
  }

  return (
    <div className='d-flex'>
      <button className="btn" onClick={callContract}>Get number</button>
      <button className="btn" onClick={writeToContract}>Set Tier</button>
    </div>
  )
}

export default App

