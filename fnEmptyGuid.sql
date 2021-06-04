 IF EXISTS (
     SELECT * FROM sysobjects WHERE id = object_id(N'dbo.EmptyGuid') 
     AND xtype IN (N'FN', N'IF', N'TF')
 )
     DROP FUNCTION General.EmptyGuid
 GO
 
 --======================================================================
 -- Author: Chris Stoll
 -- Date: 6/4/2021
 -- Description: Returns an empty guid
 -- Yes, I'm this lazy
 --======================================================================
 CREATE FUNCTION dbo.EmptyGuid()
 RETURNS UNIQUEIDENTIFIER
 AS
 BEGIN
     RETURN '00000000-0000-0000-0000-000000000000'
END
 GO