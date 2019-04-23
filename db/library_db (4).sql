-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 23, 2019 at 07:07 PM
-- Server version: 10.1.38-MariaDB
-- PHP Version: 7.3.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `library_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_due_list` ()  NO SQL
SELECT I.issue_id, M.email, B.isbn, B.title
FROM book_issue_log I INNER JOIN member M on I.member = M.username INNER JOIN book B ON I.book_isbn = B.isbn
WHERE DATEDIFF(CURRENT_DATE, I.due_date) >= 0 AND DATEDIFF(CURRENT_DATE, I.due_date) % 5 = 0 AND (I.last_reminded IS NULL OR DATEDIFF(I.last_reminded, CURRENT_DATE) <> 0)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `book`
--

CREATE TABLE `book` (
  `isbn` char(13) NOT NULL,
  `title` varchar(80) NOT NULL,
  `author` varchar(80) NOT NULL,
  `category` varchar(80) NOT NULL,
  `price` int(4) UNSIGNED NOT NULL,
  `copies` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `book`
--

INSERT INTO `book` (`isbn`, `title`, `author`, `category`, `price`, `copies`) VALUES
('0000545010225', 'Harry Potter and the Deathly Hallows', 'J. K. Rowling', 'Fiction', 550, 30),
('0000553103547', 'A Game of Thrones', 'George R. R. Martin', 'Fiction', 500, 10),
('0000553106635', 'A Storm of Swords', 'George R. R. Martin', 'Fiction', 550, 15),
('0000553108034', 'A Clash of Kings', 'George R. R. Martin', 'Fiction', 500, 9),
('0000553801503', 'A Feast for Crows', 'George R. R. Martin', 'Fiction', 600, 20),
('0000747532699', 'Harry Potter and the Philosopher\'s Stone', 'J. K. Rowling', 'Fiction', 300, 12),
('0000747538492', 'Harry Potter and the Chamber of Secrets', 'J. K. Rowling', 'Fiction', 300, 10),
('0000747542155', 'Harry Potter and the Prisoner of Azkaban', 'J. K. Rowling', 'Fiction', 350, 16),
('0000747546240', 'Harry Potter and the Goblet of Fire', 'J. K. Rowling', 'Fiction', 400, 15),
('0000747551006', 'Harry Potter and the Order of the Phoenix', 'J. K. Rowling', 'Fiction', 400, 20),
('0000747581088', 'Harry Potter and the Half-Blood Prince', 'J. K. Rowling', 'Fiction', 500, 25),
('9780066620992', 'Good to Great', 'Jim Collins', 'Non-fiction', 300, 10),
('9780241257555', 'The Pigeon Tunnel', 'John le CarrÃ©', 'Non-fiction', 200, 25),
('9780439023511', 'Mockingjay', 'Suzanne Collins', 'Fiction', 500, 20),
('9780439023528', 'The Hunger Games', 'Suzanne Collins', 'Fiction', 400, 10),
('9780545227247', 'Catching Fire', 'Suzanne Collins', 'Fiction', 400, 14),
('9780553801477', 'A Dance with Dragons', 'George R. R. Martin', 'Fiction', 600, 30),
('9780967752808', 'Sandbox Wisdom', 'Tom Asacker', 'Non-fiction', 250, 5),
('9781501141515', 'Born to Run', 'Bruce Springsteen', 'Non-fiction', 250, 20),
('9788183331630', 'Let Us C', 'Yashavant Kanetkar', 'Education', 200, 22),
('9789350776667', 'Computer Graphics and Virtual Reality', 'Sanjesh S. Pawale', 'Education', 100, 30),
('9789350776773', 'Microcontroller and Embedded Systems', 'Harish G. Narula', 'Education', 80, 15),
('9789350777077', 'Advanced Database Management Systems', 'Mahesh Mali', 'Education', 60, 29),
('9789350777121', 'Operating Systems', 'Rajesh Kadu', 'Education', 50, 24),
('9789351194545', 'Open Source Technologies', 'Dayanand Ambawade', 'Education', 100, 20),
('9789381626719', 'Stay Hungry Stay Foolish', 'Rashmi Bansal', 'Non-fiction', 100, 5);

-- --------------------------------------------------------

--
-- Table structure for table `book_issue_log`
--

CREATE TABLE `book_issue_log` (
  `issue_id` int(11) NOT NULL,
  `member` varchar(20) NOT NULL,
  `book_isbn` varchar(13) NOT NULL,
  `due_date` date NOT NULL,
  `last_reminded` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `book_issue_log`
--

INSERT INTO `book_issue_log` (`issue_id`, `member`, `book_isbn`, `due_date`, `last_reminded`) VALUES
(1, 'raj32', '9789350777077', '2018-10-17', NULL),
(2, 'raj32', '9780545227247', '2018-10-17', NULL),
(3, 'Ayush', '0000553108034', '2019-04-30', NULL);

--
-- Triggers `book_issue_log`
--
DELIMITER $$
CREATE TRIGGER `issue_book` BEFORE INSERT ON `book_issue_log` FOR EACH ROW BEGIN
	SET NEW.due_date = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    UPDATE member SET balance = balance - (SELECT price FROM book WHERE isbn = NEW.book_isbn) WHERE username = NEW.member;
    UPDATE book SET copies = copies - 1 WHERE isbn = NEW.book_isbn;
    DELETE FROM pending_book_requests WHERE member = NEW.member AND book_isbn = NEW.book_isbn;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `return_book` BEFORE DELETE ON `book_issue_log` FOR EACH ROW BEGIN
    UPDATE member SET balance = balance + (SELECT price FROM book WHERE isbn = OLD.book_isbn) WHERE username = OLD.member;
    UPDATE book SET copies = copies + 1 WHERE isbn = OLD.book_isbn;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `librarian`
--

CREATE TABLE `librarian` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `librarian`
--

INSERT INTO `librarian` (`id`, `username`, `password`) VALUES
(1, 'harshit', 'harshit786@');

-- --------------------------------------------------------

--
-- Table structure for table `member`
--

CREATE TABLE `member` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `email` varchar(80) NOT NULL,
  `balance` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `member`
--

INSERT INTO `member` (`id`, `username`, `password`, `name`, `email`, `balance`) VALUES
(1, 'lokesh9', '12345', 'lokesh ', 'lokesh@gmail.com', 1000),
(2, 'vaibhav32', 'goel123', 'vaibhav', 'vaibhav@gmail.com', 540),
(3, 'harshit4_ff7', 'chirgania', 'harshit ', 'harshit@gmial.com', 1000),
(4, 'Ayush', '3da541559918a808c2402bba5012f6c60b27661c', 'Ayush Sri', 'ayush@admin.com', 122956);

--
-- Triggers `member`
--
DELIMITER $$
CREATE TRIGGER `add_member` AFTER INSERT ON `member` FOR EACH ROW DELETE FROM pending_registrations WHERE username = NEW.username
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `remove_member` AFTER DELETE ON `member` FOR EACH ROW DELETE FROM pending_book_requests WHERE member = OLD.username
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pending_book_requests`
--

CREATE TABLE `pending_book_requests` (
  `request_id` int(11) NOT NULL,
  `member` varchar(20) NOT NULL,
  `book_isbn` varchar(13) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pending_book_requests`
--

INSERT INTO `pending_book_requests` (`request_id`, `member`, `book_isbn`, `time`) VALUES
(1, 'khushi', '9780553801477', '2018-10-10 13:53:27'),
(2, 'meenu', '0000545010225', '2018-10-10 12:53:59'),
(5, 'ayushi', '0000553103547', '2018-10-10 12:59:45');

-- --------------------------------------------------------

--
-- Table structure for table `pending_registrations`
--

CREATE TABLE `pending_registrations` (
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `email` varchar(80) NOT NULL,
  `balance` int(4) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pending_registrations`
--

INSERT INTO `pending_registrations` (`username`, `password`, `name`, `email`, `balance`, `time`) VALUES
('asf', '3da541559918a808c2402bba5012f6c60b27661c', 'asdasd asdasd', 'asdasd@sfsd.sdfsd', 4544, '2019-04-23 16:38:00'),
('harshit ', '339a80e038d2185159d9309c375f63f45d200d19', 'harshit chirgania', 'harshit444@gmail.com', 500, '2019-04-23 16:13:20'),
('jjjkkjjk', '3da541559918a808c2402bba5012f6c60b27661c', 'jhbh jhbjhbjh', 'hbhb@vvjvj.hbjh', 2656546, '2019-04-23 16:36:22'),
('jjnvkj', '3da541559918a808c2402bba5012f6c60b27661c', 'vodnf dfjnsdfn', 'djslkf@jdkvjlk.jidff', 1234, '2019-04-23 16:44:26'),
('pranshu', '339a80e038d2185159d9309c375f63f45d200d19', 'pranshu chirgania', 'pranshu444@gmail.com', 1000, '2019-04-23 16:16:26'),
('pranshu123', '81fe8bfe87576c3ecb22426f8e57847382917acf', ' chirgania', 'pranshu123@gmail.com', 5000, '2019-04-23 16:19:07'),
('sdsdfsd', '3da541559918a808c2402bba5012f6c60b27661c', 'Asd Sdf', 'sdsf123@gmail.com', 100000, '2019-04-23 16:28:22'),
('test', '786@123', 'Test', 'test@test.com', 500, '2018-10-11 13:01:13'),
('test2', 'fuck@123', 'Test 2', 'test2@test2.com', 800, '2018-10-11 13:03:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `book`
--
ALTER TABLE `book`
  ADD PRIMARY KEY (`isbn`);

--
-- Indexes for table `book_issue_log`
--
ALTER TABLE `book_issue_log`
  ADD PRIMARY KEY (`issue_id`);

--
-- Indexes for table `librarian`
--
ALTER TABLE `librarian`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `pending_book_requests`
--
ALTER TABLE `pending_book_requests`
  ADD PRIMARY KEY (`request_id`);

--
-- Indexes for table `pending_registrations`
--
ALTER TABLE `pending_registrations`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `book_issue_log`
--
ALTER TABLE `book_issue_log`
  MODIFY `issue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `librarian`
--
ALTER TABLE `librarian`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `member`
--
ALTER TABLE `member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `pending_book_requests`
--
ALTER TABLE `pending_book_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
