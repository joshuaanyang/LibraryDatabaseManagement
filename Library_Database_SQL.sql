-- complete queries for adb on a singular page --

--create database
create database LibraryManagementSystem;
go

--using the library database
use LibraryManagementSystem;
go

/* Creating Tables for the Libray System
Starting with the tables with the least amount of dependencies*/

create table Addresses(
Address_id int identity(1,1) not null primary key,
Street_address nvarchar(150) not null,
City nvarchar(90) not null,
State nvarchar(90) not null,
)
go

create table UserLogins(
Login_id int identity(1,1) not null primary key,
Username nvarchar(50) not null,
Password_Hash binary(64) not null,
Salt uniqueidentifier
)
go

create table Users(
User_id int identity(1,1) not null primary key,
First_Name nvarchar(50) not null,
Last_Name nvarchar(50) not null,
Date_Of_Birth date not null,
Email nvarchar(50) unique null,
Telephone int null,
Address_ID int,
User_Login_ID int,
DateJoined date not null,
DateLeft date null,
foreign key (Address_ID) references Addresses(Address_id),
foreign key (User_Login_ID) references UserLogins(Login_id),
constraint Email_Check check (Email like '%_@_%._%')
)
go


create table CatalogueOfItems(
Item_id int identity(1,1) not null primary key,
Item_title nvarchar(250) not null,
Item_type nvarchar(20) not null,
Author_Name nvarchar(250) null,
Year_Published date null,
Date_added date not null,
Current_status nvarchar(25) not null,
Date_removed date null,
ISBN numeric(18,0) null,
constraint Item_Type_Check check (Item_type IN ('Book', 'Journal', 'DVD', 'Other Media')),
constraint Status_Check check (Current_status IN ('On Loan', 'Overdue', 'Available', 'Lost/Removed'))
)
go


create table Loans(
Loan_id int identity(1,1) not null primary key,
User_ID int not null,
Item_ID int not null,
Date_Loaned date not null,
Date_Due date not null,
Date_Returned date null,
foreign key (User_ID) references Users(User_id),
foreign key (Item_ID) references CatalogueOfItems(Item_id)
)
go

create table Fines(
Fine_id int identity(1,1) not null primary key,
User_ID int not null,
Total_Fine_Owed decimal(7,2) not null,
Total_Fine_Paid decimal(7,2) not null,
Total_Fine_Remaining decimal(7,2) not null,
foreign key (User_ID) references Users(User_id)
)
go

create table FineRepayments(
Repayment_id int identity(1,1) not null primary key,
Fine_id int not null,
Date_Paid date not null,
Amount_Paid decimal(7,2) not null,
Payment_Method nvarchar(10) not null,
foreign key (Fine_id) references Fines(Fine_id),
constraint Payment_Check check (Payment_Method IN ('cash', 'card'))
)
go

/*Search the catalogue for matching character strings by title.
Results should be sorted with most recent publication date first*/


create procedure SearchForTitle
    @char_string nvarchar(250)
as
begin
    select * 
    from CatalogueOfItems
    where Item_title like '%' + @char_string + '%'
    order by Year_Published desc
end
go

/*Return a full list of all items currently on loan
which have a due date of less than five days from the current date 
(i.e., the system date when the query is run)*/

create procedure ItemsDue
as
begin
    select *
    from Loans 
    inner join CatalogueOfItems Cat on Loans.Item_ID = Cat.Item_id
    where datediff(day, getdate(), Loans.Date_Due) < 5 and Loans.Date_Returned is null
end
go

/*
Insert a new member into the database:
*/

create procedure AddNewUser
    @first_name nvarchar(50),
    @last_name nvarchar(50),
    @date_of_birth date,
    @email nvarchar(50),
    @telephone int,
    @street_address nvarchar(150),
    @city nvarchar(90),
    @state nvarchar(90),
    @username nvarchar(50),
    @password nvarchar(50)

as
begin
    declare @address_id int
    insert into Addresses (Street_address, City, State)
    values (@street_address, @city, @state)
    set @address_id = scope_identity()
    
    declare @login_id int
	declare @salt uniqueidentifier=newid()
    insert into UserLogins (Username, Password_Hash, Salt)
    values (@username, hashbytes('SHA2_512',@password+cast(@salt as nvarchar(36))), @salt)
    set @login_id = scope_identity()
    
    insert into Users (First_Name, Last_Name, Date_Of_Birth, Email, Telephone, Address_ID, User_Login_ID, DateJoined)
    values (@first_name, @last_name, @date_of_birth, @email, @telephone, @address_id, @login_id, getdate())
end
go

--update user

create procedure UpdateUser
        @User_id int,
    @First_Name nvarchar(50) = null,
    @Last_Name nvarchar(50) = null,
    @Date_Of_Birth date = null,
    @Email nvarchar(50) = null,
    @Telephone int = null,
    @street_address nvarchar(150) = null,
    @city nvarchar(90) = null,
    @state nvarchar(90) = null,
    @username nvarchar(50) = null,
    @password nvarchar(50) = null,
    @DateJoined date = null,
    @DateLeft date = null
as
begin
	declare @salt uniqueidentifier=newid()
    update Users
    set First_Name = isnull(@First_Name,First_Name),
        Last_Name = isnull(@Last_Name,Last_Name),
        Date_Of_Birth = isnull(@Date_Of_Birth,Date_Of_Birth),
        Email = isnull(@Email,Email),
        Telephone = isnull(@Telephone,Telephone),
        DateJoined = isnull(@DateJoined,DateJoined),
        DateLeft = isnull(@DateLeft,DateLeft)
    where User_id = @User_id;

	update Addresses
	set Street_address = isnull(@street_address,Street_address),
		City = isnull(@city,City),
		State = isnull(@state,State)
	where Address_id = (select Address_ID from Users where User_id = @User_Id) 

	update UserLogins
	set Username = isnull(@username,Username),
		Password_Hash = isnull(hashbytes('SHA2_512',@password+cast(@salt as nvarchar(36))),Password_Hash)	
	where Login_id = (select User_Login_ID from Users where User_id = @User_Id)

end
go

/*view loan history showing all previous and current loans and including details of the item borrowed, borrowed date,
due date and any associated fines for each loan*/

create view ViewLibraryLoanHistory
as
select 
    Loans.Loan_id,
    Users.First_Name,
    Users.Last_Name,
    CatalogueOfItems.Item_title,
	CatalogueOfItems.Item_type,
    Loans.Date_Loaned,
    Loans.Date_Due,
    Loans.Date_Returned,
    Fines.Total_Fine_Owed,
    Fines.Total_Fine_Paid,
    Fines.Total_Fine_Remaining
from 
    Loans 
    join Users on Loans.User_ID = Users.User_id
    join CatalogueOfItems on Loans.Item_ID = CatalogueOfItems.Item_id
    left join Fines on Loans.User_ID = Fines.User_ID;

--update status when item is returned

create trigger update_status
on Loans
after update
as
begin
  if update(Date_Returned)
  begin
    update CatalogueOfItems
    set Current_status = 'Available'
    from CatalogueOfItems
    join returned on CatalogueOfItems.Item_id = returned.Item_ID
    where returned.Date_Returned IS NOT NULL
      and CatalogueOfItems.Current_status != 'Available'
  end
end
go

--get total loans on specific date

create function LoanOnDate(@date date)
returns int
as
begin
    declare @loanCount int
    
    select @loanCount = count(*)
    from Loans
    where Date_Loaned = @date
    
    return @loanCount
end
go

/*test test test*/
exec AddNewUser 'Jay','Cole','1990-01-27','jaycole@gmail.com', null,'19 Hollywood Boulevard','Los Angeles',
    'California','jcole','jaydacoolest' 
go

exec AddNewUser 'Kene','James','1999-11-20','kene@yahoo.com', 101920,'5 Tokunbo Ave','Victoria Island',
    'Lagos','kene','kjames1999'
go

exec AddNewUser 'Milesh','Doy','1998-04-30','doy@gmail.com', 708908,'14 John Lester','Salford',
    'Greater Manchester','milesh','doy123doy456doy'
go

exec AddNewUser 'Eminem','Marshall','1890-10-10','eminem@slimshady.com', null,'Saint John','Westminister',
    'London','eminem','fastestrap109'
go


select * from Userdetails
go

--DBCC CHECKIDENT ('Addresses', RESEED, 0);
	
select * from [dbo].[Total_Loans_View]
go
select * from [dbo].[ViewLibraryLoanHistory]
go

select * from loans
go

exec AddToLibrary 'The Secret History', 'Book', 'Donna Tart', '2021-07-16', 'Available', 33442059;
go
exec AddToLibrary '8th Confession', 'Book', 'James Patterson', '2015-03-21', 'On Loan', 780316761;
go
exec AddToLibrary 'Lion King', 'DVD', null, '1999-04-19', 'Available', 921019398;
go
exec AddToLibrary 'Poltergeist', 'Journal', 'J.S. Anyang', '2001-05-26', 'Overdue', 31694328;
go


--Inserting data into Loans table
/*insert into Loans (User_ID, Item_ID, Date_Loaned, Date_Due, Date_Returned)
values (1, 2, '2023-03-30', '2023-04-11', NULL),
       (3, 4, '2023-03-30', '2023-03-30', NULL);*/

insert into Loans (User_ID, Item_ID, Date_Loaned, Date_Due, Date_Returned)
values (3, 4, '2023-04-03', '2023-04-03', NULL);
go


--Inserting data into Fines table
insert into Fines (User_ID, Total_Fine_Owed, Total_Fine_Paid, Total_Fine_Remaining)
values (3, 0.10, 0.00, 0.10)
go

--borrowing item
select * from library.CatalogueOfItems
go

exec  [Library].[BorrowItem] 'Kene', 'James', 'Lion King', '2023-05-01'
go

select * from Library.Loans
go

update Library.Loans
SET Date_Returned = getdate()
WHERE Loan_id = 5;
go

select * from library.CatalogueOfItems
go


select * from Library.UserDetails
go

exec Library.UpdateUser @user_id=1, @Telephone= 90480334
go


/*test test test*/

--additional
--borrow items
create procedure BorrowItem
    @FirstName nvarchar(50),
    @LastName nvarchar(50),
    @Title nvarchar(250),
    @ReturnDate date
as
begin
    set nocount on;
    
    -- Check if user exists
    declare @UserID int
    select @UserID = User_id from Users where First_Name = @FirstName and Last_Name = @LastName
    if @UserID is null
    begin
        raiserror('User not found.', 16, 1)
        return
    end
    
    -- Check if item is available
    declare @ItemID int
    select @ItemID = Item_id from CatalogueOfItems where Item_title = @Title and Current_status = 'Available'
    if @ItemID is null
    begin
        raiserror('Item not available.', 16, 1)
        return
    end
    
    -- Update Loan table
    insert into Loans (User_ID, Item_ID, Date_Loaned, Date_Due)
    values (@UserID, @ItemID, getdate(), @ReturnDate)
    
    -- Update CatalogueOfItems table
    update CatalogueOfItems set Current_status = 'On Loan' where Item_id = @ItemID
	update CatalogueOfItems set Date_removed = getdate() where Item_id = @ItemID
    
    print 'Item borrowed successfully.'
end
go

-- return items
create procedure ReturnItem
    @LoanId int
as
begin
    set nocount on;

    declare @ItemId int;
    declare @UserId int;
    declare @DateDue date;
    declare @DateReturned date;

    -- Get the item ID and user ID for the loan
    select @ItemId = Item_ID, @UserId = User_ID, @DateDue = Date_Due, @DateReturned = getdate()
    from Loans
    where Loan_id = @LoanId;

    -- Update the Loans table with the return date
    update Loans set Date_Returned = @DateReturned where Loan_id = @LoanId;

    -- Update the CatalogueOfItems table to set the item as available
    update CatalogueOfItems set Current_status = 'Available' where Item_id = @ItemId;

    -- Check if the item was returned late and calculate the fine
    declare @Fine decimal(7, 2);
    if @DateReturned > @DateDue
    begin
        declare @DaysLate int = datediff(day, @DateDue, @DateReturned);
        set @Fine = @DaysLate * 0.10;

        -- Insert a new fine record or update an existing one
        declare @FineId int;
        select @FineId = Fine_id from Fines where User_ID = @UserId;

        if @FineId IS NULL
        begin
            -- Create a new fine record for the user
            insert into Fines (User_ID, Total_Fine_Owed, Total_Fine_Paid, Total_Fine_Remaining)
            values (@UserId, @Fine, 0.00, @Fine);
        end
        else
        begin
            -- Update the existing fine record for the user
            update Fines
            set Total_Fine_Owed = Total_Fine_Owed + @Fine,
                Total_Fine_Remaining = Total_Fine_Remaining + @Fine
            where Fine_id = @FineId;
        end
    end

end
go


--update fines with trigger
create trigger AddFines
on Loans
for update
as
begin
    declare @User_ID int;
    declare @Item_ID int;
    declare @Date_Due date;
    declare @Date_Returned date;

    select @User_ID = User_ID, @Item_ID = Item_ID, @Date_Due = Date_Due, @Date_Returned = Date_Returned from inserted;

    if @Date_Returned is null and @Date_Due < getdate()
    begin
        declare @Fine_ID INT;
        declare @Total_Fine_Owed decimal(7,2);
        declare @Total_Fine_Paid decimal(7,2);
        declare @Total_Fine_Remaining decimal(7,2);

        select @Fine_ID = Fine_id, @Total_Fine_Owed = Total_Fine_Owed, @Total_Fine_Paid = Total_Fine_Paid, @Total_Fine_Remaining = Total_Fine_Remaining from Fines where User_ID = @User_ID;

        if @Fine_ID is null
        begin
            insert into Fines (User_ID, Total_Fine_Owed, Total_Fine_Paid, Total_Fine_Remaining)
            values (@User_ID, 0.10, 0.00, 0.10);
        end
        else
        begin
            update Fines set Total_Fine_Owed = @Total_Fine_Owed + 0.10, Total_Fine_Remaining = @Total_Fine_Remaining + 0.10 where User_ID = @User_ID;
        end
    end
end
go


--pay fine
create procedure PayFine
    @FineID int,
    @Amount decimal(7,2),
    @PaymentMethod nvarchar(10)
as
begin
    set nocount on;

    insert into FineRepayments (Fine_id, Date_Paid, Amount_Paid, Payment_Method)
    values (@FineID, getdate(), @Amount, @PaymentMethod);
	   
    update Fines
    set Total_Fine_Paid = Total_Fine_Paid + @Amount,
        Total_Fine_Remaining = Total_Fine_Remaining - @Amount
    where Fine_id = @FineID;

    -- Print payment message
    print 'Payment of ' + convert(nvarchar(20), @Amount) + ' has been made on fine ' + convert(nvarchar(10), @FineID) + ' using ' + @PaymentMethod + '.';
end
go

--created a view to see all the user details

create view UserDetails AS
select Users.User_id, Users.First_Name, Users.Last_Name,
       Users.Date_Of_Birth, Users.Email, Users.Telephone,
       Addresses.Street_address, Addresses.City, Addresses.State,
       UserLogins.Username, UserLogins.Password_Hash, UserLogins.Salt,
       Users.DateJoined, Users.DateLeft
from Users
left join Addresses on Users.Address_ID = Addresses.Address_id
left join UserLogins on Users.User_Login_ID = UserLogins.Login_id;
go


--function to check item status

create function CheckStatus(@itemTitle nvarchar(250))
returns nvarchar(50)
as
begin
    declare @status nvarchar(50)

    select @status = Current_Status
    from CatalogueOfItems
    where Item_title = @itemTitle

    if @status IS NULL
        set @status = 'Item not found'

    return @status
end
go

--create login user
create login librarian
with password = 'library001';
go

--create database user
create user librarian
for login librarian;
go

-- grant CRUD operations and grant permissions
grant select, insert, delete, update
on  [Library].[CatalogueOfItems]
to librarian
with grant option;
go

-- revoke access 
revoke select 
on schema :: Library 
to librarian;
go

