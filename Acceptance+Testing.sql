--Create a new database
create database testdb;

--Create a new user
--By default, only the master user that you created when you launched the cluster has access to the
--initial database in the cluster. 
--When you create a new user, you specify the name of the new user and a password. 
--A password is required. It must have between 8 and 64 characters, 
--and it must include at least one uppercase letter, one lowercase letter, and one numeral.
create user guest password 'ABCd4321';

--Drop a user
drop user guest;

--Create a new table
create table testtable (testcol int);

--Query table definition
select * from pg_table_def where tablename = 'testtable';

--Insert data into table
insert into testtable values (100);

--Query data from table
select * from testtable;

--The PG_TABLE_DEF system table contains information about all the tables in the cluster.
--By default, new database objects, such as tables, are created in a schema named "public".
--To view a list of all tables in the public schema, you can query the PG_TABLE_DEF system catalog table
select distinct(tablename) from pg_table_def where schemaname = 'public';

--Query the PG_USER catalog to view a list of all database users, along with the user ID (USESYSID) and user privileges
select * from pg_user;

--The user name rdsdb is used internally by Amazon Redshift to perform routine administrative and maintenance tasks. 
--You can filter your query to show only user-defined user names by adding where usesysid > 1 to your select statement
select * from pg_user where usesysid > 1;

--The SVL_QLOG view is a friendlier subset of information from the STL_QUERY table. 
--You can use this view to find the query ID (QUERY) or process ID (PID) for a recently run query or 
--to see how long it took a query to complete.
--SVL_QLOG includes the first 60 characters of the query string (SUBSTRING) to help you locate a specific query. 
--Use the LIMIT clause with your SELECT statement to limit the results to five rows.
select query, pid, elapsed, substring from svl_qlog
where userid = 100
order by starttime desc
limit 5;

--You will need the PID if you need to cancel a query that is taking too long to run. 
--You can query the STV_RECENTS system table to obtain a list of process IDs for running queries, 
--along with the corresponding query string. If your query returns multiple PIDs, you can look at the query text to determine 
--which PID you need.
--Copy in another window and execute immediately after running below query to find the PID of the below query
select top 10 *
from stv_recents
where status='Running';

--Execute a sample query that is a little complex for processing
--The result set will include all of the rows in the SALES table multiplied by all the rows in the USERS table (49989*3766). 
--This is called a Cartesian join, and it is not recommended. The result is over 188 million srows and takes a long time to run.
select sellerid, firstname, lastname, sum(qtysold)
from sales, users
group by sellerid, firstname, lastname
order by 4 desc;

--The CANCEL command will not abort a transaction. To abort or roll back a transaction, you must use the ABORT 
--or ROLLBACK command. To cancel a query associated with a transaction, first cancel the query then abort the transaction.

cancel <pid>

--If your current session has too many queries running concurrently, you might not be able to run the CANCEL command 
--until another query finishes. In that case, you will need to issue the CANCEL command using a different 
--workload management query queue.
--Workload management enables you to execute queries in different query queues so that you don't need to wait for another query
--to complete. The workload manager creates a separate queue, called the Superuser queue, that you can use for troubleshooting.
--To use the Superuser queue, you must be logged on a superuser and set the query group to 'superuser' using the SET command. 
--After running your commands, reset the query group using the RESET command.

set query_group to 'superuser';
cancel 18764;
reset query_group;

--Drop test database
drop database testdb