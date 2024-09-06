import React from 'react';
import './index.css';

const Menu = ({ items }) => {

  return (
    <div className="menu-container">
      <ul className="menu-list">
        {items.map((item, index) => (
          <li key={index} className="menu-item" onClick={item.onClick}>
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Menu;
