DECLARE
		@CHILD VARCHAR(10) = ''
		, @SETCHILD VARCHAR(100) = 'W02, W03, W04, W05, W06, W07, W08, W09, W0A, W0B, W0C'
		, @SQL NVARCHAR(2000) = ''
		, @COUNT INT = 0
		, @OperID VARCHAR(100) = 'CDGWYPsnEdit18'
		, @TZCHILD VARCHAR(100) = ''
		, @STATUS INT = -1
		, @Msg VARCHAR(300) = ''
        , @State INT = 0
		, @JobID VARCHAR(36) = 'BEA71F7721CB4B50A7E8388FB97DC9D5'
		, @JobDataID INT = 1
	DECLARE
		CURSOR_SETCHILD CURSOR
	    FOR (SELECT ch FROM dbo.Get_StringSplit(@SETChild, ','))
	OPEN CURSOR_SETCHILD; --���α�
	FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @TZCHILD = 
		CASE 
			WHEN @CHILD = 'W02' THEN 'A30'
			WHEN @CHILD = 'W03' THEN 'A29'
			WHEN @CHILD = 'W04' THEN 'A15'
			WHEN @CHILD = 'W05' THEN 'A11'
			WHEN @CHILD = 'W06' THEN 'A14'
			WHEN @CHILD = 'W07' THEN 'A02'
			WHEN @CHILD = 'W08' THEN 'A02'
			WHEN @CHILD = 'W09' THEN 'A02G'
			WHEN @CHILD = 'W0A' THEN 'A02G'
			WHEN @CHILD = 'W0B' THEN 'A02'
			WHEN @CHILD = 'W0C' THEN 'GWYZWZJ'
		END 
		
		SET @SQL = '
SELECT @COUNT = COUNT(1) FROM WF_D_'+ @OperID +'_'+ @CHILD +' _TZ
LEFT JOIN WF_D_'+ @OperID +'_Main _Main ON _Main.KeyID = _TZ.KeyID
WHERE _Main.JobID = '''+ @JobID +''' AND _Main.JobDataID = '+ convert(VARCHAR(4), @JobDataID) + '
AND (_TZ.'+ @CHILD +'PersonID IS NULL OR _TZ.'+ @CHILD +'B0001 IS NULL OR _TZ.'+ @CHILD + @TZCHILD +'RKeyID IS NULL
OR _TZ.'+ @CHILD +'PersonID <> _Main.SourceKeyID)'
		
		EXEC sp_executesql @SQL, N'@COUNT int out', @COUNT out 
		
		--PRINT @SQL
		--PRINT @COUNT
		IF @COUNT > 0
		BEGIN
			SET @STATUS = 1
		END
		
		--PRINT @CHILD
 		FETCH NEXT FROM CURSOR_SETCHILD INTO @CHILD;
	END
	CLOSE CURSOR_SETCHILD;
	DEALLOCATE CURSOR_SETCHILD;

--PRINT @STATUS
IF @STATUS > 0
BEGIN
    SET @State = -1
    SET @Msg = '���翪С����������ù��ͣ������������ࣩ��̨����Ϣ���ݳ�Ϣ�Ƿ����ݣ��뷵��ҳ������Ԥ������̨�ʡ�������룺#00006'
    --���ؽ��
    SELECT @State State,@Msg Msg
END
