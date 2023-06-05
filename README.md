# LibraryDatabaseManagement
# Masters Coursework
Project Description: Library Database System
<br>
<ul>
<li>Created a comprehensive database system for a library, incorporating member information, library catalogue, loan history, and overdue fine repayment data.</li>
<li>Designed tables with primary and foreign keys to maintain referential integrity and utilized check constraints for data consistency.</li>
<li>Implemented functionalities like data insertion, updates, and querying through procedures, triggers, and views, while ensuring automation of certain library operations.</li>
<li>Ensured data security with password hashing, salting, schemas, and roles, and implemented regular data backups for disaster recovery.</li>
  </ul>

# Contents

[TASK 1 3](#_Toc133054690)

[Introduction 3](#_Toc133054691)

[Part 1 3](#_Toc133054692)

[These are the datatypes used for the columns in the tables: 5](#_Toc133054693)

[Additional Assumptions 8](#_Toc133054694)

[Part 2 8](#_Toc133054695)

[2A – Search the catalogue for matching character strings by title 8](#_Toc133054696)

[2B - Return a full list of all items currently on loan which have a due date of less than five days from the current date 8](#_Toc133054697)

[2C - Insert a new member into the database 9](#_Toc133054698)

[2D - Update the details for an existing member 9](#_Toc133054699)

[Part 3 10](#_Toc133054700)

[View for the loan history, previous and current loans, item borrowed, borrowed date, due date and associated fines 10](#_Toc133054701)

[Part 4 11](#_Toc133054702)

[Trigger updates the current status of an item to 'Available' when the book is returned. 11](#_Toc133054703)

[Part 5 11](#_Toc133054704)

[Function to identify the total number of loans made on a specified date. 11](#_Toc133054705)

[Part 6 12](#_Toc133054706)

[Data Test insertions 12](#_Toc133054707)

[Inserting Member data into the database using the AddNewUser procedure 12](#_Toc133054708)

[Inserting item data into the Catalogue table 12](#_Toc133054709)

[View Loan 13](#_Toc133054710)

[View Loan History 14](#_Toc133054711)

[Borrow Item 14](#_Toc133054712)

[Available Status trigger 15](#_Toc133054713)

[Part 7 - Additional Functions, Queries, Views and Triggers 16](#_Toc133054714)

[Borrow Item 16](#_Toc133054715)

[Return Item 17](#_Toc133054716)

[Fine Trigger 18](#_Toc133054717)

[Pay Fine 19](#_Toc133054718)

[View All User Details 19](#_Toc133054719)

[Function to Check Item Status 20](#_Toc133054720)

[Additional Recommendations 20](#_Toc133054721)

[Data Integrity and Concurrency 20](#_Toc133054722)

[Database Security 20](#_Toc133054723)

[Security Recommendations 21](#_Toc133054724)

[Full Database Backup 22](#_Toc133054725)

[Restore Database 25](#_Toc133054726)

[Selecting a Maintenance plan 27](#_Toc133054727)

[Conclusion 30](#_Toc133054728)

# TASK 1

## Introduction

The first task required me, as a database developer consultant, to design a database system for a library to store information on the members of the library, items in the library's catalogue which range from books, dvds, journals to other medias, loan history of the items and overdue fine repayments. This report highlights the steps that I took to create the database and the entities, T-SQL codes for the triggers, views and other database objects, queries into the database as well as database security recommendations and advice.

## Part 1

In order to avoid insertion and deletion anomalies, I normalized the database in 3NF (Third Normal Form). Normalization is arranging the data in a database and relationship between the tables to improve the data integrity.

1. The first step I carried out was to map out the diagram for the tables and design the diagrams on draw.io using the rough draft that I sketched out in figure 1. The

![](RackMultipart20230605-1-aryxca_html_83653b4bba1afb41.jpg)

_Figure 1_

![](RackMultipart20230605-1-aryxca_html_bacb7a292a582ec2.png)

_Figure 2_

1. The next step was to open Microsoft Server and connect to the SQL server and create the library database using the T-SQL code below. The database can be seen in figure 3 below

createdatabase LibraryManagementSystem;

![](RackMultipart20230605-1-aryxca_html_937c527f753b7967.png)

_Figure 3_

1. To carry this out, I created 7 tables in the database namely;Addresses, UserLogins, Users, CatalogueOfItems, Loans, Fines and a linker table called FineRepayments. Following the library's specifications, I chose the datatypes of each table and attribute based on the type of data that it would hold.

### These are the datatypes used for the columns in the tables:

- Nvarchar(n) – I used this for text-based data entry and varied the width of the character string
- Binary(n) – I used this for the password hash column to store the salted password in a binary string
- Int – I used this for all the primary and foreign key columns as it allowed numbers -2,147,483,648 to 2,147,483,647
- Date – I used this to store all date entries in the database
- Numeric – I used this for the ISBN column as the numbers exceeded the maximum allowance for int data type
- Decimal – I used this for the money columns as it allows for fixed precision and scale numbers.

1. I started with the tables with the least amount of dependencies and used the code below to create Addresses

createtable Addresses(

Address\_id intidentity(1,1)notnullprimarykey,

Street\_address nvarchar(150)notnull,

City nvarchar(90)notnull,

Statenvarchar(90)notnull,

)

1. I created the table to hold the members login data and email with the code below

createtable UserLogins(

Login\_id intidentity(1,1)notnullprimarykey,

Username nvarchar(50)notnull,

Password\_Hash binary(64)notnull,

Salt uniqueidentifier

)

1. I created the table that holds the members data complete with the constraints and foreign keys.

createtable Users(

User\_idintidentity(1,1)notnullprimarykey,

First\_Name nvarchar(50)notnull,

Last\_Name nvarchar(50)notnull,

Date\_Of\_Birth datenotnull,

Email nvarchar(50)uniquenull,

Telephone intnull,

Address\_ID int,

User\_Login\_ID int,

DateJoined datenotnull,

DateLeft datenull,

foreignkey (Address\_ID)references Addresses(Address\_id),

foreignkey (User\_Login\_ID)references UserLogins(Login\_id),

constraint Email\_Check check (Email like'%\_@\_%.\_%')

)

1. I created the CatalogueofItems table to hold the items data in it

createtable CatalogueOfItems(

Item\_id intidentity(1,1)notnullprimarykey,

Item\_title nvarchar(250)notnull,

Item\_type nvarchar(20)notnull,

Author\_Name nvarchar(250)null,

Year\_Published datenull,

Date\_added datenotnull,

Current\_status nvarchar(25)notnull,

Date\_removed datenull,

ISBN numeric(18,0)null,

constraint Item\_Type\_Check check (Item\_type IN('Book','Journal','DVD','Other Media')),

constraint Status\_Check check (Current\_status IN('On Loan','Overdue','Available','Lost/Removed'))

)

1. The loans table to hold the data when an item is loaned out from the library and it is dependent on the Catalogue table

createtable Loans(

Loan\_id intidentity(1,1)notnullprimarykey,

User\_IDint,

Item\_ID int,

Date\_Loaned datenotnull,

Date\_Due datenotnull,

Date\_Returned datenull,

foreignkey (User\_ID)references Users(User\_id),

foreignkey (Item\_ID)references CatalogueOfItems(Item\_id)

)

1. The Fines table holds the fines data

createtable Fines(

Fine\_id intidentity(1,1)notnullprimarykey,

User\_IDint,

Total\_Fine\_Owed decimal(7,2)notnull,

Total\_Fine\_Paid decimal(7,2)notnull,

Total\_Fine\_Remaining decimal(7,2)notnull,

foreignkey (User\_ID)references Users(User\_id)

)

1. The FineRepayment table is a table to hold the data and keeps track of the repayments, how and when they were paid

createtable FineRepayments(

Repayment\_id intidentity(1,1)notnullprimarykey,

Fine\_id int,

Date\_Paid date,

Amount\_Paid decimal(7,2)notnull,

Payment\_Method nvarchar(10)notnull,

foreignkey (Fine\_id)references Fines(Fine\_id),

constraint Payment\_Check check (Payment\_Method IN('cash','card'))

)

The diagram below is a screenshot that shows all the tables created in the database

![](RackMultipart20230605-1-aryxca_html_95195b18d39d4bf7.png)

_Figure 4_

The diagram below is a screenshot that depicts the database diagram from the sql database

![](RackMultipart20230605-1-aryxca_html_9643291d73db2971.png)

_Figure 5_

### Additional Assumptions

- I assumed that in the items being added to the library, for other items that were not books, the Year of Publication was not needed and as such left it as null

## Part 2

### 2A – Search the catalogue for matching character strings by title

I created a procedure called SearchForTitle that allowed the title of an item to be searched using select and where condition.

createprocedure SearchForTitle

@char\_string nvarchar(250)

as

begin

select\*

from CatalogueOfItems

where Item\_title like'%'+ @char\_string +'%'

orderby Year\_Published desc

end

It is executed by:

exec SearchForTitle'The Secret History'

And the result is:

![](RackMultipart20230605-1-aryxca_html_735d13d71aa85810.png)

_Figure 6_

### 2B - Return a full list of all items currently on loan which have a due date of less than five days from the current date

Created a procedure to return all the items on loan less than five days. This procedure works by getting the difference between current day and the loan date and checking if it's less than five.

createprocedure ItemsDue

as

begin

select\*

from Loans

innerjoin CatalogueOfItems Cat on Loans.Item\_ID = Cat.Item\_id

wheredatediff(day,getdate(), Loans.Date\_Due)\< 5 and Loans.Date\_Returned isnull

end

The procedure can be executed like:

exec ItemsDue'The Secret History'

### 2C - Insert a new member into the database

This procedure adds a user to the database using the information given to the system. The code written for the procedure is given below.

createprocedure AddNewUser

@first\_name nvarchar(50),

@last\_name nvarchar(50),

@date\_of\_birth date,

@email nvarchar(50),

@telephone int,

@street\_address nvarchar(150),

@city nvarchar(90),

@state nvarchar(90),

@username nvarchar(50),

@password nvarchar(50)

as

begin

declare @address\_id int

insertinto Addresses(Street\_address, City,State)

values (@street\_address, @city, @state)

set @address\_id =scope\_identity()

declare @login\_id int

declare @salt uniqueidentifier=newid()

insertinto UserLogins(Username, Password\_Hash, Salt)

values (@username,hashbytes('SHA2\_512',@password+cast(@salt asnvarchar(36))), @salt)

set @login\_id =scope\_identity()

insertinto Users(First\_Name, Last\_Name, Date\_Of\_Birth, Email, Telephone, Address\_ID, User\_Login\_ID, DateJoined)

values (@first\_name, @last\_name, @date\_of\_birth, @email, @telephone, @address\_id, @login\_id,getdate())

end

### 2D - Update the details for an existing member

This procedure gets a hold of the user's information by using the user's id in the where condition statement.

--update user

createprocedure UpdateUser

@User\_id int,

@First\_Name nvarchar(50)=null,

@Last\_Name nvarchar(50)=null,

@Date\_Of\_Birth date=null,

@Email nvarchar(50)=null,

@Telephone int=null,

@street\_address nvarchar(150)=null,

@city nvarchar(90)=null,

@state nvarchar(90)=null,

@username nvarchar(50)=null,

@password nvarchar(50)=null,

@DateJoined date=null,

@DateLeft date=null

as

begin

declare @salt uniqueidentifier=newid()

update Users

set First\_Name =isnull(@First\_Name,First\_Name),

Last\_Name =isnull(@Last\_Name,Last\_Name),

Date\_Of\_Birth =isnull(@Date\_Of\_Birth,Date\_Of\_Birth),

Email =isnull(@Email,Email),

Telephone =isnull(@Telephone,Telephone),

DateJoined =isnull(@DateJoined,DateJoined),

DateLeft =isnull(@DateLeft,DateLeft)

whereUser\_id= @User\_id;

update Addresses

set Street\_address =isnull(@street\_address,Street\_address),

City =isnull(@city,City),

State=isnull(@state,State)

where Address\_id =(select Address\_ID from Users whereUser\_id= @User\_Id)

update UserLogins

set Username =isnull(@username,Username),

Password\_Hash =isnull(hashbytes('SHA2\_512',@password+cast(@salt asnvarchar(36))),Password\_Hash)

where Login\_id =(select User\_Login\_ID from Users whereUser\_id= @User\_Id)

end

## Part 3

### View for the loan history, previous and current loans, item borrowed, borrowed date, due date and associated fines

I created a view that allows the library view the loan history, showing all previous and current loans, and including details of the item borrowed, borrowed date, due date and any associated fines for each loan. This view joined all four tables: Loans, Users, CatalogueOfItems, and Fines using join and left join so that all the loans are included even if there are no fines for the loans.

/\*view loan history showing all previous and current loans and including details of the item borrowed, borrowed date,

due date and any associated fines for each loan\*/

use LibraryManagementSystem

go

createview ViewLibraryLoanHistory

as

select

Loans.Loan\_id,

Users.First\_Name,

Users.Last\_Name,

CatalogueOfItems.Item\_title,

CatalogueOfItems.Item\_type,

Loans.Date\_Loaned,

Loans.Date\_Due,

Loans.Date\_Returned,

Fines.Total\_Fine\_Owed,

Fines.Total\_Fine\_Paid,

Fines.Total\_Fine\_Remaining

from

Loans

join Users on Loans.User\_ID= Users.User\_id

join CatalogueOfItems on Loans.Item\_ID = CatalogueOfItems.Item\_id

leftjoin Fines on Loans.User\_ID= Fines.User\_ID;

## Part 4

### Trigger updates the current status of an item to 'Available' when the book is returned.

The trigger automatically engages after an update into the Loans table and it uses the if statement to check the date\_returned column and if there has been an insert, it will begin updating the current status column in the library's catalogue

--update status when item is returned

createtrigger update\_status

on Loans

afterupdate

as

begin

ifupdate(Date\_Returned)

begin

update CatalogueOfItems

set Current\_status ='Available'

from CatalogueOfItems

join returned on CatalogueOfItems.Item\_id = returned.Item\_ID

where returned.Date\_Returned ISNOTNULL

and CatalogueOfItems.Current\_status !='Available'

end

end

## Part 5

### Function to identify the total number of loans made on a specified date.

I created this scalar function that takes the date as a parameter. The date is used as a condition and the function returns a singular value which is the total number of loans made on that day

--get total loans on specific date

createfunction LoanOnDate(@date date)

returnsint

as

begin

declare @loanCount int

select @loanCount =count(\*)

from Loans

where Date\_Loaned = @date

return @loanCount

end

## Part 6

### Data Test insertions

### Inserting Member data into the database using the AddNewUser procedure

I created sample data and used my stored procedures to insert the data into the database

exec AddNewUser'Jay','Cole','1990-01-27','jaycole@gmail.com',null,'19 Hollywood Boulevard','Los Angeles',

'California','jcole','jaydacoolest'

go

exec AddNewUser'Kene','James','1999-11-20','kene@yahoo.com', 101920,'5 Tokunbo Ave','Victoria Island',

'Lagos','kene','kjames1999'

go

exec AddNewUser'Milesh','Doy','1998-04-30','doy@gmail.com', 708908,'14 John Lester','Salford',

'Greater Manchester','milesh','doy123doy456doy'

go

exec AddNewUser'Eminem','Marshall','1890-10-10','eminem@slimshady.com',null,'Saint John','Westminister',

'London','eminem','fastestrap109'

go

This is what the table looks like in the figure below using a select query on Users table

![](RackMultipart20230605-1-aryxca_html_bd245b16d45fc69a.png)

_Figure 7_

### Inserting item data into the Catalogue table

exec AddToLibrary'The Secret History','Book','Donna Tart','2021-07-16','Available', 33442059;

go

exec AddToLibrary'8th Confession','Book','James Patterson','2015-03-21','On Loan', 780316761;

go

exec AddToLibrary'Lion King','DVD',null,'1999-04-19','Available', 921019398;

go

exec AddToLibrary'Poltergeist','Journal','J.S. Anyang','2001-05-26','Overdue', 31694328;

go

This is a select query on the library's catalogue below

![](RackMultipart20230605-1-aryxca_html_690f5b2380cd9cbc.png)

_Figure 8_

### Update User

This is the code used to execute the update user stored procedure

execLibrary.UpdateUser@user\_id=1, @Telephone= 90480334

![](RackMultipart20230605-1-aryxca_html_fbc7b02923bbb84c.png)

### View Loan

This query is used on the Loans table to see the information in it

![](RackMultipart20230605-1-aryxca_html_af5d444a47d052b7.png)

_Figure 9_

### View Loan History

This query is from the Loan History View. All dates are present as well as all fine information

![](RackMultipart20230605-1-aryxca_html_971850ce8dd2590c.png)

_Figure 10_

### Borrow Item

exec [Library].[BorrowItem]'Kene','James','Lion King','2023-05-01'

![](RackMultipart20230605-1-aryxca_html_db0a0480638caebc.png)

### Available Status trigger

This query (check image below for before and after results) allowed me to update the return date of a book and triggered the status check to display available

select\*fromLibrary.Loans

updateLibrary.Loans

SET Date\_Returned =getdate()

WHERE Loan\_id = 5;

select\*fromlibrary.CatalogueOfItems

![](RackMultipart20230605-1-aryxca_html_7ff374c4946ba973.png)

## Part 7 - Additional Functions, Queries, Views and Triggers

### Borrow Item

This procedure that I created takes a user's first name and last name, title of the book to be borrowed and date the book should be returned and checks the user id if the user's first name and last name exist in the user table and also checks if the book is in the catalogue of items and status is available. If all the conditions are met, the due date of the book in the loan table is updated and the status of the book is updated to 'on loan'. It also changes the date that the book was removed from the Catalogue of Items Table

createprocedure BorrowItem

@FirstName nvarchar(50),

@LastName nvarchar(50),

@Title nvarchar(250),

@ReturnDate date

as

begin

setnocounton;

-- Check if user exists

declare @UserID int

select @UserID =User\_idfrom Users where First\_Name = @FirstName and Last\_Name = @LastName

if @UserID isnull

begin

raiserror('User not found.', 16, 1)

return

end

-- Check if item is available

declare @ItemID int

select @ItemID = Item\_id from CatalogueOfItems where Item\_title = @Title and Current\_status ='Available'

if @ItemID isnull

begin

raiserror('Item not available.', 16, 1)

return

end

-- Update Loan table

insertinto Loans(User\_ID, Item\_ID, Date\_Loaned, Date\_Due)

values (@UserID, @ItemID,getdate(), @ReturnDate)

-- Update CatalogueOfItems table

update CatalogueOfItems set Current\_status ='On Loan'where Item\_id = @ItemID

update CatalogueOfItems set Date\_removed =getdate()where Item\_id = @ItemID

print'Item borrowed successfully.'

end

### Return Item

I created this procedure to easily return an item to the library. It takes the loan id as a parameter and it updates the status of the item, updates the return date. It also calculates the fine if the item was returned late (ie past it due date) and if there was no existing fine, it would create one

createprocedure ReturnItem

@LoanId int

as

begin

setnocounton;

declare @ItemId int;

declare @UserId int;

declare @DateDue date;

declare @DateReturned date;

-- Get the item ID and user ID for the loan

select @ItemId = Item\_ID, @UserId =User\_ID, @DateDue = Date\_Due, @DateReturned =getdate()

from Loans

where Loan\_id = @LoanId;

-- Update the Loans table with the return date

update Loans set Date\_Returned = @DateReturned where Loan\_id = @LoanId;

-- Update the CatalogueOfItems table to set the item as available

update CatalogueOfItems set Current\_status ='Available'where Item\_id = @ItemId;

-- Check if the item was returned late and calculate the fine

declare @Fine decimal(7, 2);

if @DateReturned \> @DateDue

begin

declare @DaysLate int=datediff(day, @DateDue, @DateReturned);

set @Fine = @DaysLate \* 0.10;

-- Insert a new fine record or update an existing one

declare @FineId int;

select @FineId = Fine\_id from Fines whereUser\_ID= @UserId;

if @FineId ISNULL

begin

-- Create a new fine record for the user

insertinto Fines(User\_ID, Total\_Fine\_Owed, Total\_Fine\_Paid, Total\_Fine\_Remaining)

values (@UserId, @Fine, 0.00, @Fine);

end

else

begin

-- Update the existing fine record for the user

update Fines

set Total\_Fine\_Owed = Total\_Fine\_Owed + @Fine,

Total\_Fine\_Remaining = Total\_Fine\_Remaining + @Fine

where Fine\_id = @FineId;

end

end

end

### Fine Trigger

This trigger automatically updates the fines whenever there is any update on the Loans table

createtrigger AddFines

on Loans

forupdate

as

begin

declare @User\_ID int;

declare @Item\_ID int;

declare @Date\_Due date;

declare @Date\_Returned date;

select @User\_ID =User\_ID, @Item\_ID = Item\_ID, @Date\_Due = Date\_Due, @Date\_Returned = Date\_Returned from inserted;

if @Date\_Returned isnulland @Date\_Due \<getdate()

begin

declare @Fine\_ID INT;

declare @Total\_Fine\_Owed decimal(7,2);

declare @Total\_Fine\_Paid decimal(7,2);

declare @Total\_Fine\_Remaining decimal(7,2);

select @Fine\_ID = Fine\_id, @Total\_Fine\_Owed = Total\_Fine\_Owed, @Total\_Fine\_Paid = Total\_Fine\_Paid, @Total\_Fine\_Remaining = Total\_Fine\_Remaining from Fines whereUser\_ID= @User\_ID;

if @Fine\_ID isnull

begin

insertinto Fines(User\_ID, Total\_Fine\_Owed, Total\_Fine\_Paid, Total\_Fine\_Remaining)

values (@User\_ID, 0.10, 0.00, 0.10);

end

else

begin

update Fines set Total\_Fine\_Owed = @Total\_Fine\_Owed + 0.10, Total\_Fine\_Remaining = @Total\_Fine\_Remaining + 0.10 whereUser\_ID= @User\_ID;

end

end

end

### Pay Fine

This is a procedure that takes the amount that the user would like to pay, the fine Id and the payment method. It updates the Fines and Fines Repayment table and prints out a nice payment message. I used convert to change the data types of the data so that it could all be joined in the string

createprocedure PayFine

@FineID int,

@Amount decimal(7,2),

@PaymentMethod nvarchar(10)

as

begin

setnocounton;

insertinto FineRepayments(Fine\_id, Date\_Paid, Amount\_Paid, Payment\_Method)

values (@FineID,getdate(), @Amount, @PaymentMethod);

update Fines

set Total\_Fine\_Paid = Total\_Fine\_Paid + @Amount,

Total\_Fine\_Remaining = Total\_Fine\_Remaining - @Amount

where Fine\_id = @FineID;

-- Print payment message

print'Payment of '+convert(nvarchar(20), @Amount)+' has been made on fine '+convert(nvarchar(10), @FineID)+' using '+ @PaymentMethod +'.';

end

### View All User Details

I created a view and joined the Users, Addresses and Login tables so that the library could see all their member details.

createview UserDetails AS

select Users.User\_id, Users.First\_Name, Users.Last\_Name,

Users.Date\_Of\_Birth, Users.Email, Users.Telephone,

Addresses.Street\_address, Addresses.City, Addresses.State,

UserLogins.Username, UserLogins.Password\_Hash, UserLogins.Salt,

Users.DateJoined, Users.DateLeft

from Users

leftjoin Addresses on Users.Address\_ID = Addresses.Address\_id

leftjoin UserLogins on Users.User\_Login\_ID = UserLogins.Login\_id;

### Function to Check Item Status

I created this function that takes the item title in string as a parameter and checks if it is available using the select on catalogue of items. It returns the status if the title exists and item not found if it doesn't exist

--function to check item status

createfunction CheckStatus(@itemTitle nvarchar(250))

returnsnvarchar(50)

as

begin

declare @status nvarchar(50)

select @status = Current\_Status

from CatalogueOfItems

where Item\_title = @itemTitle

if @status ISNULL

set @status ='Item not found'

return @status

end

## Additional Recommendations

### Data Integrity and Concurrency

To ensure data integrity in the database, I used the following checks:

- Primary keys and foreign keys: I gave all tables primary identifier keys and Foreign keys in tables that refenced other tables to ensure consistent data across the tables.
- Check constraints: I used checks to ensure that data entered into columns like methods of payment, types of items, item status and email conforms to a particular style as requested by the library in the task brief.
- Not null constraints: I used not null constraints to make sure that the fields were not left empty during data entry.

I also use 'begin' and 'commit' when creating library procedures to ensure that concurrent updates to the same record are not allowed.

### Database Security

The first thing I did to improve upon the database security was to create a schema. Schemas can be used as a security boundary and database objects can be allocated to that specific schema. In this case, we have created a security boundary using the code below:

--creating library schema

createschemaLibrary

go

--transfer tables

alterschemaLibrarytransfer [dbo].[Addresses]

alterschemaLibrarytransfer [dbo].[CatalogueOfItems]

alterschemaLibrarytransfer [dbo].[FineRepayments]

alterschemaLibrarytransfer [dbo].[Fines]

alterschemaLibrarytransfer [dbo].[Loans]

alterschemaLibrarytransfer [dbo].[UserLogins]

alterschemaLibrarytransfer [dbo].[Users]

--transfer functions, procedures and views

alterschemaLibrarytransfer [dbo].[UserDetails]

alterschemaLibrarytransfer [dbo].[ViewLibraryLoanHistory]

alterschemaLibrarytransfer [dbo].[CheckStatus]

alterschemaLibrarytransfer [dbo].[LoanOnDate]

alterschemaLibrarytransfer [dbo].[AddNewUser]

alterschemaLibrarytransfer [dbo].[AddToLibrary]

alterschemaLibrarytransfer [dbo].[ItemsDue]

alterschemaLibrarytransfer [dbo].[PayFine]

alterschemaLibrarytransfer [dbo].[ReturnItem]

alterschemaLibrarytransfer [dbo].[SearchForTitle]

alterschemaLibrarytransfer [dbo].[UpdateUser]

### Security Recommendations

The library should consider what roles to create and necessary privileges will be associated to that role. These roles could be used to separate the job descriptions of librarians that loan out books from employees that work in the libray's finance department to oversee the fines.

See example below:

A login should be created for the user with similar code as below:

createlogin librarian

withpassword='library001';

Close the SSMS and re-start it to login using the new details to connect to the SQL Server instance.

Create a database user for the Library Database using the code below:

--create database user

createuser librarian

forlogin librarian;

To grant a role/user any permissions on database objects, use the following grant statement:

-- grant CRUD operations and grant permissions

grantselect,insert,delete,update

on [Library].[CatalogueOfItems]

to librarian

withgrantoption;

To incase of the librarian being retired/fired, to revoke his/her permission to the schema:

-- revoke access

revokeselect

onschema::Library

to librarian;

### Full Database Backup

1. I created a folder called LibraryManagementSystem\_Backup and then created an SQL server instance in SSMS. After doing this, I went to Tasks on my Library Database and clicked on Back Up

![](RackMultipart20230605-1-aryxca_html_42d0e35ac1a98ab2.png)

![](RackMultipart20230605-1-aryxca_html_48192929d3cee117.png)

![](RackMultipart20230605-1-aryxca_html_aad09be8010c417f.png)

1. In the dialog box, I chose the database and the backup type to be Full. Then I selected the destination as disk as I would be keeping a backup of the library's management system on my device.

![](RackMultipart20230605-1-aryxca_html_125778522573ad6b.png)

1. After setting the location for the backup to be saved, I clicked on media and selected the override all option

![](RackMultipart20230605-1-aryxca_html_63eca6330878f4af.png)

1. After I selected the compress option in backup options, I clicked ok and my file was created.

![](RackMultipart20230605-1-aryxca_html_806d18a4922ca1a8.png)

### Restore Database

In the event of an emergency and the Library's Database wants to be restored, this is the step-by-step process of how I did it.

1. In order to ensure that the Library's database is backed up periodically under short periods of time and can be restored at any point after the full backup, I did a differential backup.

![](RackMultipart20230605-1-aryxca_html_f09ff177b54d53ac.png)

![](RackMultipart20230605-1-aryxca_html_1718f4c21bd20c02.png)

1. In the case of an emergency, the timeline can be selected to choose where the library's recovery would begin.

![](RackMultipart20230605-1-aryxca_html_b2c922c2aec21773.png)

![](RackMultipart20230605-1-aryxca_html_6f10edf7f5cae0ff.png)

1. The Database has been restored successfully

![](RackMultipart20230605-1-aryxca_html_a4e27035ae9ced26.png)

### Selecting a Maintenance plan

As the Library can afford to go a couple of hours without the database, I have decided to create a Maintenance plan with the Wizard in order to frequently back up the LibraryManagementSystem Database.

1. In the Object Explorer Pane, I clicked on Management Node and selected the Maintenance Plan Wizard

![](RackMultipart20230605-1-aryxca_html_afd03571b35ef5c1.png)

Note: In case of an error message, use the following code:

SP\_CONFIGURE'SHOW ADVANCE',1

GO

RECONFIGUREWITHOVERRIDE

GO

SP\_CONFIGURE'AGENT XPs',1

GO

RECONFIGUREWITHOVERRIDE

GO

1. I create a new schedule and set the backup and database check as daily

![](RackMultipart20230605-1-aryxca_html_ad64ffac7c6af9c1.png)

1. I selected integrity checks and full database back up. I set the backup component to all databases.

![](RackMultipart20230605-1-aryxca_html_9fa7609f19b20ea.png)

![](RackMultipart20230605-1-aryxca_html_2884885dd46446ec.png)

1. This is the maintenance plan and I saved it

![](RackMultipart20230605-1-aryxca_html_8924652ae70d9b0e.png)

![](RackMultipart20230605-1-aryxca_html_2631fbafcf7febd6.png)

![](RackMultipart20230605-1-aryxca_html_fc8c8ea3c8947861.png)

## Conclusion

The database has been designed to store and update data on its entities which include Addresses, UserLogins, Users, CatalogueOfItems, Loans, Fines, and FineRepayments.

These tables were created with Primary and foreign keys to ensure referential integrity in the database. I also used check constraints to ensure data consistency across the tables so that the data put in the columns were approved by the clients.

Some of the key functionalities offered is the ability to update data on the library's members, search for specific titles, track loans and status of the items in the library.

I created procedures to insert, update and query data in the database, created triggers that help to automate certain operations in the library. I created functions to calculate things like total daily loan and database views to see into the data being held in the database.

I implemented security practice for the database using schemas, roles and password hashing and salting. The database is also backed up so the information would not be lost in the event of a power outage or a fire outbreak.

