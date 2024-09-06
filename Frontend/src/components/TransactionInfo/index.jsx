import React, { useRef, useState } from "react";
import { ReactComponent as IncomeIcon } from "../../assets/svgs/Download.svg";
import { ReactComponent as ExpenseIcon } from "../../assets/svgs/Upload.svg";
import Transaction from "../../components/Transaction";
import AddButton from "../AddButton";
import "./index.css";
import AddTransactionModal from "../TransactionalModal";
const TransactionInfo = ({
  totalIncome,
  totalExpense,
  carryForward,
  expense,
  income,
}) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("Expense");
  const [isUpdate, setIsUpdate] = useState(false);
  const [dataToShow, setdataToShow] = useState({});

  const handleTabClick = (tab) => {
    setActiveTab(tab);
  };

  const handleAddButtonClick = (item) => {
    setdataToShow(item)
    setIsModalOpen(true);
    setIsUpdate(false)
  };



  return (
    <div className="transaction-info">
      <div className="c-f">
        <span>C/F</span>
        <span>${carryForward}</span>
      </div>
      <div className="summary">
        <div className="summary-item">
          <div className="summary-icon">
            <IncomeIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Income</p>
            <h3 className="amount positive">${totalIncome}</h3>
          </div>
        </div>
        <div className="summary-item">
          <div className="summary-icon-ex">
            <ExpenseIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Expenses</p>
            <h3 className="amount negative">${totalExpense}</h3>
          </div>
        </div>
        <div className="add-btn">
          <AddButton onClick={handleAddButtonClick} />
        </div>
      </div>
      <div className="transaction-history">
        <h4>Transaction History</h4>
        <div className="tab-row" id="tab-row">
          <div
            className='expense-tab'
            onClick={() => handleTabClick("Expense")}
          >
            Expenses
          </div>
          <div
            className='income-tab'
            onClick={() => handleTabClick("Income")}
          >
            Income
          </div>
        </div>
        {activeTab === "Expense" && expense.length === 0 && (
          <div className="no-transaction">No Transaction</div>
        )}
        {activeTab === "Income" && income.length === 0 && (
          <div className="no-transaction">No Transaction</div>
        )}
        {activeTab === "Expense" &&
          expense.map((item, index) => {
            return (
              <Transaction
                activeTab={activeTab}
                key={index}
                showIcon={true}
                showDetails={true}
                date={false}
                historyLog={false}
                item={item}
                handleAddButtonClick={handleAddButtonClick}
                setIsUpdate={setIsUpdate}
              />
            );
          })}
        {activeTab === "Income" &&
          income.map((item, index) => {
            return (
              <Transaction
                activeTab={activeTab}
                key={index}
                showIcon={true}
                showDetails={true}
                date={false}
                historyLog={false}
                item={item}
                handleAddButtonClick={handleAddButtonClick}
                setIsUpdate={setIsUpdate}
              />
            );
          })}
      </div>
      <AddTransactionModal
       dataToShow={dataToShow}
        isOpen={isModalOpen}
        isUpdate={isUpdate}
       setIsModalOpen={setIsModalOpen}

      />  
    </div>
  );
};

export default TransactionInfo;
