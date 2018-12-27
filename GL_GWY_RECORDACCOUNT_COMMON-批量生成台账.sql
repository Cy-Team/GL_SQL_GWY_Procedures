ALTER PROCEDURE [dbo].[GL_GWY_RECORDACCOUNT_COMMON](@SET_CHILD VARCHAR(100), @WHERE_SQLSTR VARCHAR(MAX))
AS
BEGIN
	-- 声明变量
	DECLARE
		@CHILD VARCHAR(30) = ''
		, @COUNT INT = 0
				
	-- 创建条件临时表
	EXEC dbo.GS_SMCheckDropTable #WHERE_SCOPE_PERSONID
	CREATE TABLE #WHERE_SCOPE_PERSONID
	(
		PersonID VARCHAR(36)
	)
	-- 把人员范围插入临时表
	INSERT INTO #WHERE_SCOPE_PERSONID EXEC (@WHERE_SQLSTR)
	--SELECT * FROM #WHERE_SCOPE_PERSONID
	
	-- 是否存在乡镇记录
	SELECT @COUNT = COUNT(1) FROM Data_Person_GWYINNERCHANGE WHERE PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
	
	DECLARE
		CURSOR_SETCHILD CURSOR
	    FOR (SELECT ch FROM dbo.Get_StringSplit(@SET_CHILD, ','))
	    
	OPEN CURSOR_SETCHILD; 
	FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--1. A30-W02 退出信息集
		IF @CHILD = 'A30'
		BEGIN
			-- 更新A30空RKeyID的记录
			UPDATE dbo.Data_Person_A30 SET A30RKeyID = Replace(Newid(),'-','')
			WHERE A30RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			-- 删除人员本单位的台帐
			DELETE _W02 FROM Data_DB21_W02 _W02 WHERE W02B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W02.W02PersonID)
			AND W02PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			-- 插入人员本单位的台帐
			INSERT INTO dbo.Data_DB21_W02 (KeyID, DispOrder, IsLastRow, W02A0215A, W02A0219, W02A0221, 
			W02A0284, W02A0291, W02A0292, W02A0293, W02A0293G, W02A3001, W02A3004, W02B0001, W02UnitName, 
			W02W0110G, W02PersonID, W02A30RKeyID)
			
			SELECT
			    replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A30.PersonID ORDER BY _A30.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
			    ,A0215A
			    ,A0219
			    ,A0221
			    ,A0284
			    ,A0291
			    ,A0292
			    ,A0293
			    ,A0293G
			    ,A3001
			    ,A3004
			    ,B0001
			    , NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
			    ,W0110G
			    ,_A01.PersonID
			    ,A30RKeyID
			FROM Data_Person_A30 _A30
			LEFT JOIN Data_Person_A01 _A01 ON _A30.PersonID = _A01.PersonID
			LEFT JOIN Data_Person_A02 _A02 ON _A02.PersonID = _A01.PersonID AND _A02.IsLastRow = 1
			WHERE --A30RKeyID NOT IN (SELECT W02A30RKeyID FROM Data_DB21_W02) --AND A30RKeyID IS NOT NULL 
			_A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			IF @COUNT > 0
			BEGIN
				
				INSERT INTO dbo.Data_DB21_W02 (KeyID, DispOrder, IsLastRow, W02A0215A, W02A0219, W02A0221, 
				W02A0284, W02A0291, W02A0292, W02A0293, W02A0293G, W02A3001, W02A3004, W02B0001, W02UnitName, 
				W02W0110G, W02PersonID, W02A30RKeyID)
				
				SELECT
				    replace(newid(), '-', '') AS KeyID
				    , row_number() OVER(PARTITION BY _change.PersonID ORDER BY _change.DispOrder) AS DispOrder
				    , 1 AS IsLastRow
				    , GWYInnerChange10
				    , GWYInnerChange12
				    , GWYInnerChange09
				    , NULL
				    , NULL
				    , NULL
				    , NULL
				    , NULL
				    , GWYInnerChange08
				    , GWYInnerChange07
				    , GWYInnerChange01
				    , NULL --,dbo.FN_CodeItemIDToName('N', GWYInnerChange01) C_N_GWYInnerChange01
				    , GWYInnerChange97
				    , PersonID
				    , replace(newid(), '-', '') AS RKeyID
				FROM Data_Person_GWYINNERCHANGE _change
				WHERE PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID) AND GWYInnerChange99 = '02'
			END
			
			--SELECT * FROM Data_DB21_W02 WHERE W02PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
		END
		
		--2. A29-W03 进入信息集
		IF @CHILD = 'A29'
		BEGIN
			UPDATE dbo.Data_Person_A29 SET A29RKeyID = Replace(Newid(),'-','')
			WHERE A29RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W03 FROM Data_DB21_W03 _W03 WHERE W03B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W03.W03PersonID)
			AND W03PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W03 (KeyID, DispOrder, IsLastRow, W03A0215A, W03A0219, W03A0221, 
			W03A2907, W03A2911, W03B0001, W03UnitName, W03W0110G, W03PersonID, W03A29RKeyID)
			
			SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A29.PersonID ORDER BY _A29.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
			    ,A0215A
			    ,A0219
			    ,A0221
			    ,A2907
			    ,A2911
			    ,B0001
			    , NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
			    ,W0110G
			    ,_A01.PersonID
			    ,A29RKeyID
			FROM Data_Person_A29 _A29
			LEFT JOIN Data_Person_A01 _A01 ON _A29.PersonID = _A01.PersonID
			LEFT JOIN Data_Person_A02 _A02 ON _A02.PersonID = _A01.PersonID AND _A02.IsLastRow = 1
			WHERE --A29RKeyID NOT IN (SELECT W03A29RKeyID FROM Data_DB21_W03) --AND A29RKeyID IS NOT NULL 
			_A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			IF @COUNT > 0
			BEGIN
			
				INSERT INTO dbo.Data_DB21_W03 (KeyID, DispOrder, IsLastRow, W03A0215A, W03A0219, W03A0221, 
			W03A2907, W03A2911, W03B0001, W03UnitName, W03W0110G, W03PersonID, W03A29RKeyID)
				
				SELECT
				    replace(newid(), '-', '') AS KeyID
				    , row_number() OVER(PARTITION BY _change.PersonID ORDER BY _change.DispOrder) AS DispOrder
				    , 1 AS IsLastRow
				    , GWYInnerChange06
				    , GWYInnerChange11
				    , GWYInnerChange05
				    , GWYInnerChange03
				    , GWYInnerChange04
				    , GWYInnerChange01
				    , NULL --, dbo.FN_CodeItemIDToName('N', GWYInnerChange01) C_N_GWYInnerChange01
				    , GWYInnerChange97
				    , PersonID
				    , replace(newid(), '-', '') AS RKeyID
				FROM Data_Person_GWYINNERCHANGE _change
				WHERE PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID) AND GWYInnerChange99 = '01'
			END
			--SELECT * FROM Data_DB21_W03 WHERE W03PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
		END
		
		--3. A15-W04 考核信息台帐
		IF @CHILD = 'A15'
		BEGIN
			UPDATE dbo.Data_Person_A15 SET A15RKeyID = Replace(Newid(),'-','')
			WHERE A15RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W04 FROM Data_DB21_W04 _W04 WHERE W04B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W04.W04PersonID)
			AND W04PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)

			INSERT INTO dbo.Data_DB21_W04 (KeyID, DispOrder, IsLastRow, 
			W04A1501G, W04A1517, W04A1519G, W04A1521, W04A1521G, W04A1522, W04A1522G, W04B0001, W04UnitName, 
			W04PersonID, W04A15RKeyID, W04W0110G)
			
			SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A15.PersonID ORDER BY _A15.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
			 	, A1501G
			 	, A1517
			 	, A1519G
			 	, A1521
			 	, A1521G
			 	, A1522
			 	, A1522G
			 	, B0001
			 	, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
			 	, _A01.PersonID
			 	, A15RKeyID
			 	, W0110G
			FROM Data_Person_A15 _A15
			LEFT JOIN Data_Person_A01 _A01 ON _A15.PersonID = _A01.PersonID
			--LEFT JOIN Data_Person_A02 _A02 ON _A02.PersonID = _A01.PersonID AND _A02.IsLastRow = 1
			WHERE A1521 >= (SELECT year(A2907) FROM Data_Person_A29 WHERE PersonID = _A15.PersonID AND IsLastRow = 1)
			---AND A15RKeyID NOT IN (SELECT W04A15RKeyID FROM Data_DB21_W04) --AND A15RKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W04 WHERE W04PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W04W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W04PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W04 _TZ, Data_Person_A01 _A01 WHERE _TZ.W04PersonID = _A01.PersonID
				AND _TZ.W04B0001 = _A01.B0001 AND _TZ.W04PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W04PersonID = PersonID
					AND _TZ.W04A1521 < year(GWYInnerChange07)) 
			END
		END
		
		--4. A11-W05 培训信息台帐
		IF @CHILD = 'A11'
		BEGIN
			UPDATE dbo.Data_Person_A11 SET A11RKeyID = Replace(Newid(),'-','')
			WHERE A11RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W05 FROM Data_DB21_W05 _W05 WHERE W05B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W05.W05PersonID)
			AND W05PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W05 (KeyID, DispOrder, IsLastRow, 
			W05A0219, W05A0221, W05A1101, W05A1104, W05A1107, W05A1111, W05A1111G, W05A1114, W05A1121, 
			W05A1127, W05A1131, W05A1132G, W05A1133G, W05A1134G, W05A1151, W05A11RKeyID, W05B0001, W05PersonID, 
			W05UnitName, W05W0110G)
			
			SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A11.PersonID ORDER BY _A11.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, A11SX
				, A11ZW
				, A1101
				, A1104
				, A1107
				, A1111
				, A1111G
				, A1114
				, A1121
				, A1127
				, A1131
				, A1132G
				, A1133G
				, A1134G
				, A1151
				, A11RKeyID
				, B0001
				, _A11.PersonID
				, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
				, W0110G
			FROM Data_Person_A11 _A11
			LEFT JOIN Data_Person_A01 _A01 ON _A11.PersonID = _A01.PersonID
			--LEFT JOIN Data_Person_A02 _A02 ON _A02.PersonID = _A01.PersonID AND _A02.DispOrder = (
				--SELECT isnull(max(DispOrder), 0) FROM Data_Person_A02 WHERE A0243 < _A11.A1107 AND PersonID = _A02.PersonID) 
			WHERE A1107 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A11.PersonID AND IsLastRow = 1)
			--AND A11RKeyID NOT IN (SELECT W05A11RKeyID FROM Data_DB21_W05) --AND A11RKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W05 WHERE W05PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W05W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W05PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W05 _TZ, Data_Person_A01 _A01 WHERE _TZ.W05PersonID = _A01.PersonID
				AND _TZ.W05B0001 = _A01.B0001 AND _TZ.W05PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W05PersonID = PersonID
					AND _TZ.W05A1111 < GWYInnerChange07) 
			END
		END
		
		--5. A14-W06 奖惩信息台帐
		IF @CHILD = 'A14'
		BEGIN
		   	UPDATE dbo.Data_Person_A14 SET A14RKeyID = Replace(Newid(),'-','')
			WHERE A14RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W06 FROM Data_DB21_W06 _W06 WHERE W06B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W06.W06PersonID)
			AND W06PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W06 (KeyID, DispOrder, IsLastRow, W06A1404A, W06A1404B, W06A1407, W06A1411A, W06A1414,
			 W06A1415, W06A1419G, W06A1424, W06A1428, W06A14RKeyID, W06B0001, W06PersonID, W06UnitName, W06W0110G)
			
			SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A14.PersonID ORDER BY _A14.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, A1404A
				, A1404B
				, A1407
				, A1411A
				, A1414
				, A1415
				, A1419G
				, A1424
				, A1428
			  	, _A14.A14RKeyID
			  	, B0001
			  	, _A01.PersonID
			  	, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
			  	, W0110G
			FROM Data_Person_A14 _A14
			LEFT JOIN Data_Person_A01 _A01 ON _A14.PersonID = _A01.PersonID
			--LEFT JOIN Data_Person_A02 _A02 ON _A02.PersonID = _A01.PersonID AND _A02.IsLastRow = 1
			WHERE _A14.A1407 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A14.PersonID AND IsLastRow = 1)
		 	--AND _A14.A14RKeyID NOT IN (SELECT W06A14RKeyID FROM Data_DB21_W06) 
		 	AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W06 WHERE W06PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W06W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W06PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W06 _TZ, Data_Person_A01 _A01 WHERE _TZ.W06PersonID = _A01.PersonID
				AND _TZ.W06B0001 = _A01.B0001 AND _TZ.W06PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W06PersonID = PersonID
					AND _TZ.W06A1407 < GWYInnerChange07) 
			END
		END
		
		--6. A02-W07 晋升信息台帐
		IF @CHILD = 'A02'
		BEGIN
			UPDATE dbo.Data_Person_A02 SET A02RKeyID = Replace(Newid(),'-','')
			WHERE A02RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W07 FROM Data_DB21_W07 _W07 WHERE W07B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W07.W07PersonID)
			AND W07PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W07 (KeyID, DispOrder, IsLastRow, 
	    	W07Age, W07A0141A, W07A0801B, W07A0801BQ, W07A0243, W07A0251, W07A0251D, W07A0243G, W07A0221, W07A0219, 
	    	W07A02RKeyID, W07B0001, W07PersonID, W07UnitName, W07W0110G)
	        SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A02.PersonID ORDER BY _A02.DispOrder) AS DispOrder
			  , 1 AS IsLastRow
				, substring(CONVERT(VARCHAR, datediff(M, A0111, A0243)/12), 1, 2)  AS Age
				, A0141A
				, _A08.A0801B
				, _A08Q.A0801B W07A0801BQ
				, A0243
				, A0251
				, A0251D
				, A0243G
				, A0221
				, A0219
				, A02RKeyID
				, B0001
				, _A01.PersonID
				, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
				, W0110G
			FROM Data_Person_A02 _A02
			LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02.PersonID
			LEFT JOIN Data_Person_A08 _A08 ON _A08.PersonID = _A01.PersonID AND _A08.DispOrder = (
				SELECT max(DispOrder) FROM Data_Person_A08 _A08Q WHERE PersonID = _A01.PersonID
				AND A0807 = (SELECT MAX(A0807) FROM Data_Person_A08 WHERE PersonID=_A08Q.PersonID AND A0807 < _A02.A0243))
			LEFT JOIN Data_Person_A08 _A08Q ON _A01.PersonID = _A08Q.PersonID AND _A08Q.DispOrder = (
				SELECT MAX(DispOrder) FROM Data_Person_A08 AS b WHERE b.PersonID=_A08Q.PersonID AND b.A0807 =
					(SELECT MAX(A0807) FROM Data_Person_A08 AS a WHERE a.PersonID=b.PersonID AND A0837='1'))
			WHERE _A02.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02 WHERE PersonID = _A01.PersonID AND A0251 IN ('26', '27'))
			AND A0243 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A02.PersonID AND IsLastRow = 1)
			--AND A02RKeyID NOT IN (SELECT W07A02RKeyID FROM Data_DB21_W07) --AND A02RKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W07 WHERE W07PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W07W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W07PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W07 _TZ, Data_Person_A01 _A01 WHERE _TZ.W07PersonID = _A01.PersonID
				AND _TZ.W07B0001 = _A01.B0001 AND _TZ.W07PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W07PersonID = PersonID
					AND _TZ.W07A0243 < GWYInnerChange07) 
			END
		END
		
		--7. A02-W08 降职信息集
		IF @CHILD = 'A02'
		BEGIN
			UPDATE dbo.Data_Person_A02 SET A02RKeyID = Replace(Newid(),'-','')
			WHERE A02RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W08 FROM Data_DB21_W08 _W08 WHERE W08B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W08.W08PersonID)
			AND W08PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W08 (KeyID, DispOrder, IsLastRow, 
	    	W08A0219, W08A0221, W08A02RKeyID, W08B0001, W08PersonID, W08UnitName, W08W0110G, W08A0265)
	    	SELECT
			 replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A02.PersonID ORDER BY _A02.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, A0219
				, A0221
				, A02RKeyID
				, B0001
				, _A01.PersonID
				, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
				, W0110G
				, A0265
			FROM Data_Person_A02 _A02
			LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02.PersonID
			WHERE _A02.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02 WHERE PersonID = _A01.PersonID AND A0271 = 2)	
			AND A0265 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A02.PersonID AND IsLastRow = 1)
			--AND A02RKeyID NOT IN (SELECT W08A02RKeyID FROM Data_DB21_W08) --AND A02RKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W08 WHERE W08PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W08W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W08PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W08 _TZ, Data_Person_A01 _A01 WHERE _TZ.W08PersonID = _A01.PersonID
				AND _TZ.W08B0001 = _A01.B0001 AND _TZ.W08PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W08PersonID = PersonID
					AND _TZ.W08A0265 < GWYInnerChange07) 
			END
		END
		
		--8. A02G-W09 免职信息集
		IF @CHILD = 'A02G'
		BEGIN
			UPDATE dbo.Data_Person_A02G SET A02GRKeyID = Replace(Newid(),'-','')
			WHERE A02GRKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W09 FROM Data_DB21_W09 _W09 WHERE W09B0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W09.W09PersonID)
			AND W09PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			INSERT INTO dbo.Data_DB21_W09 (KeyID, DispOrder, IsLastRow,
	    	W09W0110G, W09A02G01, W09A02G02, W09A02G05, W09A02G06, W09B0001, W09PersonID, W09UnitName, W09A02GRKeyID)
	    	
			SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A02G.PersonID ORDER BY _A02G.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, W0110G
				, A02G01
				, A02G02
				, A02G05
				, A02G06
				, B0001
				, _A01.PersonID
				, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
				, A02GRKeyID
			FROM Data_Person_A02G _A02G
			LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02G.PersonID
			WHERE _A02G.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02G WHERE PersonID = _A01.PersonID AND A02G02 = 2)
			AND A02G01 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A02G.PersonID AND IsLastRow = 1)
			--AND A02GRKeyID NOT IN (SELECT W09A02GRKeyID FROM Data_DB21_W09) --AND A02GRKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W09 WHERE W09PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W08W0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W08PersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W08 _TZ, Data_Person_A01 _A01 WHERE _TZ.W08PersonID = _A01.PersonID
				AND _TZ.W08B0001 = _A01.B0001 AND _TZ.W08PersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W08PersonID = PersonID
					AND _TZ.W08A0265 < GWYInnerChange07) 
			END
		END
		
		--9. A02G-W0A 辞去领导职务信息集
		IF @CHILD = 'A02G'
		BEGIN
			UPDATE dbo.Data_Person_A02G SET A02GRKeyID = Replace(Newid(),'-','')
			WHERE A02GRKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W0A FROM Data_DB21_W0A _W0A WHERE W0AB0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W0A.W0APersonID)
			AND W0APersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
				
		   	INSERT INTO dbo.Data_DB21_W0A (KeyID, DispOrder, IsLastRow, 
	  		W0AW0110G, W0AA02G01, W0AA02G02, W0AA02G05, W0AA02G06, W0AB0001, W0APersonID, W0AUnitName, W0AA02GRKeyID)
	    	SELECT
			     replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _A02G.PersonID ORDER BY _A02G.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, W0110G
				, A02G01
				, A02G02
				, A02G05
				, A02G06
				, B0001
				, _A01.PersonID
				, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
				, A02GRKeyID
			FROM Data_Person_A02G _A02G
			LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02G.PersonID
			WHERE _A02G.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02G WHERE PersonID = _A01.PersonID AND A02G02 LIKE '3%')
			AND A02G01 >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A02G.PersonID AND IsLastRow = 1)
			--AND A02GRKeyID NOT IN (SELECT W0AA02GRKeyID FROM Data_DB21_W0A) --AND A02GRKeyID IS NOT NULL 
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W0A WHERE W0APersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W0AW0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W0APersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W0A _TZ, Data_Person_A01 _A01 WHERE _TZ.W0APersonID = _A01.PersonID
				AND _TZ.W0AB0001 = _A01.B0001 AND _TZ.W0APersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W0APersonID = PersonID
					AND _TZ.W0AA02G01 < GWYInnerChange07) 
			END
		END
		
		--10. A02-W0B 交流信息集
		IF @CHILD = 'A02'
		BEGIN
			UPDATE dbo.Data_Person_A02 SET A02RKeyID = Replace(Newid(),'-','')
			WHERE A02RKeyID IS NULL AND PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			DELETE _W0B FROM Data_DB21_W0B _W0B WHERE W0BB0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W0B.W0BPersonID)
			AND W0BPersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--乡镇台帐区分交流
			IF @COUNT > 0
			BEGIN
				INSERT INTO dbo.Data_DB21_W0B (KeyID, DispOrder, IsLastRow,  
		    	W0BA0141A, W0BA0141B, W0BA0141BQ, W0BA0219, W0BA0221, W0BA0284, W0BA0291, W0BA0291T, W0BA0292, W0BA0293, 
		    	W0BA0293G, W0BA02RKeyID, W0BB0001, W0BPersonID, W0BUnitName, W0BW0110G, W0BAge)
		    	
				SELECT
				     replace(newid(), '-', '') AS KeyID
				    , row_number() OVER(PARTITION BY _A02.PersonID ORDER BY _A02.DispOrder) AS DispOrder
				    , 1 AS IsLastRow
					, A0141A W0BA0141A
					, _A08.A0801B W0BA0141B
					, _A08Q.A0801B W0BA0141BQ
					, A0219 W0BA0219
					, A0221 W0BA0221
					, '1' W0BA0284
					, '9' W0BA0291
					, (SELECT GWYInnerChange07 FROM Data_Person_GWYINNERCHANGE WHERE PersonID = _A01.PersonID AND GWYInnerChange99 = '02') W0BA0291T
					, '21' W0BA0292
					, A0293 W0BA0293
					, '2' W0BA0293G
					, A02RKeyID
					, B0001
					, _A01.PersonID
					, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
					, (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE WHERE PersonID = _A01.PersonID AND GWYInnerChange99 = '02') W0BW0110G
					, substring(CONVERT(VARCHAR, datediff(M, A0111, A0291T)/12), 1, 2)  AS Age
				FROM Data_Person_A02 _A02
				LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02.PersonID
				LEFT JOIN Data_Person_A08 _A08 ON _A08.PersonID = _A01.PersonID AND _A08.DispOrder = (
					SELECT max(DispOrder) FROM Data_Person_A08 _A08Q WHERE PersonID = _A01.PersonID
					AND A0807 = (SELECT MAX(A0807) FROM Data_Person_A08 WHERE PersonID=_A08Q.PersonID AND A0807 < _A02.A0291T))
				LEFT JOIN Data_Person_A08 _A08Q ON _A01.PersonID = _A08Q.PersonID AND _A08Q.DispOrder = (
					SELECT MAX(DispOrder) FROM Data_Person_A08 AS b WHERE b.PersonID=_A08Q.PersonID AND b.A0807 =
						(SELECT MAX(A0807) FROM Data_Person_A08 AS a WHERE a.PersonID=b.PersonID AND A0837='1'))
				WHERE _A02.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02 WHERE PersonID = _A01.PersonID )
				AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			END
			ELSE
			BEGIN
			
			   	INSERT INTO dbo.Data_DB21_W0B (KeyID, DispOrder, IsLastRow,  
		    	W0BA0141A, W0BA0141B, W0BA0141BQ, W0BA0219, W0BA0221, W0BA0284, W0BA0291, W0BA0291T, W0BA0292, W0BA0293, 
		    	W0BA0293G, W0BA02RKeyID, W0BB0001, W0BPersonID, W0BUnitName, W0BW0110G, W0BAge)
		    	
				SELECT
				     replace(newid(), '-', '') AS KeyID
				    , row_number() OVER(PARTITION BY _A02.PersonID ORDER BY _A02.DispOrder) AS DispOrder
				    , 1 AS IsLastRow
					, A0141A
					, _A08.A0801B
					, _A08Q.A0801B W0BA0141BQ
					, A0219
					, A0221
					, A0284
					, A0291
					, A0291T
					, A0292
					, A0293
					, A0293G
					, A02RKeyID
					, B0001
					, _A01.PersonID
					, NULL --, dbo.FN_CodeItemIDToName('N', B0001) C_N_B0001
					, W0110G
					, substring(CONVERT(VARCHAR, datediff(M, A0111, A0291T)/12), 1, 2)  AS Age
				FROM Data_Person_A02 _A02
				LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _A02.PersonID
				LEFT JOIN Data_Person_A08 _A08 ON _A08.PersonID = _A01.PersonID AND _A08.DispOrder = (
					SELECT max(DispOrder) FROM Data_Person_A08 _A08Q WHERE PersonID = _A01.PersonID
					AND A0807 = (SELECT MAX(A0807) FROM Data_Person_A08 WHERE PersonID=_A08Q.PersonID AND A0807 < _A02.A0291T))
				LEFT JOIN Data_Person_A08 _A08Q ON _A01.PersonID = _A08Q.PersonID AND _A08Q.DispOrder = (
					SELECT MAX(DispOrder) FROM Data_Person_A08 AS b WHERE b.PersonID=_A08Q.PersonID AND b.A0807 =
						(SELECT MAX(A0807) FROM Data_Person_A08 AS a WHERE a.PersonID=b.PersonID AND A0837='1'))
				WHERE _A02.DispOrder = (SELECT max(DispOrder) FROM Data_Person_A02 WHERE PersonID = _A01.PersonID AND A0284 = 1 )
				AND A0291T >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A02.PersonID AND IsLastRow = 1)
				--AND A02RKeyID NOT IN (SELECT W0BA02RKeyID FROM Data_DB21_W0B) --AND A02RKeyID IS NOT NULL 
				AND (isnull(A0292, -2) = 
					CASE 
						 WHEN _A01.PClassID = '00001' AND A0292 = 3 THEN 3
						 WHEN _A01.PClassID = '00001' AND A0292 = 24 THEN 24
						 WHEN _A01.PClassID = '00001' THEN -1
						 ELSE A0292
					END) 
				AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			END
			
			--SELECT * FROM Data_DB21_W0B WHERE W0BPersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
		END
		
		--10. GWYZWZJ-W0C 职级晋升
		IF @CHILD = 'GWYZWZJ'
		BEGIN
			DELETE _W0C FROM Data_DB21_W0C _W0C WHERE W0CB0001 = (
				SELECT B0001 FROM Data_Person_A01 WHERE PersonID = _W0C.W0CPersonID)
			AND W0CPersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
				
			INSERT INTO dbo.Data_DB21_W0C (KeyID, DispOrder, IsLastRow, W0CA0801B, W0CA0801BQ, W0CAge,
			 W0CGWYZWZJ01, W0CGWYZWZJ02, W0CGWYZWZJ09, W0CGWYZWZJ10, W0CGWYZWZJ11, W0CW0110G, W0CGWYZWZJRKeyID, 
			 W0CPersonID, W0CB0001, W0CGWYZWZJ02T)

			SELECT 
				replace(newid(), '-', '') AS KeyID
			    , row_number() OVER(PARTITION BY _GWYZWZJ.PersonID ORDER BY _GWYZWZJ.DispOrder) AS DispOrder
			    , 1 AS IsLastRow
				, _A08.A0801B
				, _A08Q.A0801B A0801BQ
				, substring(CONVERT(VARCHAR, datediff(M, A0111, GWYZWZJ02T)/12), 1, 2)  AS W0CAge
				, (
				 CASE GWYZWZJ01
			         WHEN '11' THEN '9901'
			         WHEN '12' THEN '9902'
			         WHEN '13' THEN '9903'
			         WHEN '14' THEN '9904'
			         WHEN '15' THEN '9905'
			         WHEN '16' THEN '9906'
			         WHEN '17' THEN '9907'
			         WHEN '18' THEN '9908'
			         WHEN '19' THEN '9909'
			         WHEN '1A' THEN '990A'
			         WHEN '1B' THEN '990B'
			         WHEN '1C' THEN '990C'
			     END) GWYZWZJ01
				, GWYZWZJ02
				, GWYZWZJ09
				, GWYZWZJ10
				, GWYZWZJ11
				, W0110G
				, GWYZWZJRKeyID
				, _A01.PersonID
				, B0001
				, GWYZWZJ02T
			FROM Data_Person_GWYZWZJ _GWYZWZJ
			LEFT JOIN Data_Person_A01 _A01 ON _A01.PersonID = _GWYZWZJ.PersonID
			LEFT JOIN Data_Person_A08 _A08 ON _A08.PersonID = _A01.PersonID AND _A08.DispOrder = (
				SELECT max(DispOrder) FROM Data_Person_A08 _A08Q WHERE PersonID = _A01.PersonID
				AND A0807 = (SELECT MAX(A0807) FROM Data_Person_A08 WHERE PersonID=_A08Q.PersonID AND A0807 < _GWYZWZJ.GWYZWZJ02T))
			LEFT JOIN Data_Person_A08 _A08Q ON _A01.PersonID=_A08Q.PersonID AND _A08Q.DispOrder = (
				SELECT MAX(DispOrder) FROM Data_Person_A08 AS b WHERE b.PersonID=_A08Q.PersonID AND b.A0807 =
					(SELECT MAX(A0807) FROM Data_Person_A08 AS a WHERE a.PersonID=b.PersonID AND A0837='1'))
			WHERE _GWYZWZJ.DispOrder = (SELECT max(DispOrder) FROM Data_Person_GWYZWZJ WHERE PersonID = _A01.PersonID AND GWYZWZJ09 IN ('26', '27') AND GWYZWZJ01 LIKE '1%')
			AND GWYZWZJ02T >= (SELECT A2907 FROM Data_Person_A29 WHERE PersonID = _A01.PersonID AND IsLastRow = 1)
			AND _A01.PersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			
			--SELECT * FROM Data_DB21_W0C WHERE W0CPersonID IN (SELECT PersonID FROM #WHERE_SCOPE_PERSONID)
			IF @COUNT > 0
			BEGIN
				UPDATE _TZ SET W0CW0110G = (SELECT GWYInnerChange97 FROM Data_Person_GWYINNERCHANGE 
					WHERE PersonID = _TZ.W0CPersonID AND GWYInnerChange99 = '02')
				FROM Data_DB21_W0C _TZ, Data_Person_A01 _A01 WHERE _TZ.W0CPersonID = _A01.PersonID
				AND _TZ.W0CB0001 = _A01.B0001 AND _TZ.W0CPersonID IN (
					SELECT PersonID FROM Data_Person_GWYINNERCHANGE WHERE _TZ.W0CPersonID = PersonID
					AND _TZ.W0CGWYZWZJ02 < GWYInnerChange07) 
			END
		END
		
		PRINT @CHILD
	    FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD;
	END
	CLOSE CURSOR_SETCHILD;
	DEALLOCATE CURSOR_SETCHILD;
END
GO

