ALTER PROCEDURE GL_GWYOperPersonTZ_Common(@SETChild VARCHAR(100), @OperID VARCHAR(50), @JobID VARCHAR(36), @JobDataID INT)
AS
BEGIN
	EXEC GL_GWYPerson_SETRKeyID 'A30, A29, A15, A11, A14, A02, A02G, GWYZWZJ', @OperID, @JobID, @JobDataID

	DECLARE
		@CHILD VARCHAR(10) = ''
		, @COUNT INT = 0
		, @SQL VARCHAR(8000) = ''
		, @InnerChangeCount INT = 0
		, @temSql NVARCHAR(800)=''
		
	SET @SQL = 
'
	UPDATE WF_D_'+@OperID+'_Main SET SourceKeyID = KeyID WHERE JobID = '''+@JobID+''' AND JobDataID =
' +	convert(VARCHAR(4), @JobDataID) + ' AND IsImport=0

'
	EXEC(@SQL)
	IF(@OperID LIKE 'CDGWYPsnEdit%' OR @OperID LIKE 'CDGWYTransferOut')
	BEGIN
		SET @temSql = 
'
			SELECT @InnerChangeCount = count(1) FROM WF_D_'+@OperID+'_GWYInnerChange WHERE KeyID IN 
	    	(SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''')
'
	EXEC sp_executesql @temSql,N'@InnerChangeCount INT out',@InnerChangeCount OUT
	END
	DECLARE
		CURSOR_SETCHILD CURSOR
	    FOR (SELECT ch FROM dbo.Get_StringSplit(@SETChild, ','))
	OPEN CURSOR_SETCHILD; 
	FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
	    IF @CHILD = 'W02'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W02 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
'+'

'+'	    	INSERT INTO dbo.WF_D_'+@OperID+'_W02 (KeyID, DispOrder, IsLastRow, W02A0215A, W02A0219, W02A0221, 
'+'			W02A0284, W02A0291, W02A0292, W02A0293, W02A0293G, W02A3001, W02A3004, W02B0001, W02UnitName, W02W0110G, W02PersonID, W02A30RKeyID)
'+'			
'+'			SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A30.KeyID ORDER BY _A30.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'			    ,A0215A
'+'			    ,A0219
'+'			    ,A0221
'+'			    ,A0284
'+'			    ,A0291
'+'			    ,A0292
'+'			    ,A0293
'+'			    ,A0293G
'+'			    ,A3001
'+'			    ,A3004
'+'			    ,B0001
'+'			    ,dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'			    ,W0110G
'+'			    ,SourceKeyID
'+'			    ,A30RKeyID
'+'			FROM WF_D_'+@OperID+'_A30 _A30
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _A30.KeyID = _main.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A02 _A02 ON _A02.KeyID = _main.KeyID AND _A02.IsLastRow = 1
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID)

			EXEC(@SQL)
			--PRINT @sql
			
		    IF @InnerChangeCount>0
		    BEGIN
		    	SET @SQL = 
'		    	INSERT INTO dbo.WF_D_'+@OperID+'_W02 (KeyID, DispOrder, IsLastRow, W02A0215A, W02A0219, W02A0221, 
'+'				W02A0284, W02A0291, W02A0292, W02A0293, W02A0293G, W02A3001, W02A3004, W02B0001, W02UnitName, W02W0110G, W02PersonID, W02A30RKeyID)
'+'				
'+'				SELECT
'+'				    _main.KeyID
'+'				    , (SELECT isnull(max(DispOrder), 0) + 1 FROM WF_D_'+@OperID+'_W02 WHERE KeyID = _main.KeyID) AS DispOrder
'+'				    , 1 AS IsLastRow
'+'				    ,GWYInnerChange10
'+'				    ,GWYInnerChange12
'+'				    ,GWYInnerChange09
'+'				    ,null
'+'				    ,null
'+'				    ,null
'+'				    ,null
'+'				    ,null
'+'				    ,GWYInnerChange08
'+'				    ,GWYInnerChange07
'+'				    ,GWYInnerChange01
'+'				    ,dbo.FN_CodeItemIDToName(''N'', GWYInnerChange01) C_N_GWYInnerChange01
'+'				    ,GWYInnerChange97
'+'				    ,SourceKeyID
'+'				    ,replace(newid(), ''-'', '''') AS RKeyID
'+'				FROM WF_D_'+@OperID+'_GWYInnerChange _change
'+'				LEFT JOIN WF_D_'+@OperID+'_Main _main ON _change.KeyID = _main.KeyID
'+'				WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) + ' AND GWYInnerChange99 = ''02''
' 
				EXEC(@SQL)
				PRINT @sql
			END
	    END
	    
	    IF @CHILD = 'W03'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W03 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			
'+'	    	INSERT INTO dbo.WF_D_'+@OperID+'_W03 (KeyID, DispOrder, IsLastRow, W03A0215A, W03A0219, W03A0221, 
'+'			W03A2907, W03A2911, W03B0001, W03UnitName, W03W0110G, W03PersonID, W03A29RKeyID)
'+'			
'+'			SELECT			    
'+'			     _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A29.KeyID ORDER BY _A29.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'			    ,A0215A
'+'			    ,A0219
'+'			    ,A0221
'+'			    ,A2907
'+'			    ,A2911
'+'			    ,B0001
'+'			    ,dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'			    ,W0110G
'+'			    ,SourceKeyID
'+'			    ,A29RKeyID
'+'			FROM WF_D_'+@OperID+'_A29 _A29
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _A29.KeyID = _main.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A02 _A02 ON _A02.KeyID = _main.KeyID AND _A02.IsLastRow = 1
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID)
		
			EXEC(@SQL)
			--PRINT @sql
			
		    IF @InnerChangeCount>0
		    BEGIN
		    	SET @SQL = 
'		    	INSERT INTO dbo.WF_D_'+@OperID+'_W03 (KeyID, DispOrder, IsLastRow, W03A0215A, W03A0219, W03A0221, 
'+'				W03A2907, W03A2911, W03B0001, W03UnitName, W03W0110G, W03PersonID, W03A29RKeyID)
'+'				
'+'				SELECT			    
'+'				     _main.KeyID
'+'				    , (SELECT isnull(max(DispOrder), 0) + 1 FROM WF_D_'+@OperID+'_W03 WHERE KeyID = _main.KeyID) AS DispOrder
'+'				    , 1 AS IsLastRow
'+'				    ,GWYInnerChange06
'+'				    ,GWYInnerChange11
'+'				    ,GWYInnerChange05
'+'				    ,GWYInnerChange03
'+'				    ,GWYInnerChange04
'+'				    ,GWYInnerChange01
'+'				    ,dbo.FN_CodeItemIDToName(''N'', GWYInnerChange01) C_N_GWYInnerChange01
'+'				    ,GWYInnerChange97
'+'				    ,SourceKeyID
'+'				    ,replace(newid(), ''-'', '''') AS RKeyID
'+'				FROM WF_D_'+@OperID+'_GWYInnerChange _change
'+'				LEFT JOIN WF_D_'+@OperID+'_Main _main ON _change.KeyID = _main.KeyID
'+'				WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) + ' AND GWYInnerChange99 = ''01''
'	
				EXEC(@SQL)
				PRINT @sql
			END
	    END
	    
	    IF @CHILD = 'W04'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W04 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			
'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W04 (KeyID, DispOrder, IsLastRow, 
'+'			W04A1501G, W04A1517, W04A1519G, W04A1521, W04A1521G, W04A1522, W04A1522G, W04B0001, W04UnitName, 
'+'			W04PersonID, W04A15RKeyID, W04W0110G)
'+'			
'+'			SELECT
'+'			     _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A15.KeyID ORDER BY _A15.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'			 	, A1501G
'+'			 	, A1517
'+'			 	, A1519G
'+'			 	, A1521
'+'			 	, A1521G
'+'			 	, A1522
'+'			 	, A1522G
'+'			 	, B0001
'+'			 	, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'			 	, SourceKeyID
'+'			 	, A15RKeyID
'+'			 	, W0110G
'+'			FROM WF_D_'+@OperID+'_A15 _A15
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _A15.KeyID = _main.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A02 _A02 ON _A02.KeyID = _main.KeyID AND _A02.IsLastRow = 1
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND A1521 >= (SELECT year(A2907) FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A15.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
			--PRINT @SQL
	    END
	    
	    IF @CHILD = 'W05'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W05 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			
'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W05 (KeyID, DispOrder, IsLastRow, 
'+'			W05A0219, W05A0221, W05A1101, W05A1104, W05A1107, W05A1111, W05A1111G, W05A1114, W05A1121, 
'+'			W05A1127, W05A1131, W05A1132G, W05A1133G, W05A1134G, W05A1151, W05A11RKeyID, W05B0001, W05PersonID, 
'+'			W05UnitName, W05W0110G)
'+'			
'+'			
'+'			SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A11.KeyID ORDER BY _A11.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, A11SX
'+'				, A11ZW
'+'				, A1101
'+'				, A1104
'+'				, A1107
'+'				, A1111
'+'				, A1111G
'+'				, A1114
'+'				, A1121
'+'				, A1127
'+'				, A1131
'+'				, A1132G
'+'				, A1133G
'+'				, A1134G
'+'				, A1151
'+'				, A11RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, W0110G
'+'			FROM WF_D_'+@OperID+'_A11 _A11
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _a11.KeyID = _main.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A02 _A02 ON _A02.KeyID = _main.KeyID AND _A02.DispOrder = (
'+'				SELECT isnull(max(DispOrder), 0) FROM WF_D_'+@OperID+'_A02 WHERE A0243 < _A11.A1107 AND KeyID = _A02.KeyID) 
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND A1107 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A11.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
			--PRINT @SQL
	    END
	    
	    IF @CHILD = 'W06'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W06 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			
'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W06 (KeyID, DispOrder, IsLastRow, 
'+'			W06A1404A, W06A1404B, W06A1407, W06A1411A, W06A1414, W06A1415, W06A1419G, W06A1424, W06A1428, 
'+'			W06A14RKeyID, W06B0001, W06PersonID, W06UnitName, W06W0110G)
'+'			
'+'			SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A14.KeyID ORDER BY _A14.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, A1404A
'+'				, A1404B
'+'				, A1407
'+'				, A1411A
'+'				, A1414
'+'				, A1415
'+'				, A1419G
'+'				, A1424
'+'				, A1428
'+'				, A14RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, W0110G
'+'			FROM WF_D_'+@OperID+'_A14 _A14
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _A14.KeyID = _main.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A02 _A02 ON _A02.KeyID = _main.KeyID AND _A02.IsLastRow = 1
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND A1407 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A14.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
			--PRINT @SQL
	    END
	    
	    IF @CHILD = 'W07'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W07 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
			
'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W07 (KeyID, DispOrder, IsLastRow, 
'+'	    	W07Age, W07A0141A, W07A0801B, W07A0801BQ, W07A0243, W07A0251, W07A0251D, W07A0243G, W07A0221, W07A0219, 
'+'	    	W07A02RKeyID, W07B0001, W07PersonID, W07UnitName, W07W0110G)
'+'
'+'	    	SELECT
'+'				_main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A02.KeyID ORDER BY _A02.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, substring(CONVERT(VARCHAR, datediff(M, A0111, A0243)/12), 1, 2)  AS Age
'+'				, A0141A
'+'				, _A08.A0801B
'+'				, _A08Q.A0801B A0801BQ
'+'				, A0243
'+'				, A0251
'+'				, A0251D
'+'				, A0243G
'+'				, A0221
'+'				, A0219
'+'				, A02RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, W0110G
'+'			FROM WF_D_'+@OperID+'_A02 _A02
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 _A08 ON _A08.KeyID = _main.KeyID AND _A08.DispOrder = (
'+'				SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A08 _A08Q WHERE KeyID = _main.KeyID 
'+'				AND A0807 = (SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 WHERE KeyID=_A08Q.KeyID AND A0807 < _A02.A0243))
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 AS _A08Q ON _main.KeyID=_A08Q.KeyID AND _A08Q.DispOrder = (
'+'				SELECT MAX(DispOrder) FROM WF_D_'+@OperID+'_A08 AS b WHERE b.KeyID=_A08Q.KeyID AND b.A0807 =
'+'					(SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 AS a WHERE a.KeyID=b.KeyID AND A0837=''1''))
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02 WHERE KeyID = _main.KeyID AND A0251 IN (''26'', ''27''))
'+'			AND A0243 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A02.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
			--PRINT @SQL
	    END
	    
	    IF @CHILD = 'W08'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W08 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')

'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W08 (KeyID, DispOrder, IsLastRow, 
'+'	    	W08A0219, W08A0221, W08A02RKeyID, W08B0001, W08PersonID, W08UnitName, W08W0110G, W08A0265)
'+'
'+'	    	SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A02.KeyID ORDER BY _A02.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, A0219
'+'				, A0221
'+'				, A02RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, W0110G
'+'				, A0265
'+'			FROM WF_D_'+@OperID+'_A02 _A02
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02.KeyID
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02 WHERE KeyID = _main.KeyID AND A0271 = ''2'')	
'+'			AND A0265 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A02.KeyID AND IsLastRow = 1)
'+'         AND A0201B = _main.B0001'
			EXEC(@SQL)
			--PRINT @SQL
		END
		
		IF @CHILD = 'W09'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W09 WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')

'+'		   	INSERT INTO dbo.WF_D_'+@OperID+'_W09 (KeyID, DispOrder, IsLastRow,
'+'	    	W09W0110G, W09A02G01, W09A02G02, W09A02G05, W09A02G06, W09B0001, W09PersonID, W09UnitName, W09A02GRKeyID)
'+'			SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A02G.KeyID ORDER BY _A02G.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, W0110G
'+'				, A02G01
'+'				, A02G02
'+'				, A02G05
'+'				, A02G06
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, A02GRKeyID
'+'			FROM WF_D_'+@OperID+'_A02G _A02G
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02G.KeyID
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02G.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02G WHERE KeyID = _main.KeyID AND A02G02 = ''2'')
'+'			AND A02G01 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A02G.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
	  END
	    
	    IF @CHILD = 'W0A'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W0A WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
		   	
'+'		   	INSERT INTO dbo.WF_D_'+@OperID+'_W0A (KeyID, DispOrder, IsLastRow, 
'+'	  	W0AW0110G, W0AA02G01, W0AA02G02, W0AA02G05, W0AA02G06, W0AB0001, W0APersonID, W0AUnitName, W0AA02GRKeyID)
'+'
'+'	    	SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A02G.KeyID ORDER BY _A02G.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, W0110G
'+'				, A02G01
'+'				, A02G02
'+'				, A02G05
'+'				, A02G06
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, A02GRKeyID
'+'			FROM WF_D_'+@OperID+'_A02G _A02G
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02G.KeyID
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02G.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02G WHERE KeyID = _main.KeyID AND A02G02 LIKE ''3%'')
'+'			AND A02G01 >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A02G.KeyID AND IsLastRow = 1)'
			EXEC(@SQL)
	    END
	    
	    IF @CHILD = 'W0B'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W0B WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
		   	
'+'		   	INSERT INTO dbo.WF_D_'+@OperID+'_W0B (KeyID, DispOrder, IsLastRow,  
'+'	    	W0BA0141A, W0BA0141B, W0BA0141BQ, W0BA0219, W0BA0221, W0BA0284, W0BA0291, W0BA0291T, W0BA0292, W0BA0293, 
'+'	    	W0BA0293G, W0BA02RKeyID, W0BB0001, W0BPersonID, W0BUnitName, W0BW0110G, W0BAge)
'+'	    	
'+'			SELECT
'+'			    _main.KeyID
'+'			    , row_number() OVER(PARTITION BY _A02.KeyID ORDER BY _A02.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, A0141A
'+'				, _A08.A0801B
'+'				, _A08Q.A0801B A0801BQ
'+'				, A0219
'+'				, A0221
'+'				, A0284
'+'				, A0291
'+'				, A0291T
'+'				, A0292
'+'				, A0293
'+'				, A0293G
'+'				, A02RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, W0110G
'+'				, substring(CONVERT(VARCHAR, datediff(M, A0111, A0291T)/12), 1, 2)  AS Age
'+'			FROM WF_D_'+@OperID+'_A02 _A02
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 _A08 ON _A08.KeyID = _main.KeyID AND _A08.DispOrder = (
'+'				SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A08 _A08Q WHERE KeyID = _main.KeyID 
'+'				AND A0807 = (SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 WHERE KeyID=_A08Q.KeyID AND A0807 < _A02.A0291T))
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 AS _A08Q ON _main.KeyID=_A08Q.KeyID AND _A08Q.DispOrder = (
'+'				SELECT MAX(DispOrder) FROM WF_D_'+@OperID+'_A08 AS b WHERE b.KeyID=_A08Q.KeyID AND b.A0807 =
'+'					(SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 AS a WHERE a.KeyID=b.KeyID AND A0837=''1''))
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02 WHERE KeyID = _main.KeyID AND A0284 = ''1'' )
'+'			AND A0291T >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _A02.KeyID AND IsLastRow = 1)
'+'			AND (isnull(A0292, -2) = 
'+'				CASE 
'+'					 WHEN _Main.PClassID = ''00001'' AND A0292 = 3 THEN 3
'+'					 WHEN _Main.PClassID = ''00001'' AND A0292 = 24 THEN 24
'+'					 WHEN _Main.PClassID = ''00001'' THEN -1
'+'					 ELSE A0292
'+'				END) '
			EXEC(@SQL)
			--PRINT @SQL
		END
		
	    IF @InnerChangeCount>0
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W0B WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
'+'			AND KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_GWYInnerChange)
		   	
'+'		   	INSERT INTO dbo.WF_D_'+@OperID+'_W0B (KeyID, DispOrder, IsLastRow,  
'+'	    	W0BA0141A, W0BA0141B, W0BA0141BQ, W0BA0219, W0BA0221, W0BA0284, W0BA0291, W0BA0291T, W0BA0292, W0BA0293, 
'+'	    	W0BA0293G, W0BA02RKeyID, W0BB0001, W0BPersonID, W0BUnitName, W0BW0110G, W0BAge)
'+'	    	
'+'			SELECT
'+'			    _main.KeyID KeyID
'+'			    , row_number() OVER(PARTITION BY _A02.KeyID ORDER BY _A02.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, A0141A W0BA0141A
'+'				, _A08.A0801B W0BA0141B
'+'				, _A08Q.A0801B W0BA0141BQ
'+'				, A0219 W0BA0219
'+'				, A0221 W0BA0221
'+'				, ''1'' W0BA0284
'+'				, ''9'' W0BA0291
'+'				, (SELECT GWYInnerChange07 FROM WF_D_'+@OperID+'_GWYInnerChange WHERE KeyID = _main.KeyID AND GWYInnerChange99 = ''02'') W0BA0291T
'+'				, ''21'' W0BA0292
'+'				, A0293 W0BA0293
'+'				, ''2'' W0BA0293G
'+'				, A02RKeyID
'+'				, B0001
'+'				, SourceKeyID
'+'				, dbo.FN_CodeItemIDToName(''N'', B0001) C_N_B0001
'+'				, (SELECT GWYInnerChange97 FROM WF_D_'+@OperID+'_GWYInnerChange WHERE KeyID = _main.KeyID AND GWYInnerChange99 = ''02'') W0BW0110G
'+'				, substring(CONVERT(VARCHAR, datediff(M, A0111, A0291T)/12), 1, 2)  AS Age
'+'			FROM WF_D_'+@OperID+'_A02 _A02
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _A02.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 _A08 ON _A08.KeyID = _main.KeyID AND _A08.DispOrder = (
'+'				SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A08 _A08Q WHERE KeyID = _main.KeyID 
'+'				AND A0807 = (SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 WHERE KeyID=_A08Q.KeyID))
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 AS _A08Q ON _main.KeyID=_A08Q.KeyID AND _A08Q.DispOrder = (
'+'				SELECT MAX(DispOrder) FROM WF_D_'+@OperID+'_A08 AS b WHERE b.KeyID=_A08Q.KeyID AND b.A0807 =
'+'					(SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 AS a WHERE a.KeyID=b.KeyID AND A0837=''1''))
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _A02.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A02 WHERE KeyID = _main.KeyID )
'+'			AND _main.KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_GWYInnerChange)
'	
			EXEC(@SQL)
			PRINT @SQL
		END
		
		IF @CHILD = 'W0C'
	    BEGIN
	    	SET @SQL = 
'	    	DELETE FROM WF_D_'+@OperID+'_W0C WHERE KeyID IN (SELECT KeyID FROM WF_D_'+@OperID+'_Main WHERE JobID = '''+@JobID+''' AND JobDataID = '+ convert(VARCHAR(4), @JobDataID) +')
		   	
'+'			INSERT INTO dbo.WF_D_'+@OperID+'_W0C (KeyID, DispOrder, IsLastRow, W0CA0801B, W0CA0801BQ, W0CAge, 
'+'			W0CGWYZWZJ01, W0CGWYZWZJ02, W0CGWYZWZJ09, W0CGWYZWZJ10, W0CGWYZWZJ11, W0CW0110G, W0CGWYZWZJRKeyID, W0CPersonID, W0CB0001, W0CGWYZWZJ02T)

'+'			SELECT 
'+'				_main.KeyID
'+'			    , row_number() OVER(PARTITION BY _GWYZWZJ.KeyID ORDER BY _GWYZWZJ.DispOrder) AS DispOrder
'+'			    , 1 AS IsLastRow
'+'				, _A08.A0801B
'+'				, _A08Q.A0801B A0801BQ
'+'				, substring(CONVERT(VARCHAR, datediff(M, A0111, GWYZWZJ02T)/12), 1, 2)  AS W0CAge
'+'				, (
'+'				 CASE GWYZWZJ01
'+'			         WHEN ''11'' THEN ''9901''
'+'			         WHEN ''12'' THEN ''9902''
'+'			         WHEN ''13'' THEN ''9903''
'+'			         WHEN ''14'' THEN ''9904''
'+'			         WHEN ''15'' THEN ''9905''
'+'			         WHEN ''16'' THEN ''9906''
'+'			         WHEN ''17'' THEN ''9907''
'+'			         WHEN ''18'' THEN ''9908''
'+'			         WHEN ''19'' THEN ''9909''
'+'			         WHEN ''1A'' THEN ''990A''
'+'			         WHEN ''1B'' THEN ''990B''
'+'			         WHEN ''1C'' THEN ''990C''
'+'			     END) GWYZWZJ01
'+'				, GWYZWZJ02
'+'				, GWYZWZJ09
'+'				, GWYZWZJ10
'+'				, GWYZWZJ11
'+'				, W0110G
'+'				, GWYZWZJRKeyID
'+'				, SourceKeyID
'+'				, B0001
'+'				, GWYZWZJ02T
'+'			FROM WF_D_'+@OperID+'_GWYZWZJ _GWYZWZJ
'+'			LEFT JOIN WF_D_'+@OperID+'_Main _main ON _main.KeyID = _GWYZWZJ.KeyID
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 _A08 ON _A08.KeyID = _main.KeyID AND _A08.DispOrder = (
'+'				SELECT max(DispOrder) FROM WF_D_'+@OperID+'_A08 _A08Q WHERE KeyID = _main.KeyID
'+'				AND A0807 = (SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 WHERE KeyID=_A08Q.KeyID AND A0807 < _GWYZWZJ.GWYZWZJ02T))
'+'			LEFT JOIN WF_D_'+@OperID+'_A08 AS _A08Q ON _main.KeyID=_A08Q.KeyID AND _A08Q.DispOrder = (
'+'				SELECT MAX(DispOrder) FROM WF_D_'+@OperID+'_A08 AS b WHERE b.KeyID=_A08Q.KeyID AND b.A0807 =
'+'					(SELECT MAX(A0807) FROM WF_D_'+@OperID+'_A08 AS a WHERE a.KeyID=b.KeyID AND A0837=''1''))
'+'			WHERE _main.JobID = '''+@JobID+''' AND _main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) +'
'+'			AND _GWYZWZJ.DispOrder = (SELECT max(DispOrder) FROM WF_D_'+@OperID+'_GWYZWZJ WHERE KeyID = _main.KeyID AND GWYZWZJ09 IN (''26'', ''27'') AND GWYZWZJ01 LIKE ''1%'')
'+'			AND GWYZWZJ02T >= (SELECT A2907 FROM WF_D_'+@OperID+'_A29 WHERE KeyID = _main.KeyID AND IsLastRow = 1)'
	    	EXEC(@SQL)
			PRINT @SQL
	    END
	    			
		IF @InnerChangeCount>0 AND (SELECT COUNT(1) FROM dbo.Get_StringSplit('W04, W05, W06, W07, W08, W09, W0A, W0C', ',') WHERE ch = @CHILD) > 0
    	BEGIN
    		
    		SET @SQL = 
'
			UPDATE _'+@CHILD+' SET '+@CHILD+'W0110G = (SELECT GWYInnerChange97 FROM WF_D_'+@OperID+'_GWYInnerChange 
'+'				WHERE KeyID = _'+@CHILD+'.KeyID AND GWYInnerChange99 = ''02'')
'+'			FROM WF_D_'+@OperID+'_'+@CHILD+' _'+@CHILD+' WHERE _'+@CHILD+'.KeyID IN (
'+'				SELECT _Main.KeyID FROM WF_D_'+@OperID+'_GWYInnerChange _GWYInnerChange
'+'				LEFT JOIN WF_D_'+@OperID+'_Main _Main ON _Main.KeyID = _GWYInnerChange.KeyID
'+'				WHERE _Main.JobID = '''+@JobID+''' AND _Main.JobDataID = '+ convert(VARCHAR(4), @JobDataID)
    		
    		IF @CHILD = 'W04'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W04.W04A1521 < year(_GWYInnerChange.GWYInnerChange07)) '
    		END
    		
    		IF @CHILD = 'W05'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W05.W05A1111 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W06'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W06.W06A1407 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W07'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W07.W07A0243 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W08'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W08.W08A0265 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W09'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W09.W09A02G01 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W0A'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W0A.W0AA02G01 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		IF @CHILD = 'W0C'
    		BEGIN
    			SET @SQL = @SQL + ' AND _W0C.W0CGWYZWZJ02 < _GWYInnerChange.GWYInnerChange07) '
    		END
    		
    		EXEC (@SQL)
    		PRINT @SQL
    	END
	    --PRINT @CHILD
	    FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD;
	END
	CLOSE CURSOR_SETCHILD;
	DEALLOCATE CURSOR_SETCHILD;
END
GO

