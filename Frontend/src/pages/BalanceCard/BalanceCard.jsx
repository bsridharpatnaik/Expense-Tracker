import React, { useEffect, useRef, useState } from "react";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import "./Balancecard.css";
import logo from "../../assets/png/evergreen.png";
import { ReactComponent as ThreeIcon } from "../../assets/svgs/three.svg";
import { ReactComponent as FrameIcon } from "../../assets/svgs/Frame2.svg";
import { ReactComponent as Icon } from "../../assets/svgs/Icon.svg";
import Menu from "../../components/Menu";
import TransactionInfo from "../../components/TransactionInfo";
import { addDays, subDays, addMonths, subMonths } from "date-fns";
import { useGetDashboardTransactionDataQuery } from "../../service/api";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";

function BalanceCard() {
  const [toggle, setToggle] = useState("D");
  const [dashboardData, setDashboardData] = useState({
    transactionsByType: {
      EXPENSE: [],
      INCOME: [],
    },
    carryForward: 0,
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    username: "anonymous",
  });
  const transactionRef = useRef(null); 

  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showMenu, setShowMenu] = useState(false);
  const { data, refetch } = useGetDashboardTransactionDataQuery(formatDate(selectedDate));
  const handleToggle = (value) => {
    setToggle(value);
  };
  console.log("data",data);
  function formatDate(dateString) {
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    if(toggle === "M") return `${year}-${month}`;
    return `${year}-${month}-${day}`;
  }

  const handleDateChange = async(date) => {
    // const formattedDate = await formatDate(date)
    setSelectedDate(date);
    // console.log(formattedDate,"formattedDate")
    refetch()
  };

  const handlePrevDate = () => {
    if (toggle === "D") {
      setSelectedDate((prevDate) => subDays(prevDate, 1));
    } else if (toggle === "M") {
      setSelectedDate((prevDate) => subMonths(prevDate, 1));
    }
  };

  const handleNextDate = () => {
    if (toggle === "D") {
      setSelectedDate((prevDate) => addDays(prevDate, 1));
    } else if (toggle === "M") {
      setSelectedDate((prevDate) => addMonths(prevDate, 1));
    }
  };

  const user = JSON.parse(localStorage.getItem("user"));

  const menuRef = useRef(null);
  const items = [
    {
      label: "Export to PDF",
      onClick: () =>{
        setShowMenu(false);
        exportToPDF()
      }
    },
    {
      label: "Documentation Vault",
      onClick: () => {
        setShowMenu(false);
      },
    },
    {
      label: "History",
      onClick: () => {
        setShowMenu(false);
      },
    },
    ...(user?.username !== "anonymous" ? [{
      label: "Logout",
      onClick: () => {
        localStorage.clear();
        window.location.reload();
      }
    }] : [])
  ];


  useEffect(() => {
    if (data) {
      setDashboardData({
        transactionsByType: {
          EXPENSE: data?.transactionsByType?.EXPENSE,
          INCOME: data?.transactionsByType?.INCOME,
        },
        carryForward: data.carryForward,
        totalIncome: data.totalIncome,
        totalExpense: data.totalExpense,
        balance: data.balance,
        username: data.username,
      });
      if(data?.username==="anonymous"){
        localStorage.clear()
      }
    }
  }, [data]);
  const exportToPDF = () => {
    console.log("Clicked");
    const input = transactionRef.current;
    html2canvas(input, { scale: 2 }) // Increase the scale for better quality
      .then((canvas) => {
        const imgData = canvas.toDataURL("image/png");
        const pdf = new jsPDF("p", "mm", "a4");
        const imgProps = pdf.getImageProperties(imgData);
        const pdfWidth = pdf.internal.pageSize.getWidth();
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
        pdf.addImage(imgData, "PNG", 0, 0, pdfWidth, pdfHeight);
        pdf.save("transactions.pdf");
      })
      .catch((err) => {
        console.error("Failed to generate PDF", err);
      });
  };
  
  return (
    <div>
      <div className="balance-card">
        <div className="header">
          <div style={{ display: "flex", gap: "5px" }}>
            <img src={logo} alt="Logo" className="logo" />
            <p style={{ fontSize: "14px", color: "#fff" }}>
              Hi, {data?.username!=="anonymous" ? data?.username : ""}
            </p>
          </div>
          <div className="user-info">
            <div className="icons">
              <Icon className="search-icon" />
              {data?.username==="anonymous" && (
                <a href="/login">
                  <ThreeIcon className="menu-icon" />
                </a>
              )}
              <div className="dots-container">
                <FrameIcon
                  className="frame-icon"
                  onClick={() => setShowMenu(!showMenu)}
                  ref={menuRef}
                />
                {showMenu && <Menu items={items}  />}
              </div>
            </div>
          </div>
        </div>
        <div className="balance-info">
          <div>
            <p>Total Balance</p>
            <h2>₹{dashboardData.balance}</h2>
          </div>
          <div className="toggle-group">
            <div
              className={`toggle-btn ${toggle === "D" ? "selected" : ""}`}
              onClick={() => handleToggle("D")}
            >
              D
            </div>
            <div
              className={`toggle-btn ${toggle === "M" ? "selected" : ""}`}
              onClick={() => handleToggle("M")}
            >
              M
            </div>
          </div>
        </div>
        <div className="date-selector">
          <button className="prev-date" onClick={handlePrevDate}>
            {"<"}
          </button>
          <div className="date-display">
            {toggle === "D" ? (
              <DatePicker
                selected={selectedDate}
                onChange={handleDateChange}
                dateFormat="d, MMM yy EEE"
              />
            ) : (
              <DatePicker
                selected={selectedDate}
                onChange={handleDateChange}
                dateFormat="MMM yy"
                showMonthYearPicker
              />
            )}
          </div>
          <button className="next-date" onClick={handleNextDate}>
            {">"}
          </button>
        </div>
      </div>
      <div ref={transactionRef}> 
      <TransactionInfo
        totalIncome={dashboardData.totalIncome}
        totalExpense={dashboardData.totalExpense}
        carryForward={dashboardData.carryForward}
        expense={dashboardData.transactionsByType.EXPENSE}
        income={dashboardData.transactionsByType.INCOME}
      />
      </div>
    </div>
  );
}

export default BalanceCard;
