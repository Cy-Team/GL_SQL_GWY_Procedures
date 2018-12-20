ALTER PROCEDURE GL_GWYOperPerson_TZData(@SETChild VARCHAR(100), @OperID VARCHAR(100), @JobID VARCHAR(36), @JobDataID INT, @UserID VARCHAR(30))
AS
BEGIN
	/*
	* 回填指定信息子集的 子集
	* 用于354公务员项目
	* 作者： 胡文鸿
	*/
	DECLARE
		@CHILD VARCHAR(10) = ''
		, @SQL VARCHAR(2000) = ''
		, @Field VARCHAR(100) = ''
	
	
	DECLARE
		CURSOR_SETCHILD CURSOR
	    FOR (SELECT ch FROM dbo.Get_StringSplit(@SETChild, ','))
	OPEN CURSOR_SETCHILD; --打开游标
	FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 删除
		SET @Field = (SELECT TOP 1 ItemID FROM SM_SetItems WHERE SetID = @CHILD AND ItemID LIKE '%RKeyID')
		SET @SQL = '
			DELETE a FROM Data_DB21_'+ @CHILD +' a
			LEFT JOIN WF_D_'+ @OperID +'_Main b ON a.'+ @CHILD +'PersonID = b.SourceKeyID AND a.'+ @CHILD +'B0001 = b.B0001
			WHERE JobID = '''+ @JobID +''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID)
		
		EXEC(@SQL)
		PRINT @SQL
		
		-- 插入
		SET @SQl = '
			INSERT INTO dbo.Data_DB21_'+ @CHILD +' (KeyID, DispOrder, IsLastRow, LastUpdateTime, LastUpdateUser, '+ 
				(SELECT TOP 1
					    [ItemID]=stuff((
					    SELECT ',' + ItemID FROM SM_SetItems WHERE SetID = @CHILD FOR XML path('')
					), 1, 1, ''))			
			 +')
			SELECT
			    Replace(Newid(),''-'','''') AS KeyID
			    , row_number() OVER(PARTITION BY KeyID ORDER BY DispOrder) AS DispOrder
			    , 1 AS IsLastRow
			    , getdate() AS LastUpdateTime
			    , '''+ @UserID +''' AS LastUpdateUser
			    , ' + (SELECT TOP 1
					    [ItemID]=stuff((
					    SELECT ',' + ItemID FROM SM_SetItems WHERE SetID = @CHILD FOR XML path('')
					), 1, 1, '')) + '
			FROM WF_D_' + @OperID + '_'+ @CHILD +' _'+ @CHILD +' WHERE KeyID IN (
			SELECT KeyID FROM WF_D_' + @OperID + '_Main WHERE JobID = '''+ @JobID +''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			AND NOT EXISTS (SELECT 1 FROM Data_DB21_'+ @CHILD +' WHERE _'+ @CHILD +'.'+ @CHILD +'B0001 = '+ @CHILD +'B0001 AND ' + @Field + ' = _'+@CHILD+'.'+@Field+' )
		'
		
		IF @CHILD = 'W04'
		BEGIN
			SET @SQl = @SQl + ' AND W04A1521 >= (SELECT year(A2907) FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W05'
		BEGIN
			SET @SQl = @SQl + ' AND W05A1107 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W06'
		BEGIN
			SET @SQl = @SQl + ' AND W06A1407 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W07'
		BEGIN
			SET @SQl = @SQl + ' AND W07A0243 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W08'
		BEGIN
			SET @SQl = @SQl + ' AND W08A0265 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W09'
		BEGIN
			SET @SQl = @SQl + ' AND W09A02G01 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		IF @CHILD = 'W0A'
		BEGIN
			SET @SQl = @SQl + ' AND W0AA02G01 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		/*
		IF @CHILD = 'W0B'
		BEGIN
			SET @SQl = @SQl + ' AND W0BA0291T >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		*/
		
		IF @CHILD = 'W0C'
		BEGIN
			SET @SQl = @SQl + ' AND W0CGWYZWZJ02T >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _'+@CHILD+'.KeyID AND IsLastRow = 1)'
		END
		
		EXEC(@SQL)
		PRINT @SQL
		
		SET @SQl = '
			UPDATE _'+@CHILD+'A
				SET '+ (
					SELECT TOP 1
					    [ItemID]=stuff((
					    SELECT ', _'+@CHILD+'A.'+ ItemID + '= _'+@CHILD+'B.' + ItemID FROM SM_SetItems WHERE SetID = ''+@CHILD+'' FOR XML path('')
					), 1, 1, '')
				)+'
			FROM Data_DB21_'+@CHILD+' _'+@CHILD+'A, WF_D_'+@OperID+'_'+@CHILD+' _'+@CHILD+'B
			WHERE _'+@CHILD+'B.KeyID IN (
				SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+ @JobID +''' AND JobDataID = '+convert(VARCHAR(4), @JobDataID)+')
				AND _'+@CHILD+'B.'+@Field+' = _'+@CHILD+'A.'+@Field+'
				AND _'+@CHILD+'B.'+@CHILD+'PersonID = _'+@CHILD+'A.'+@CHILD+'PersonID
				AND _'+@CHILD+'B.'+@CHILD+'B0001 = _'+@CHILD+'A.'+@CHILD+'B0001
		'
		EXEC(@SQL)
		PRINT @SQL
				
	    FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD;
	END
	CLOSE CURSOR_SETCHILD;
	DEALLOCATE CURSOR_SETCHILD;
END
GO

