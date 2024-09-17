import React, { useEffect, useState } from "react";
import "./index.css";
import { ReactComponent as Cross } from "../../assets/svgs/cross.svg";

import { ReactComponent as Edit } from "../../assets/svgs/EditModal.svg";
import { ReactComponent as Delete } from "../../assets/svgs/DeleteModal.svg";
import AddTransactionModal from "../TransactionalModal";

const TransactionOpenPopup = ({
  isOpen,
  activeTab,
  date,
  historyLog,
  item,
  handleCloseModal,
  convertToTimeFormat,
  showDetails,
  handleDelete
}) => {
  console.log("ITEM",item);
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isUpdate, setIsUpdate] = useState(false);
  const [dataToShow, setdataToShow] = useState({});
  const[files,setFiles]=useState([])
  const handleAddButtonClick = () => {
    setdataToShow(item);
    setIsModalOpen(true);
    setIsUpdate(true);
  };
  useEffect(()=>{
    setFiles(item.fileInfos)
  },[item.id,item.fileInfos.length])
  const downloadFile = async (file) => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BASE_URL}/file/download/${file.fileUuid}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/octet-stream',
        },
      });
      if (!response.ok) {
        throw new Error('Failed to download file');
      }
  
      const blob = await response.blob(); // Convert the response to a blob
  
      // Extract the filename from content-disposition if available
      const contentDisposition = response.headers.get('content-disposition');
      let filename = file.filename;
  
      if (contentDisposition && contentDisposition.includes('filename=')) {
        filename = contentDisposition.split('filename=')[1].trim().replace(/['"]/g, '');
      }
  
      // Create a temporary anchor element for triggering download
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', file.filename); // Filename for download
      document.body.appendChild(link);
      link.click();
      link.parentNode.removeChild(link); // Clean up the DOM
      window.URL.revokeObjectURL(url); // Revoke the object URL
    } catch (error) {
      console.error('Error while downloading the file:', error);
    }
  };
  return (
    <div className={`modal-overlay ${isOpen ? "show" : ""}`}>
      <div
        className={`modal-content ${isOpen ? "slide-up" : ""}`}
        onClick={(e) => e.stopPropagation()}
      >
       <div style={{width:"100%" , display:"flex",justifyContent:"flex-end"}}>
       <Cross onClick={handleCloseModal} />
        </div>

        <div className="top-heading">
          <h2>Transaction History</h2>
          <div style={{display:"flex",gap:"5px"}}>
            <Edit onClick={handleAddButtonClick} />
            <Delete onClick={handleDelete} />
          </div>
        </div>
        <div className="transaction-item">
          <div className="transaction-icon">
            {activeTab?.toUpperCase()?.substring(0, 1)}
          </div>
          <div className="transaction-details">
            <strong>{item?.title}</strong>
            {historyLog && (
              <span style={{ color: "#666875" }}> &nbsp;{item?.message}</span>
            )}
            {date ? (
              <>
                <p
                  style={{
                    marginTop: "3px",
                    color: "#A6AEC1",
                    fontWeight: "200",
                  }}
                >
                  {item?.creationDate}
                </p>{" "}
              </>
            ) : (
              <>
                <p>{item?.party}</p>
              </>
            )}
          </div>
          {showDetails && (
            <div className="transaction-amt">
              <div className="transaction-amount positive">₹{item?.amount}</div>
              <div className="transaction-time">
                {convertToTimeFormat(item?.modificationDate)}
              </div>
            </div>
          )}
        </div>
        <div className="file-preview">
          {files?.map((file, index) => {
  let previewUrl;

  try {
    previewUrl = URL.createObjectURL(file);
  } catch (error) {
    console.error("Error creating object URL:", error);

    const fileExtension = file?.name?.split('.').pop().toLowerCase();

    switch (fileExtension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        previewUrl = 'https://via.placeholder.com/150?text=Image+Preview';
        break;
      case 'pdf':
        previewUrl = 'https://via.placeholder.com/150?text=PDF+Preview';
        break;
      case 'doc':
      case 'docx':
        previewUrl = 'https://via.placeholder.com/150?text=Word+Preview';
        break;
      case 'xls':
      case 'xlsx':
        previewUrl = 'https://via.placeholder.com/150?text=Excel+Preview';
        break;
      default:
        previewUrl = 'https://via.placeholder.com/150?text=File+Preview';
    }
  }

  return (
    <div key={index} className="file-item" onClick={()=>downloadFile(file)}>
      <img
        src={previewUrl}
        alt="file preview"
        className="file-preview-image"
      />
      <span className="file-name">{file?.name ?? file.filename}</span>
    </div>
  );
})}

          </div>
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

export default TransactionOpenPopup;
