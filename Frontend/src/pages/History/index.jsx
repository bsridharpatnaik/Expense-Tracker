import React from 'react'
import "./index.css"
import { ReactComponent as Left } from "../../assets/svgs/arrowleft.svg";
import Transaction from '../../components/Transaction';
import { useGetHistoryQuery } from '../../service/api';

const History = () => {
  const { data }=useGetHistoryQuery()
  console.log("Data",data);
  return (
    <div className='wrapper'>
    <div className='wrapper_container_heading'>
      <div className='text_container'>
        <Left />
        <h5>History</h5>
        </div>
     
      </div>
      {data?.map((val, index) => {
        return <Transaction key={index} borderBottom="1px solid #F7F9FC" background="unset" item={val} showIcon={false} showDetails={false} date={true} historyLog={true} />;
      })}
    </div>
  )
}

export default History
