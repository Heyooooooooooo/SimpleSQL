



# <center>编译原理上机报告</center>











##  <center>《DBMS的设计与实现》</center>









#### 学号：15030140048

#### 姓名：胡雄伟

#### 手机：18292830487

#### 邮箱：xwHuNichols(a.t.)163.com

















##### <center>完成时间：2018年6月11日</center>









### 1 项目概况

#### 1.1 基本目标

​	设计并实现一个DBMS原型系统，可以接受基本的SQL语句，对其进行词法分析、语法分析，然后解释执行SQL语句，完成对数据库文件的相应操作，实现DBMS的基本功能。

#### 1.2 完成情况

实现了以下SQL语句及功能：

```
CREATE DATABASE		 创建数据库
USE DATABASE		 选择数据库
CREATE TABLE		 创建表
SHOW TABLES			 显示表名
INSERT				 插入元组
SELECT				 查询元组
UPDATE				 更新元组
DELETE				 删除元组
DROP TABLE			 删除表
DROP DATABASE		 删除数据库
EXIT				退出系统
```

支持数据类型：INT、CHAR(N)

### 2 项目实现方案

#### 2.1 逻辑结构与物理结构

###### 逻辑结构

在数据库物理设计上，增加了数据库元数据 (database.dat) 和表元数据 (tables.dat)

database.dat

| 数据库名称  |
| ------ |
| HXW    |
| TQ     |
| ...... |

tables.dat

| 表名      | 字段     | 类型     | 长度     |
| ------- | ------ | ------ | ------ |
| Student | Sno    | CHAR   | 10     |
| Course  | Cno    | CHAR   | 5      |
| SC      | Grade  | INT    | 4      |
| ......  | ...... | ...... | ...... |

###### 物理结构

DBMS主目录信息如下：

![DBMS主目录](E:\资料\编译原理\上机\DBMS主目录.PNG)

其中，database.dat中的内容（包含已创建的数据库信息，分别对应相应的子目录）如下：

![database](E:\资料\编译原理\上机\database.PNG)

HQ数据库对应的目录信息（包含Student,Course,SC三个表，分别存放于Student.txt,Course.txt,SC.txt中）如下：

![HQ](E:\资料\编译原理\上机\HQ.PNG)

其中，tables.dat中的内容如下：

![tables](E:\资料\编译原理\上机\tables.PNG)

###### 优缺点

该数据库保存和读取信息十分方便，也便于根据文件内容调试程序。但该数据库无法存储大量且复杂的数据信息，优化率低下，只适合用于了解编译原理及操作系统的知识。

#### 2.2 语法结构与数据结构

###### CREATE

① CREATE 语句的产生式语法结构

```yacas
createsql:CREATE TABLE table '(' fieldsdefinition ')' ';'
		|CREATE DATABASE ID ';'
```

② 非终结符数据结构

```c
//create语法树的类型----------------------------------------------------
char *yych;	//字面量
struct Createfieldsdef *cfdef_var;//字段定义
struct fieldType *fT;//type定义
struct Createstruct *cs_var;//整个create语句
//create语句中的字段定义-------------------------------------------------
struct Createfieldsdef{		
	char		*field;		//字段名称
	enum TYPE	type;		//字段类型
	int			length;		//字段长度
	struct	Createfieldsdef	*next_fdef;//下一字段
};
//type字段定义-----------------------------------------------------------
enum TYPE {CHAR,INT};
struct fieldType{
	enum TYPE	type;		//字段类型
	int			length;		//字段长度
};
//create语法树根节点-----------------------------------------------------
struct Createstruct{		
	char *table;				  //基本表名称
	struct	Createfieldsdef *fdef;//字段定义
};
```

③ 实例

CREATE TABLE Student ( Sno CHAR(10) , Sname CHAR (10) , Ssex CHAR (2) , INT ) ;

对应的数据结构如下图：

![create数据结构](E:\资料\编译原理\上机\create数据结构.jpg)

###### USE

① USE 语句的产生式语法结构

```yacas
usesql:USE ID ';'
```

② 实例

USE HQ;

###### SHOW

① SHOW 语句的产生式语法结构

```yacas
showsql:SHOW DATABASE ';'
	   |SHOW TABLES ';'
```

② 实例

SHOW TABLES;

###### SELECT

① SELECT 语句的产生式语法结构

```yacas
selectsql:SELECT fields_star FROM tables ';'
		|SELECT fields_star FROM tables WHERE conditions ';'
```

② 非终结符数据结构

```c
//select语法树的类型------------------------------------------------------
	char op;                             //运算符
	struct Selectedfields	*sf_var;	//所选字段
	struct Selectedtables	*st_var;	//所选表格
	struct Conditions	*cons_var;		//条件语句
	struct Selectstruct	*ss_var;		//整个select语句
//select条件-------------------------------------------------------------
struct Conditions{
	struct Conditions *left;//左部条件
	struct Conditions *right;//右部条件
	char comp_op;		/* 'a'是and, 'o'是or, '<' , '>' , '=', ‘!='  */
	int type;			/* 0是字段，1是字符串，2是整数 */
	char *value;		/* 根据type存放字段名、字符串或整数 */
	char *table;		/* NULL或表名 */
}; 
//select语句中选中的字段-------------------------------------------------
struct	Selectedfields{
	char 	*table;			//字段所属表
	char 	*field;			//字段名称
	struct 	Selectedfields	*next_sf;//下一个字段
};
//select语句中选中的表---------------------------------------------------
struct	Selectedtables{
	char	  *table;		//基本表名称
	struct  Selectedtables  *next_st;	//下一个表
};
//select语法树的根节点---------------------------------------------------
struct	Selectstruct{
	struct Selectedfields 	*sf;	//所选字段
	struct Selectedtables	*st;	//所选基本表
	struct Conditions		*cons;	//条件
};
```

③ 实例

SELECT Sno,Sname FROM Student WHERE Ssex='M' AND Sage=20;

对应的数据结构如下图：

![SELECT数据结构](E:\资料\编译原理\上机\SELECT数据结构.jpg)

###### INSERT

① INSER 语句的产生式语法结构

```yacas
insertsql:INSERT INTO table VALUES '(' values ')' ';'
		|INSERT INTO table '(' values ')' VALUES '(' values ')' ';'
```

② 非终结符数据结构

```c
//insert的语法树的类型---------------------------------------------------
	struct insertValue *is_val;
//insert语法树根节点-----------------------------------------------------
struct insertValue {
    char *value;				  //插入值
    struct insertValue *next_Value;//下一插入值
};
```

③ 实例

INSERT INTO Student VALUES ( '089' , 'TQ' , 'F' , 21 );

对应的数据结构如下图：

![insert数据结构](E:\资料\编译原理\上机\insert数据结构.jpg)

###### DELETE

① DELETE 语句的产生式语法结构

```yacas
deletesql:DELETE FROM table ';'
		|DELETE FROM table WHERE conditions ';'
```

② 实例

DELETE FROM Student;

###### DROP

① DROP 语句的产生式语法结构

```yacas
dropsql:DROP TABLE ID ';'
	   |DROP DATABASE ID ';'
```

② 实例

DROP TABLE Student;

###### UPDATE

① UPDATE 语句的产生式语法结构

```yacas
updatesql:UPDATE table SET sets ';'
		|UPDATE table SET sets WHERE conditions ';'
```

② 非终结符数据结构

```c
//update的语法树的类型-------------------------------------------------------
	struct Setstruct *s_var;
	//set语法树根节点--------------------------------------------------------
struct Setstruct{
    char *field;					//需更改字段
    char *value;					//更改值
	struct Setstruct *next_sf;		//需更改下一字段
};
```

③ 实例

UPDATE Student SET Sage=19,Sname='NIHAO';

对应的数据结构如下图：

![update数据结构](E:\资料\编译原理\上机\update数据结构.jpg)

###### EXIT

① EXIT 语句的产生式语法结构

```
exitsql:EXIT ';'
```

② 实例

EXIT;

#### 2.3 执行流程

##### CREATE

###### void createDB()

① 函数说明：创建指定名字的数据库文件夹

② 输入参数：无

③ 输出参数：无

④ 执行流程：用户输入创建数据库的SQL语句，调用_mkdir()函数在当前工作目录下的sql文件夹内创建用户指定的数据库文件夹。

###### void createTable(struct Createstruct *cs_root)

① 函数说明：创建指定名字的表文件(.txt)

② 输入参数：struct Createstruct *cs_root：create语法树的数据结构

③ 输出参数：无

④ 执行流程：用户输入创建表的SQL语句，在选定的数据库目录下创建指定的表文件(.txt)，并且将创建表的字段内容添加到元数据中 ( tables.dat )。

##### USE

###### void useDB()

① 函数说明：进入指定数据库文件夹内

② 输入参数：无

③ 输出参数：无

④ 执行流程：用户输入使用数据库的SQL语句，调用_chdir( )函数将工作目录转到指定数据库的目录下。

##### SHOW

###### void getDB()

① 函数说明：获得所有已创建数据库的名字

② 输入参数：无

③ 输出参数：无

④ 执行流程：用户输入展示数据库的SQL语句，从元数据 ( database.dat )中读出并打印所有已创建的数据库的名字。

###### void getTable()

① 函数说明：获得所有已创建表的内容

② 输入参数：无

③ 输出参数：无

④ 执行流程：用户输入展示表的SQL语句，从选定的数据库的元数据 ( tables.dat ) 中读出所有已创建表的内容。

##### SELECT

###### void selectCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot,struct Conditions *conditionRoot)

① 函数说明：打印指定表内所有满足条件的元组信息

② 输入参数：struct Selectedfields *fieldRoot      所查询的字段的根节点

​			struct Selectedtables *tableRoot    所查询的表的根节点

​			struct Conditions *conditionRoot   查询条件的根节点

③ 输出参数：无

④ 执行流程：用户输入带条件查询的SQL语句，将所有需要查询的表的所有元组做笛卡尔乘积，相当于合并成一张大表，然后每次将一行元组值传入Condition( )函数内判断是否满足条件，返回1满足条件打印相关信息，返回0不满足条件。

###### void selectNoCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot)

① 函数说明：打印指定表内所有元组信息

② 输入参数：struct Selectedfields *fieldRoot      所查询的字段的根节点

​			struct Selectedtables *tableRoot    所查询的表的根节点

③ 输出参数：无

④ 执行流程：用户输入不带条件的SQL语句，若查询字段的根节点为NULL，说明需要查询表内所有信息，将字段值以及所有元组值存放于数组中并打印；若查询字段为特定字段，将特定字段和特定字段下的元组值存放于数组中，并打印。

###### int CDTSearch(struct Conditions *conditionRoot, int totField, char allField\[][100], char value\[][100])

① 函数说明：递归函数，判断当前输入的元组是否满足condition条件

② 输入参数：struct Conditions *conditionRoot	查询条件根节点

​			int totField						所有字段个数

​			char allField\[][100]				保存所有字段值

​			char value\[][100]					保存当前行的元组值

③ 输出参数：返回1，表示当前输入的元组满足条件；返回0，不满足

④ 执行流程：将条件根节点，所有字段个数，所有字段值及元组值传入此函数，该函数根据条件根节点所在的链表判断（若conditions的判断符是'a'，则递归return (conditionRoot->left, ....)&&(conditionRoot->Right, ....) ；若conditions的判断符是'o'，则递归return (conditionRoot->left, ....)||(conditionRoot->Right, ....)）：若condition左中右部分分别是字段、'='、字段，则是判断同字段下的属性值是否相同，在函数内先匹配到左部的table1.field1，然后匹配右部的table2.field2，再判断各自字段下的属性值是否相同，返回相应的值；若condition左中右部分分别是字段、'='|'>'|'<'|'!'、字面量，则判断各自字段下的属性值是否满足条件，并返回相应的值。

###### void hanle(int read_line\[],int count_value\[],int all_table,int index)

① 函数说明：笛卡尔乘积算法

② 输入参数：int read_line\[ i ]		当前所读到表 i 的行号，从1开始

​			int count_value\[ i ]	当前表 i 的最大行号

​			int all_table			表格个数

​			int index				当前所指的表，从0开始

③ 输出参数：无

④ 执行流程：

Ⅰ 将最后一个表当前所读到的行号加1；

Ⅱ 判断当前读到的行号是否大于最大行号，大于则表示当前表读完，将read_line[ index ]=1,重新指向第一行将index--，让它指向前一个表，使read_line[ index ]++,向下移一行；

Ⅱ.1 若insex>=0，说明还有表未读完，则进行递归

Ⅱ.2 将index重新指向最后一个表

###### void freeCdt(struct Conditions *conditionRoot)

① 函数说明：释放创建的条件根节点指针

② 输入参数：struct Conditions *conditionRoot	条件根节点

③ 输出参数：无

④ 执行流程：若当前节点不为空，让当前根节点指向它的下一节点，释放当前节点。

##### INSERT

###### void insertOrder(char *tableName,struct insertValue *values)

① 函数说明：按建表时字段的既定顺序插入元组

② 输入参数：char *tableName				字符指针，值为需要插入的表名

​			struct insertValue *values		插入元组的根节点

③ 输出参数：无

④ 执行流程：找到需要插入元组的表，打开相应的文件(.txt)，将插入的元组值保存在数组内，在文件末尾添加进去，若暂时未想好填的值，可填NULL。

###### void insertNoOder(char *tableName,struct insertValue *valuesNames,struct insertValue *values)

① 函数说明：按用户指定的字段顺序插入元组

② 输入参数：char *tableName					字符指针，值为需要插入的表名

​			struct insertValue *valuesNames	用户给定顺序的字段根节点

​			struct insertValue *values			用户插入元组的根节点

③ 输出参数：无

④ 执行流程：找到需要插入元组的表，打开相应的文件(.txt)，将指定顺序的字段和插入的元组值分别保存在不同的数组内，并匹配到表内的所有字段，将元组值插入到相应的位置下。若用户给定的字段数少于表内所有字段数，则会在未指定的字段下补NULL，插入过程中，指定字段和插入元组个数必须相同。

##### DELETE

###### void deleteAll(char *tableName)

① 函数说明：删除指定的表内数据

② 输入参数：char *tableName		字符指针，值为删除数据的表名

③ 输出参数：无

④ 执行流程：找到需要删除数据的表，打开相应的文件(.txt)，将表内字段数和字段值读出，存放在数组内，调用fopen函数(参数为'w')，将表重写，写入字段数和字段值。

###### void deleteCdt(char *tableName,struct Conditions *conditionRoot)

① 函数说明：删除表内满足条件的字段的元组

② 输入参数：char *tableName					字符指针，值为删除数据的表名

​			struct Conditions *conditionRoot	删除条件的根节点

③ 输出参数：无

④ 执行流程：找到需要删除数据的表，打开相应的文件(.txt)，读出所有内容，对表进行重写入字段数和字段值，每次将表内一行数据存放于数组内，将其传入condition函数，判断当前行是否满足删除条件，满足则不写入当前行的数据，否则写入。

##### DROP

###### void dropDB()

① 函数说明：删除指定的数据库文件夹

② 输入参数：无

③ 输出参数：无

④ 执行流程：调用system函数，参数为 "rd  databaseName"，其中databaseName是数据库文件夹的名字。

###### void dropTable(char *tableName)

① 函数说明：删除指定的表文件

② 输入参数：char *tableName		字符指针，其值为要删除的表名字

③ 输出参数：无

④ 执行流程：调用system函数，参数为 "del tableName"，其中tableName为要删除的表文件名。

##### UPDATE

###### void updateAll(char *tableName,struct Setstruct *setRoot)

① 函数说明：更新所有选定字段的元组值

② 输入参数：char *tableName				字符指针，其值为要更新的表名字

​			struct Setstruct *setRoot		要更新的字段的根节点

③ 输出参数：无

④ 执行流程：打开需要更新的表文件(.txt)，将所有内容读出，保存在数组内，并将表文件重写，需要更新的字段值及更新的元组值分别保存在数组内，匹配更新字段和原表内字段，将更新值写入到相应位置下，否则写入旧值。

###### void updateCdt(char *tableName,struct Setstruct *setRoot,struct Conditions *conditionRoot)

① 函数说明：更新所有满足条件选定字段的元组值

② 输入参数：char *tableName					字符指针，其值为要更新的表名字

​			struct Setstruct *setRoot			要更新的字段的根节点

​			struct Conditions *conditionRoot	更新条件根节点

③ 输出参数：无

④ 执行流程：打开需要更新的表文件(.txt)，将所有内容读出，保存在数组内，并将表文件重写，需要更新的字段值及更新的元组值分别保存在数组内，每次读入一行数据，传入condition函数，判断是否满足更新条件，若满足则匹配更新字段和原表内字段，将更新值写入到相应位置下，否则写入旧值。

##### EXIT

###### exit(0)

#### 2.4 测试功能

##### 测试1

###### 输入：

CREATE DATABASE HQ;

CREATE DATABASE HXW;

creaTE DAtaBaSE tq;

###### 输出：

![CRAETE DATABASE](E:\资料\编译原理\上机\CRAETE DATABASE.PNG)



##### 测试2

###### 输入：SHOW DATABASES;

###### 输出：

![SHOW测试](E:\资料\编译原理\上机\SHOW测试.PNG)

![CREATE DATABASE()](E:\资料\编译原理\上机\CREATE DATABASE().PNG)

##### 测试3

###### 输入：

USE HQ;

###### 输出：

![USE测试](E:\资料\编译原理\上机\USE测试.PNG)



##### 测试4

###### 输入：

create table Student (Sno CHAR(10),Sname CHAR(10),Ssex CHAR(2),Sage INT);

CREATE TABLE Course (Cno CHAR(5),Cname CHAR(10),Cpno CHAR(5),Ccredit INT);
create TABLE SC (Sno CHAR(10),Cno CHAR(5),Grade INT);
create table test (Sdept CHAR(10),Cpno CHAR(5),NUMBER INT);

###### 输出：

![CREATE_TABLE](E:\资料\编译原理\上机\CREATE_TABLE.PNG)

![CREATE TABLE](E:\资料\编译原理\上机\CREATE TABLE.PNG)

##### 测试6

###### 输入：

show tables;

###### 输出：

![SHOW TABLES](E:\资料\编译原理\上机\SHOW TABLES.PNG)



##### 测试7

###### 输入：

drop table test;

###### 输出：

![DROP TABLE](E:\资料\编译原理\上机\DROP TABLE.PNG)

![DROP_table](E:\资料\编译原理\上机\DROP_table.PNG)

##### 测试8

###### 输入：

insert into Student values ('121','LY','M',20);

###### 输出：

![insert1](E:\资料\编译原理\上机\insert1.PNG)



##### 测试9

###### 输入：

INSERT INTO Student (Ssex,Sage,Sno,Sname) values('F',19,'124','LC');

###### 输出：

![insert2](E:\资料\编译原理\上机\insert2.PNG)



##### 测试10

###### 输入：

update SC set Grade=55 where Sno='125' AND Cno='3';

###### 输出：

![update1](E:\资料\编译原理\上机\update1.PNG)



##### 测试11

###### 输入：

update Course set Ccredit=4 where Cno='1' OR Cno='3' OR Cno ='5';

###### 输出：

![update2](E:\资料\编译原理\上机\update2.PNG)



##### 测试12

###### 输入：

select * from Student;

###### 输出：

![select1](E:\资料\编译原理\上机\select1.PNG)



##### 测试13

###### 输入：

select Sno from Student where ((Sage=17));

###### 输出：

![select2](E:\资料\编译原理\上机\select2.PNG)



##### 测试14

###### 输入：

select Student.Sno,Student.Sname,SC.Cno,Course.Cname from Student,SC,Course where Student.Sno=SC.Sno AND Course.Cno=SC.Cno AND Student.Sage=17 AND SC.Grade>70;

###### 输出：

![select3](E:\资料\编译原理\上机\select3.PNG)



##### 测试15

###### 输入：

delete from SC;

###### 输出：

![delete1](E:\资料\编译原理\上机\delete1.PNG)

![delete1_1](E:\资料\编译原理\上机\delete1_1.PNG)



##### 测试16

###### 输入：

delete from Student where Ssex='M' AND Sage=17;

###### 输出：

![delete2](E:\资料\编译原理\上机\delete2.PNG)

![delete2_2](E:\资料\编译原理\上机\delete2_2.PNG)



##### 测试17

###### 输入：

exit;

###### 输出：

![exit](E:\资料\编译原理\上机\exit.PNG)



### 3总结与未来工作

#### 3.1 未完成功能

在创建表，书写查询条件时，表名、字段名以及查询值不能以数字开头。

#### 3.2 未来实现方案

在lex中定义新的ID，该ID可以由大写字母，小写字母和数字混合组成。

