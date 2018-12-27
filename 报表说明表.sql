UPDATE dbo.BB_JointTriaExplain
SET KeyID = (replace(newid(), '-',''))



INSERT INTO dbo.BB_JointTriaExplain (Title, ItemID, Parent, Explain, DispOrder, Year, KeyID)
VALUES (
'', 
'001002004', 
'001002', 
'<p style="text-indent:36px;line-height:40px">
    <span style="font-size:16px;font-family:仿宋_GB2312">（<span>4</span>）公务员表 “实施公务员法机关调入<span>-</span>公开遴选”（行<span>1</span><span style="background: yellow;background:yellow">列<span>18</span></span>）数据，“调到实施公务员法机关<span>-</span>公开遴选”（行<span>1</span><span style="background: yellow;background:yellow">列<span>40</span></span>）数据。</span>
</p>', 
'7', 
'2018',
replace(newid(), '-',''))


SELECT * FROM BB_JointTriaExplain WHERE Year = '2018' ORDER BY DispOrder


