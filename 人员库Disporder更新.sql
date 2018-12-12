UPDATE _A01 SET DispOrder= _tbl._newOrder
FROM Data_Person_A01 _A01, (SELECT row_number() OVER(ORDER BY DispOrder) AS _newOrder, PersonID FROM Data_Person_A01) _tbl
WHERE _A01.PersonID = _tbl.PersonID