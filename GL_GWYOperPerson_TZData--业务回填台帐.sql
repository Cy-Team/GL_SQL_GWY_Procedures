ALTER PROCEDURE GL_GWYOperPerson_TZData(@SETChild VARCHAR(100), @OperID VARCHAR(100), @JobID VARCHAR(36), @JobDataID INT, @UserID VARCHAR(30))
AS
BEGIN
	/*
	* ����ָ����Ϣ�Ӽ��� �Ӽ�
	* ����354����Ա��Ŀ
	* ���ߣ� ���ĺ�
	*/
	DECLARE
		@CHILD VARCHAR(10) = ''
		, @SQL VARCHAR(2000) = ''
		, @Field VARCHAR(100) = ''
	
	
	DECLARE
		CURSOR_SETCHILD CURSOR
	    FOR (SELECT ch FROM dbo.Get_StringSplit(@SETChild, ','))
	OPEN CURSOR_SETCHILD; --���α�
	FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- ɾ��
		SET @Field = (SELECT TOP 1 ItemID FROM SM_SetItems WHERE SetID = @CHILD AND ItemID LIKE '%RKeyID')
		SET @SQL = '
			DELETE _TZ FROM Data_DB21_'+ @CHILD +' _TZ
			LEFT JOIN WF_D_'+ @OperID +'_Main _Main ON _TZ.'+ @CHILD +'PersonID = _Main.SourceKeyID AND _TZ.'+ @CHILD +'B0001 = _Main.B0001
			WHERE _Main.JobID = '''+ @JobID +''' AND _Main.JobDataID = '+ convert(VARCHAR(4), @JobDataID)
		
		EXEC(@SQL)
		PRINT @SQL
		
		-- ����
		SET @SQl = '
			INSERT INTO dbo.Data_DB21_'+ @CHILD +' (KeyID, DispOrder, IsLastRow, LastUpdateTime, LastUpdateUser, '+ 
				(SELECT TOP 1
					    [ItemID]=stuff((
					    SELECT ',' + ItemID FROM SM_SetItems WHERE SetID = @CHILD FOR XML path('')
					), 1, 1, ''))			
			 +')
			SELECT
			    Replace(Newid(),''-'','''') AS KeyID
			    , row_number() OVER(PARTITION BY _Main.KeyID ORDER BY _TZ.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
			    , getdate() AS LastUpdateTime
			    , '''+ @UserID +''' AS LastUpdateUser
			    , ' + (SELECT TOP 1
					    [ItemID]=stuff((
					    SELECT ',' + ItemID FROM SM_SetItems WHERE SetID = @CHILD FOR XML path('')
					), 1, 1, '')) + '
			FROM WF_D_' + @OperID + '_'+ @CHILD +' _TZ
			LEFT JOIN WF_D_'+ @OperID +'_Main _Main ON _TZ.'+ @CHILD +'PersonID = _Main.SourceKeyID AND _TZ.'+ @CHILD +'B0001 = _Main.B0001
			WHERE _Main.JobID = '''+ @JobID +''' AND _Main.JobDataID = '+ convert(VARCHAR(4), @JobDataID)
		
		EXEC(@SQL)
		PRINT @SQL
				
	    FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD;
	END
	CLOSE CURSOR_SETCHILD;
	DEALLOCATE CURSOR_SETCHILD;
END
GO

