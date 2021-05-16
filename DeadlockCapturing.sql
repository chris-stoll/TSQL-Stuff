/*

Sets up writing deadlocks to a table when they occur. 
Take and slightly modified from: https://itsalljustelectrons.blogspot.com/2017/06/Handling-SQL-Server-Deadlocks-With-Event-Notifications.html

*/





--Create a queue just for Deadlock events.
CREATE QUEUE queDeadlockNotification
 
--Create a service just for Deadlock events.
CREATE SERVICE svcDeadlockNotification
ON QUEUE queDeadlockNotification ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification])
 
-- Create the event notification for Deadlock events on the service.
CREATE EVENT NOTIFICATION enDeadlock
ON SERVER
WITH FAN_IN
FOR DEADLOCK_GRAPH
TO SERVICE 'svcDeadlockNotification', 'current database';
GO


DROP TABLE IF EXISTS dbo.DeadlockHistory

CREATE TABLE dbo.DeadlockHistory(
	DeadlockHistoryID INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_DeadlockHistory PRIMARY KEY CLUSTERED(DeadlockHistoryID)
	,CreatedOn DATETIME2(3) NOT NULL
		CONSTRAINT DF_DeadlockHistory_CreatedOn DEFAULT(SYSDATETIME())
	,DeadlockXML XML NOT NULL
    

)

GO

CREATE OR ALTER PROCEDURE dbo.ReceiveDeadlock
/******************************************************************************
* Name     : dbo.ReceiveDeadlock
* Purpose  : Handles deadlock events (activated by QUEUE queDeadlockNotification)
* Inputs   : None
* Outputs  : None
* Returns  : Nothing
******************************************************************************
* Change History
*      06/26/2017    DMason Created
*	   05/15/2021	 CStoll	Changed from email notification to writing to a table
******************************************************************************/
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @MsgBody XML
 
 WHILE (1 = 1)
 BEGIN
  BEGIN TRANSACTION
 
  -- Receive the next available message FROM the queue
  WAITFOR (
   RECEIVE TOP(1) -- just handle one message at a time
   @MsgBody = CAST(message_body AS XML)
   FROM queDeadlockNotification
  ), TIMEOUT 1000  -- if the queue is empty for one second, give UPDATE and go away
  -- If we didn't get anything, bail out
  IF (@@ROWCOUNT = 0)
  BEGIN
   ROLLBACK TRANSACTION
   BREAK
  END
  ELSE
  BEGIN
   --Do stuff here.
   IF @MsgBody IS NOT NULL
	INSERT INTO dbo.DeadlockHistory(DeadlockXML)
	VALUES(@MsgBody);

   /*
    Commit the transaction.  At any point before this, we
    could roll back -- the received message would be back
    on the queue AND the response wouldn't be sent.
   */

   COMMIT TRANSACTION
  END
 END
END
GO

ALTER QUEUE dbo.queDeadlockNotification
WITH
 STATUS = ON,
 ACTIVATION (
  PROCEDURE_NAME = dbo.ReceiveDeadlock,
  STATUS = ON,
  MAX_QUEUE_READERS = 1,
  EXECUTE AS OWNER)
GO