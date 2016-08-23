CREATE PROCEDURE usp_TableToClass
/*
Created by Cade Bryant.
Generates C# class code for a table
and fields/properties for each column.

Run as "Results to Text" or "Results to File" (not Grid)

Example: EXEC usp_TableToClass 'MyTable'
*/

@table_name SYSNAME

AS

SET NOCOUNT ON

DECLARE @temp TABLE
(
sort INT,
code TEXT
)

INSERT INTO @temp
SELECT 1, 'public class ' + @table_name + CHAR(13) + CHAR(10) + '{'

INSERT INTO @temp
SELECT 2, CHAR(13) + CHAR(10) + '#region Constructors' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 3, CHAR(9) + 'public ' + @table_name + '()'
+ CHAR(13) + CHAR(10) + CHAR(9) + '{'
+ CHAR(13) + CHAR(10) + CHAR(9) + '}'

INSERT INTO @temp
SELECT 4, '#endregion' + CHAR(13) + CHAR(10)

INSERT INTO @temp
SELECT 5, '#region Private Fields' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 6, CHAR(9) + 'private ' +
CASE
WHEN DATA_TYPE LIKE '%CHAR%' THEN 'string '
WHEN DATA_TYPE LIKE '%INT%' THEN 'int '
WHEN DATA_TYPE LIKE '%DATETIME%' THEN 'DateTime '
WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[] '
WHEN DATA_TYPE = 'BIT' THEN 'bool '
WHEN DATA_TYPE LIKE '%TEXT%' THEN 'string '
ELSE 'object '
END + '_' + COLUMN_NAME + ';' + CHAR(9)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 7, '#endregion' +
CHAR(13) + CHAR(10)

INSERT INTO @temp
SELECT 8, '#region Public Properties' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 9, CHAR(9) + 'public ' +
CASE
WHEN DATA_TYPE LIKE '%CHAR%' THEN 'string '
WHEN DATA_TYPE LIKE '%INT%' THEN 'int '
WHEN DATA_TYPE LIKE '%DATETIME%' THEN 'DateTime '
WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[] '
WHEN DATA_TYPE = 'BIT' THEN 'bool '
WHEN DATA_TYPE LIKE '%TEXT%' THEN 'string '
ELSE 'object '
END + COLUMN_NAME +
CHAR(13) + CHAR(10) + CHAR(9) + '{' +
CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'get { return _' + COLUMN_NAME + '; }' +
CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) +
'set { _' + COLUMN_NAME + ' = value; }' +
CHAR(13) + CHAR(10) + CHAR(9) + '}'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 10, '#endregion' +
CHAR(13) + CHAR(10) + '}'


INSERT INTO @temp 
SELECT 11, '#for constructor rdr' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 12, CHAR(9) + 'if (!rdr.IsDBNull(rdr.GetOrdinal("' + COLUMN_NAME +'"))) this.' + COLUMN_NAME+ '= ' +
CASE
WHEN DATA_TYPE LIKE '%INT%' THEN '(int)'
WHEN DATA_TYPE LIKE '%DATETIME%' THEN '(DateTime)'
--WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[]'
WHEN DATA_TYPE = 'BIT' THEN '(bool)'
ELSE ''
END
+'rdr["'+ COLUMN_NAME+'"];' + CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 13, '#endregion' +
CHAR(13) + CHAR(10) + '}'


INSERT INTO @temp
SELECT 14, '#for constructor row' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 15, CHAR(9) + 'if (!row.IsNull("' + COLUMN_NAME +'")) this.' + COLUMN_NAME+ '= ' +
CASE
WHEN DATA_TYPE LIKE '%INT%' THEN '(int)'
WHEN DATA_TYPE LIKE '%DATETIME%' THEN '(DateTime)'
--WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[]'
WHEN DATA_TYPE = 'BIT' THEN '(bool)'
ELSE ''
END
+ 'row["'+ COLUMN_NAME+'"];' + CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 16, '#endregion' +
CHAR(13) + CHAR(10) + '}'


INSERT INTO @temp
SELECT 17, '#for constructor partial' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 18, CHAR(9) + 'this.' + COLUMN_NAME+ '= NQS.DataHelper.GetDataFromRow'+
CASE
WHEN DATA_TYPE LIKE '%CHAR%' THEN '<string>'
WHEN DATA_TYPE LIKE '%INT%' THEN '<int>'
WHEN DATA_TYPE LIKE '%DATETIME%' THEN '<DateTime>'
--WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[]'
WHEN DATA_TYPE = 'BIT' THEN '<bool>'
WHEN DATA_TYPE LIKE '%TEXT%' THEN '<string>'
ELSE ''
END
 + '("'+ COLUMN_NAME+'", row);'+ CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 19, '#endregion' +
CHAR(13) + CHAR(10) + '}'


INSERT INTO @temp
SELECT 20, '#column names'+ CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 21, CHAR(9) + COLUMN_NAME+ ','+ CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 22, '#endregion' +
CHAR(13) + CHAR(10) + '}'

SELECT code FROM @temp
ORDER BY sort

