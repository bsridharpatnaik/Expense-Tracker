import React from 'react';
import './index.css';
import { ReactComponent as Left } from '../../assets/svgs/arrowleft.svg';
import Transaction from '../../components/Transaction';
import { useGetHistoryQuery } from '../../service/api';
import { useNavigate } from 'react-router-dom';
import SkeletonCard from '../../components/Skeleton';

const History = () => {
  const { data, isFetching } = useGetHistoryQuery();
  const navigate = useNavigate();

  return (
    <div className='wrapper'>
      <div className='wrapper_container_heading'>
        <div className='text_container'>
          <Left onClick={() => navigate("/dashboard")} />
          <h5>History</h5>
        </div>
      </div>
      {isFetching ? (
        Array(5).fill().map((_, index) => (
          <SkeletonCard key={index} />
        ))
      ) : (
        data?.map((val, index) => (
          <Transaction
            key={index}
            borderBottom="1px solid #F7F9FC"
            background="unset"
            item={val}
            showIcon={false}
            showDetails={false}
            date={true}
            historyLog={true}
          />
        ))
      )}
    </div>
  );
};
export default History