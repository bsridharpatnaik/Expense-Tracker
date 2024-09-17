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
import { useGetDashboardTransactionDataQuery, useGetMonthsQuery } from "../../service/api";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import { useNavigate } from "react-router-dom";
import MonthlyInfo from "../../components/MonthlyInfo";
import { ReactComponent as IncomeIcon } from "../../assets/svgs/Download.svg";
import { ReactComponent as ExpenseIcon } from "../../assets/svgs/Upload.svg";
import SkeletonCard from "../../components/Skeleton";
import MonthlyInfoSkeleton from "../../components/Skeleton/SkeletonMonth";
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
  const { data, refetch,isFetching } = useGetDashboardTransactionDataQuery(formatDate(selectedDate),{
    skip:toggle==="M"
  });
  const { data:monthData, refetch:monthRefetch,isFetching:monthFetching } = useGetMonthsQuery({date:formatDate(selectedDate)},{
    skip:toggle==="D"
  });
  
  const handleToggle = (value) => {
    setToggle(value);
  };
  
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
    if(toggle==="D"){
    refetch()
    }else{
      monthRefetch()
    }
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
  const navigate=useNavigate()
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
        navigate("/documentation-vault")
        setShowMenu(false);
      },
    },
    {
      label: "History",
      onClick: () => {
        setShowMenu(false);
        navigate("/history")
        
      },
    },
    ...((user?.username && user?.username !== "anonymous") ? [{
      label: "Logout",
      onClick: () => {
        localStorage.clear();
        window.location.reload();
      }
    }] : [])
  ];


  useEffect(() => {
    if (data || monthData) {
      setDashboardData({
        transactionsByType: {
          EXPENSE: data?.transactionsByType?.EXPENSE,
          INCOME: data?.transactionsByType?.INCOME,
        },
        carryForward:toggle==="D"  ? data?.carryForward  : monthData?.carryForward ,
        totalIncome:toggle==="D" ?  data?.totalIncome : monthData?.totalIncome,
        totalExpense:toggle==="D" ?  data?.totalExpense : monthData?.totalExpense,
        balance:toggle==="D" ?  data?.balance : monthData?.balance,
        username: data?.username,
      });
      if(data?.username==="anonymous"){
        localStorage.clear()
      }
    }
  }, [data,monthData]);

  const exportToPDF = () => {
    const input = transactionRef.current;
  
    if (!input) {
      console.error("Invalid element: transactionRef is not attached to any DOM element");
      return;
    }
  
    html2canvas(input, { scale: 2 })
      .then((canvas) => {
        const imgData = canvas.toDataURL("image/png");
        const pdf = new jsPDF("p", "mm", "a4");
  
        const pdfWidth = pdf.internal.pageSize.getWidth();
        const pdfHeight = pdf.internal.pageSize.getHeight();
  
        const canvasWidth = canvas.width;
        const canvasHeight = canvas.height;
        const imgHeight = (canvasHeight * pdfWidth) / canvasWidth;
  
        let heightLeft = imgHeight;
        let position = 0;
  
        // Add the first page
        pdf.addImage(imgData, "PNG", 0, position, pdfWidth, imgHeight);
        heightLeft -= pdfHeight;
  
        while (heightLeft > 0) {
          position = heightLeft - imgHeight;
          pdf.addPage();
          pdf.addImage(imgData, "PNG", 0, position, pdfWidth, imgHeight);
          heightLeft -= pdfHeight;
        }
  
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
            <h2>₹{dashboardData?.balance ?? monthData?.balance}</h2>
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
      <div className="c-f">
        <span>C/F</span>
        <span>₹{dashboardData?.carryForward ?? monthData?.carryForward}</span>
      </div>
      <div className="summary">
        <div className="summary-item">
          <div className="summary-icon">
            <IncomeIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Income</p>
            <h3 className="amount positive">₹{dashboardData?.totalIncome ?? monthData?.totalIncome}</h3>
          </div>
        </div>
        <div className="summary-item">
          <div className="summary-icon-ex">
            <ExpenseIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Expenses</p>
            <h3 className="amount negative">₹{dashboardData?.totalExpense ?? monthData?.totalExpense}</h3>
          </div>
        </div>
      </div>
      {toggle === "D" && (
  <>
    {isFetching ? (
      <SkeletonCard /> // Render a skeleton for TransactionInfo while fetching
    ) : (
      <TransactionInfo
        transactionRef={transactionRef}
        expense={dashboardData.transactionsByType.EXPENSE}
        income={dashboardData.transactionsByType.INCOME}
      />
    )}
  </>
)}

{toggle === "M" && (
  <div style={{ padding: "10px", display: "flex", gap: "20px", flexDirection: "column" }}>
    {monthFetching ? (
      <>
        {[...Array(3)].map((_, index) => (
          <MonthlyInfoSkeleton key={index} />
        ))}
      </>
    ) : (
      monthData?.dailySummaries?.map((val, index) => (
        <MonthlyInfo
          key={index}
          val={val}
          handleToggle={handleToggle}
          handleDateChange={handleDateChange}
        />
      ))
    )}
  </div>
)}


    </div>
  );
}

export default BalanceCard;
