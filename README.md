# Expense Tracker Application

## Overview

The Expense/Income Tracker and Document Vault Application is a **Progressive Web App (PWA)** designed to help users manage and track their daily and monthly expenses. This application supports both anonymous users and logged-in users, with varying data visibility based on user authentication.
This can be used to track business owners their cash expenses without storing any data on device.

## Key Features

### 1. Dashboard
- **Displays a summary of income, expenses, and balance.**
- **Users can switch between daily and monthly views.**
- **Allows the addition, update, and deletion of transactions.**
- **Supports file attachments for transactions.**
- **Export the dashboard data to PDF.**
- **Access to document vault and transaction history from the dashboard.**

### 2. Transactions
- **Users can create, update, and delete transactions.**
- **Transaction types include Income and Expense.**
- **File attachments can be added to transactions for better record-keeping.**

### 3. File Handling
- **Upload and manage files associated with transactions.**
- **Supports viewing and deleting files directly from the transaction interface.**

### 4. Document Vault
- **A secure vault for storing and managing documents.**
- **Users can create folders, upload files, and organize them within the vault.**
- **Supports nested folders and document management within an organization.**

### 5. Organization Management
- **Multi-tenant system where users are grouped by organization.**
- **Each organization has its own set of transactions and document vault.**
- **Anonymous users interact with a default "anonymous" organization.**

### 6. User Authentication
- **JWT-based authentication with support for both logged-in and anonymous sessions.**
- **Login and logout functionality directly accessible from the dashboard.**
- **Secure handling of user sessions and API interactions.**

### 7. History Tracking
- **A read-only page that displays a history of recent updates to transactions.**
- **Allows users to keep track of changes and modifications made over time.**

## Installation
The application is built as a PWA and is installable on mobile devices. It features a splash screen on load and automatically attempts to authenticate users using a saved JWT token.

## Technologies Used
- **Spring Boot** for the backend.
- **JWT** for authentication.
- **Java 8** as the primary programming language.
- **React** for PWA design with a mobile-first experience.

## Future Enhancements
- **Desktop view support.**
- **Advanced reporting and analytics.**
- **Integration with third-party financial tools.**
