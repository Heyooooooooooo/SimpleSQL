%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.

Date: 2018年4月23日
****************************************************************************/

#include "mylexer.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<direct.h>
#include<io.h>

char database[100]={0};	//数据库名称
char rootDir[100]={0};	//文件保存路径
enum TYPE {INT,CHAR};	//字段可用类型
//create语句中的字段定义-------------------------------------------------
struct Createfieldsdef{		
	char		*field;			//字段名称
	enum TYPE	type;			//字段类型
	int			length;		//字段长度
	struct	Createfieldsdef	*next_fdef;	//下一字段
};
//type字段定义-----------------------------------------------------------
struct fieldType{
	enum TYPE	type;			//字段类型
	int		length;			//字段长度
};
//create语法树根节点-----------------------------------------------------
struct Createstruct{		
	char *table;				  //基本表名称
	struct	Createfieldsdef *fdef;//字段定义
};
//insert语法树根节点-----------------------------------------------------
struct insertValue {
    char *value;				  //插入值
    struct insertValue *next_Value;		  //下一插入值
};
//select条件-------------------------------------------------------------
struct Conditions{
	struct Conditions *left;		//左部条件
	struct Conditions *right;		//右部条件
	char comp_op;				/* 'a'是and, 'o'是or, '<' , '>' , '=', ‘!='  */
	int type;				/* 0是字段，1是字符串，2是整数 */
	char *value;				/* 根据type存放字段名、字符串或整数 */
	char *table;				/* NULL或表名 */
}; 
//select语句中选中的字段-------------------------------------------------
struct	Selectedfields{
	char 	*table;				//字段所属表
	char 	*field;				//字段名称
	struct 	Selectedfields	*next_sf;	//下一个字段
};
//select语句中选中的表---------------------------------------------------
struct	Selectedtables{
	char	  *table;			//基本表名称
	struct  Selectedtables  *next_st;	//下一个表
};
//select语法树的根节点---------------------------------------------------
struct	Selectstruct{
	struct Selectedfields 	*sf;		//所选字段
	struct Selectedtables	*st;		//所选基本表
	struct Conditions	*cons;		//条件
};
//set语法树根节点--------------------------------------------------------
struct Setstruct{
    char *field;					//需更改字段
    char *value;					//更改值
    struct Setstruct *next_sf;				//需更改下一字段
};

void createDB();
void getDB();
void useDB();
void dropDB();
void createTable(struct Createstruct *cs_root);
void getTable();
void dropTable(char *tableName);
void insertOrder(char *tableName,struct insertValue *values);
void insertNoOrder(char *tableName,struct insertValue *valuesNames,struct insertValue *values);
int CdtSearch(struct Conditions *conditionRoot, int totField, char allField[][100], char value[][100]);
void freeCdt(struct Conditions *conditionRoot);
void updateAll(char *tableName,struct Setstruct *setRoot);
void updateCdt(char *tableName,struct Setstruct *setRoot,struct Conditions *conditionRoot);
void selectNoCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot);
void selectCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot,struct Conditions *conditionRoot);
void deleteAll(char *tableName);
void deleteCdt(char *tableName,struct Conditions *conditionRoot);
void handle(int read_line[],int count_value[],int all_table,int index);


%}

//-----------------------------------------------------------------------
%union{
	//属于create语法树的类型--------------------
	char op;
	char *yych;				//字面量
	struct Createfieldsdef *cfdef_var;	//字段定义
	struct fieldType *fT;			//type定义
	struct Createstruct *cs_var;		//整个create语句
	//属于insert的语法树------------------------
	struct insertValue *is_val;
	//属于select语法树的类型--------------------
	struct Selectedfields	*sf_var;	//所选字段
	struct Selectedtables	*st_var;	//所选表格
	struct Conditions	*cons_var;	//条件语句
	struct Selectstruct	*ss_var;	//整个select语句
	//属于update的语法树------------------------
	struct Setstruct *s_var;
}
%term CREATE SHOW USE DATABASES DATABASE TABLE TABLES CHAR INT SELECT FROM WHERE OR AND QUOTE INSERT INTO VALUES UPDATE SET DELETE DROP EXIT
%term <yych> ID NUMBER
%nonterm <op> comp_op
%nonterm <yych> table field
%nonterm <fT> type
%nonterm <cfdef_var> fieldsdefinition field_type
%nonterm <cs_var> createsql
%nonterm <is_val> values value
%nonterm <sf_var> fields_star  table_fields  table_field
%nonterm <st_var> tables
%nonterm <cons_var> condition  conditions comp_left comp_right
%nonterm <ss_var> selectsql
%nonterm <s_var> set sets

%left OR
%left AND
//%left "+","-"
//%left "*","/"
%%

//-----------------------------------------------------------------------
start		:statements;
statements	:statements statement|statement;
statement	:createsql|selectsql|usesql|showsql|insertsql|deletesql|dropsql|updatesql|exitsql;
createsql:CREATE TABLE table '(' fieldsdefinition ')' ';'
	  {
		$$=(struct Createstruct *)malloc(sizeof(struct Createstruct));
		$$->table=$3;
		$$->fdef=$5;
		createTable($$);
	  }
	 |CREATE DATABASE ID ';'
	  {
		strcpy(database,$3);
		createDB();
	  };
	  table:ID
	  {
		$$=$1;
	  };
	  fieldsdefinition:field_type
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1->field;
		$$->type=$1->type;
		$$->length=$1->length;
		$$->next_fdef=NULL;
	  }
	 |field_type ',' fieldsdefinition
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1->field;
		$$->type=$1->type;
		$$->length=$1->length;
		$$->next_fdef=$3;
	  };
	  field_type:field type
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1;
		$$->type=$2->type;
		$$->length=$2->length;
	  };
	  field:ID
	  {
		$$=$1;
	  };
	  type:CHAR '(' NUMBER ')'
	  {
		$$=(struct fieldType *)malloc(sizeof(struct fieldType));
		$$->type=CHAR;
		$$->length=atoi($3);
	  }
	 |INT
	  {
		$$=(struct fieldType *)malloc(sizeof(struct fieldType));
		$$->type=INT;
		$$->length=4;
	  };
usesql:USE ID ';'
       {
	    strcpy(database,$2);
	    useDB();
       };
showsql	:SHOW DATABASES ';'
	 {
		printf("Database:\n");
		getDB();
	 }
	|SHOW TABLES ';'
	 {
		printf("Tables:\n");
		getTable();
	 };
selectsql:SELECT fields_star FROM tables ';'
	  {
		selectNoCdt($2,$4);
	  }
	 |SELECT fields_star FROM tables WHERE conditions ';'
	  {
		selectCdt($2,$4,$6);
	  };
	  fields_star:table_fields
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=$1;
	  }
	 |'*'
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=NULL;
	  };
	  table_fields:table_field
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=$1;
	  }
	 |table_field ',' table_fields
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$1->field;
		$$->table=$1->table;
		$$->next_sf=$3;
	  };
	  table_field:field
	  {
		$$=(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$1;
		$$->table=NULL;
		$$->next_sf=NULL;
	  }
	 |table '.' field
	  {
		$$=(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$3;
		$$->table=$1;
		$$->next_sf=NULL;
	  };
	  tables:table
	  {
		$$=(struct Selectedtables *)malloc(sizeof(struct Selectedtables));
		$$->table=$1;
		$$->next_st=NULL;
	  }
	 |table ',' tables
	  {
		$$=(struct Selectedtables *)malloc(sizeof (struct Selectedtables));
		$$->table=$1;
		$$->next_st=$3;
	  };
	  conditions:condition
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$=$1;
	  }
	 |'('conditions')'
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$=$2;
	  }
	 |conditions AND conditions
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op='a';
	  }
	 |conditions OR conditions
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op='o';
	  };
	  condition:comp_left comp_op comp_right
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op=$2;
	  };
	  comp_left:table_field
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=0;
		$$->value=$1->field;
		$$->table=$1->table;
		$$->left=NULL;
		$$->right=NULL;
	 };
	 comp_right:table_field
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=0;
		$$->value=$1->field;
		$$->table=$1->table;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|NUMBER
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=2;
		$$->value=$1;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|QUOTE ID QUOTE
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=1;
		$$->value=$2;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|QUOTE NUMBER QUOTE
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=1;
		$$->value=$2;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 };
	 comp_op:'<'
	 {
		$$='<';
	 }
	|'>'
	 {
		$$='>';
	 }
	|'='
	 {
		$$='=';
	 }
	|'!''='
	 {
		$$='!';
	 };
insertsql:INSERT INTO table VALUES '(' values ')' ';'
	  {
		insertOrder($3,$6);
	  }
	 |INSERT INTO table '(' values ')' VALUES '(' values ')' ';'
	  {
		insertNoOrder($3,$5,$9);
	  };
	  values:value
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1->value;
		$$->next_Value=NULL;
	  }
	 |value ',' values
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1->value;
		$$->next_Value=$3;
	  };
	  value:QUOTE ID QUOTE
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$2;
		$$->next_Value=NULL;
	  }
	 |QUOTE NUMBER QUOTE
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$2;
		$$->next_Value=NULL;
	  }
	 |NUMBER
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1;
		$$->next_Value=NULL;
	  }
	 |ID
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1;
		$$->next_Value=NULL;
	  };
deletesql:DELETE FROM table ';'
	  {
		deleteAll($3);
	  }
	 |DELETE FROM table WHERE conditions ';'
	  {
		deleteCdt($3,$5);
	  };
dropsql:DROP TABLE ID ';'
	{
		dropTable($3);
	}
       |DROP DATABASE ID ';'
	{
		strcpy(database,$3);
		dropDB();
	};
updatesql:UPDATE table SET sets ';'
	  {
		updateAll($2,$4);
	  }
	 |UPDATE table SET sets WHERE conditions ';'
	  {
		updateCdt($2,$4,$6);
	  };
	  sets:set
	  {
		$$=$1;
	  }
	 |set ',' sets
	  {
		$$=(struct Setstruct *)malloc(sizeof(struct Setstruct));
		$$->field=$1->field;
		$$->value=$1->value;
		$$->next_sf=$3;
	  };
	  set:ID '=' NUMBER
	  {
		$$=(struct Setstruct *)malloc(sizeof(struct Setstruct));
		$$->field=$1;
		$$->value=$3;
		$$->next_sf=NULL;
	  }
	 |ID '=' QUOTE ID QUOTE
	  {
		$$=(struct Setstruct *)malloc(sizeof(struct Setstruct));
		$$->field=$1;
		$$->value=$4;
		$$->next_sf=NULL;
	  };
exitsql:EXIT ';'
	{
             	printf("Glad to see you again!\n");
           	exit(0);
	};		


%%

//-----------------------------------------------------------------------
/* 创建数据库 */
void createDB()
{
	FILE *fp;
	_chdir(rootDir);
	if(_access(database,0)!=-1)
	{
		printf("The database already exist!\n");
	}
	else
	{
		if(_mkdir(database)==-1)//创建以数据库为名的文件夹
		{
			printf("Create database failed!\n");
		}
		else
		{
			fp=fopen("database.dat","a+");//若没有此文件则创建，有则在文件末添加数据库名字
			if(fp==NULL)
			{
				printf("open database.dat error!\n");
			}
			else
			{
				fprintf(fp,"%s\n",database);
				printf("Create database %s succeed!\n",database);
				fflush(fp);
				fclose(fp);
			}
		}
	}
	strcpy(database,"\0");
	_chdir(rootDir);
	printf("MySQL>");
}

//-----------------------------------------------------------------------
/* 获取所有数据库名字 */
void getDB()
{
	FILE *fp;
	char name[100];
	_chdir(rootDir);
	fp=fopen("database.dat","r");//打开保存数据库名字的文件
	if(fp==NULL)
	{
		printf("open database.dat failed!\n");
	}
	else
	{
		while(fscanf(fp,"%s",name)!=EOF)
		{
			printf("%s\n",name);//打印数据库名字
		}	
	}
	fclose(fp);
	_chdir(rootDir);
	printf("MySQL>");
}

//-----------------------------------------------------------------------
/* 选择数据库 */
void useDB()
{
	char name[100];//保存需use的数据库绝对路径
	_chdir(rootDir);
	strcpy(name,rootDir);
	strcat(name,"\\");
	strcat(name,database);
	if(_chdir(name)==0)//转到需use的数据库的所在路径
	{
		if(_access(name,0)!=-1)//若所插入的表格存在
		{
			printf("Current database:%s\n",database);
			_chdir(rootDir);
		}
		else
		{
			printf("The database doesn't exist!\n");
		}
	}
	else
	{
		printf("Use %s failed!\n",database);
	}
	strcpy(database,name);//更新database
	printf("MySQL>");
}

//-----------------------------------------------------------------------
/* 创建表 */
void createTable(struct Createstruct *cs_root)
{
	struct Createfieldsdef *cfdef=cs_root->fdef;
	int d=4;//INT型的长度
	int i=0;//记录所创建表格的属性个数
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		FILE *fp;
		FILE *fp2;
		char name[100];//保存所创建表的名字
		char table[100];//保存所创建文件的名字
		strcpy(name,cs_root->table);
		fp=fopen("tables.dat","a+");//更新总表
		if(fp==NULL)
		{
			printf("Open tables.dat failed!\n");
		}
		else
		{
			strcpy(table,name);
			strcat(table,".txt");
			if(_access(table,0)!=-1)//若所创建的表已存在
			{
				printf("The table already exist!\n");
			}
			else
			{
				while(cfdef!=NULL)//将表的信息存入总表
				{
					fprintf(fp,"%s ",name);
					if(cfdef->type==CHAR)
					{
						fprintf(fp,"%s ",cfdef->field);
						fprintf(fp,"CHAR %d\n",(int)cfdef->length);
					}
					else if(cfdef->type==INT)
					{
						fprintf(fp,"%s INT %d\n",cfdef->field,d);
					}
					i++;
					cfdef=cfdef->next_fdef;
				}
				fclose(fp);
				fp2=fopen(table,"w");
				if(fp2==NULL)
				{
					printf("Open %s failed!\n",table);
				}
				else
				{
					cfdef=cs_root->fdef;
					fprintf(fp2,"%d\n",i);//在文件第一行写入表格属性个数
					while(cfdef!=NULL)//将表的字段存入文件
					{
						if(cfdef->next_fdef==NULL)
						{
							fprintf(fp2,"%s\n",cfdef->field);
						}
						else
						{
							fprintf(fp2,"%s\t",cfdef->field);
						}
						cfdef=cfdef->next_fdef;
					}
					fclose(fp2);
				}
				printf("Create succeed!\n");
			}
		}
	}
	cfdef=cs_root->fdef;
    while(cfdef!= NULL)//释放指针
    {
        struct Createfieldsdef *cfdeftmp=cfdef;
        cfdef=cfdef->next_fdef;
        free(cfdeftmp);
    }
    free(cs_root);
    _chdir(rootDir);
    printf("MySQL>");
}

//-----------------------------------------------------------------------
/* 显示表信息 */
void getTable()
{
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
	
		FILE *fp;
		char s1[100],s2[100],s3[100];//表名，字段，字段类型
		int d;//字段长度
		fp=fopen("tables.dat","r");
		if(fp==NULL)
		{
			printf("Open tables.dat failed!\n");
		}
		else
		{
			fscanf(fp,"%d",&d);//过滤第一行的表格属性个数
			while(fscanf(fp,"%s %s %s %d",s1,s2,s3,&d)!=EOF)
			{
				if(strcmp(s3,"CHAR")==0)
				{
					printf("%s %s %s %d\n",s1,s2,s3,d);
				}
				else if(strcmp(s3,"INT")==0)
				{
					printf("%s %s %s\n",s1,s2,s3);
				}
			}
			fclose(fp);
			_chdir(rootDir);
			printf("MySQL>");
		}
	}
}

//-----------------------------------------------------------------------
/* 按顺序插入数据 */
void insertOrder(char *tableName,struct insertValue *values)
{
	char name[100];
	_chdir(rootDir);
	strcpy(name,tableName);
	strcat(name,".txt");
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		if(_access(name,0)!=-1)//若所插入的表格存在
		{
			FILE *fp;
			struct insertValue *valuestmp=values;
			fp=fopen(name,"a+");//打开文件并在末尾添加数据
			if(fp==NULL)
			{
				printf("Open %s failed!\n",name);
			}
			else
			{
				while(valuestmp!=NULL)//写入数据
				{
					if(valuestmp->next_Value==NULL)
					{
						fprintf(fp,"%s\n",valuestmp->value);
					}
					else
					{
						fprintf(fp,"%s\t",valuestmp->value);
					}
					valuestmp=valuestmp->next_Value;
				}
				fclose(fp);
				printf("Insert succeed!\n");
			}
		}
		else
		{
			printf("The table doesn't exist!\n");
		}	
	}
	while(values!=NULL)//释放指针
	{
		struct insertValue *valuestmp=values;
		values=values->next_Value;
		free(valuestmp);
	}
	_chdir(rootDir);
	printf("MySQL>");
}

//-----------------------------------------------------------------------
/* 自定义顺序插入数据 */
void insertNoOrder(char *tableName,struct insertValue *valuesName,struct insertValue *values)
{
	char name[100];//保存写入数据的文件名
	char select_name[100][100];//所选字段名
	char all_name[100][100];//所有字段名
	char select_value[100][100];//字段值
	int flag=0;//所选字段的个数
	int flag2=0;//字段值得个数
	int N;//所有字段的个数
	int i,j;
	_chdir(rootDir);
	strcpy(name,tableName);
	strcat(name,".txt");
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		if(_access(name,0)!=-1)//若所插入的表格存在
		{
			FILE *fp;
			FILE *fp2;
			struct insertValue *val_Name=valuesName;
			struct insertValue *val_tmp=values;
			while(val_Name!=NULL)//将所选字段保存在Name数组里
			{
				strcpy(select_name[flag],val_Name->value);
				flag++;
				val_Name=val_Name->next_Value;
			}
			while(val_tmp!=NULL)//将插入值保存在Value数组里
			{
				strcpy(select_value[flag2],val_tmp->value);
				flag2++;
				val_tmp=val_tmp->next_Value;
			}
			if(flag!=flag2)//若个数不等无法插入
			{
				printf("Numbers are not equal!\n");
			}
			else
			{
				fp=fopen(name,"r");//打开文件只读
				if(fp==NULL)
				{
					printf("Open %s failed!\n",name);
				}
				else
				{
					fscanf(fp,"%d\n",&N);//读入第一行的表格属性个数
					for(i=0;i<N;i++)//将所有字段保存在all_name数组里
					{
						fscanf(fp,"%s",all_name[i]);
						if(i>=flag)//如果N大于所选字段个数，则在相应位置存NULL
						{
							strcpy(select_value[i],"NULL");
							strcpy(select_name[i],"NULL");
						}
					}
					strcpy(select_value[i],"NULL");
					strcpy(select_name[i],"NULL");
					for(i=0;i<N;i++)//将Value数组里的值的位置对应all_name
					{
						for(j=0;j<flag;j++)
						{
							if(strcmp(all_name[i],select_name[j])==0)
							{
								strcpy(select_name[j],select_name[i]);
								strcpy(select_name[i],all_name[i]);
								strcpy(select_value[N],select_value[i]);
								strcpy(select_value[i],select_value[j]);
								strcpy(select_value[j],select_value[N]);
								break;
							}
						}
					}
					fclose(fp);
					fp2=fopen(name,"a+");
					if(fp2==NULL)
					{
						printf("Open %s failed!\n",name);
					}
					else
					{
						for(i=0;i<N;i++)//写入数据，在未选插入值的位置上填NULL
						{
							if(i==N-1)
							{
								fprintf(fp2,"%s\n",select_value[i]);
							}
							else
							{
								fprintf(fp2,"%s\t",select_value[i]);
							}
						}
						fclose(fp2);
						printf("Insert succeed!\n");
					}
				}
			}
			while(valuesName!=NULL)//释放指针
			{
				struct insertValue *val_Name=valuesName;
				valuesName=valuesName->next_Value;
				free(val_Name);
			}
			while(values!=NULL)//释放指针
			{
				struct insertValue *val_tmp=values;
				values=values->next_Value;
				free(val_tmp);
			}	
		}
		else
		{
			printf("The table doesn't exist!\n");
		}	
	}
	_chdir(rootDir);
	printf("MySQL>");
}

//匹配条件式的ID,找到需更新/查询的行-------------------------------------
int CdtSearch(struct Conditions *conditionRoot, int totField, char allField[][100], char value[][100])
{
    char comp_op = conditionRoot->comp_op;//操作符
    int field = 0;
    int field2 = 0;
    int i;
    if (comp_op == 'a')//若是AND则求多个条件式的和，返回1表示属性匹配成功
    {
        return (CdtSearch(conditionRoot->left, totField, allField, value)&&CdtSearch(conditionRoot->right, totField, allField, value));
    }
    else if (comp_op == 'o')//若是OR则求多个条件式的或，返回1表示属性匹配成功
    {
        return (CdtSearch(conditionRoot->left, totField, allField, value) || CdtSearch(conditionRoot->right, totField, allField, value));
    }
    else//若条件式为单个
    {
        if(conditionRoot->right->type==0)//若是ID=ID的条件，先找到匹配左部table.field的字段下标
        {
			for(i=0;i<totField;i++)
			{
				if(strcmp(allField[i+totField],conditionRoot->left->table)==0)
				{
					if(strcmp(allField[i], conditionRoot->left->value)==0)
					{
						field2=i;
						break;
					}
				}
			}
        }
        else
        {
			for (i = 0; i < totField; ++i)//匹配更改字段和表中字段，成功则记录属性所在第几列
			{
				if (strcmp(allField[i], conditionRoot->left->value) == 0)
				{
					field = i;
					break;
				}
			}
        }
        if (comp_op == '=')//表中的值和条件式右部相等
        {
            if(conditionRoot->right->type==0)
            {
				for(i=0;i<totField;i++)//找到右部字段field等于左部字段field
				{
					if(strcmp(allField[i+totField],conditionRoot->right->table)==0)
					{
						if(strcmp(allField[field2],allField[i])==0)
						{
							if(strcmp(value[field2],value[i])==0)//连接相同属性值
							{
								return 1;
							}
						}
					}
				}
				if(i==totField)//没找到返回0
				{
					return 0;
				}
            }
            else if (strcmp(value[field], conditionRoot->right->value) == 0)
            {
                return 1;
            }
            else
            {
                return 0;
			}
        }
        else if (comp_op == '>')//表中的值大于条件式右部
        {
            if (conditionRoot->right->type == 2)
            {	
				if (atoi(value[field]) > atoi(conditionRoot->right->value))
                {
					return 1;
				}
				else
				{
					return 0;
				}
            }
            else 
            {
                return 0;
            }
        }
        else if (comp_op == '<')//表中的值小于条件式右部
        {
            if (conditionRoot->right->type == 2)
            {	
				if (atoi(value[field]) < atoi(conditionRoot->right->value))
                {
					return 1;
				}
				else
				{
					return 0;
				}
            }
            else 
            {
                return 0;
            }
        }
        else if (comp_op == '!')//表中的值不等于条件式右部
        {
            if (conditionRoot->right->type == 2)
            {	
				if (atoi(value[field]) != atoi(conditionRoot->right->value))
                {
					return 1;
				}
				else
				{
					return 0;
				}
            }
            else if(conditionRoot->right->type == 1)
            {
				if(strcmp(value[field],conditionRoot->right->value)!=0)
				{
					return 1;
				}
				else
				{
					return 0;
				}
            }
            else 
            {
                return 0;
            }
        }
    }
}

//释放condition指针
void freeCdt(struct Conditions *conditionRoot)
{
	if (conditionRoot->left != NULL)
	{
        freeCdt(conditionRoot->left);
    }
    else if (conditionRoot->right != NULL)
    {    
		freeCdt(conditionRoot->right);
    }
    else
    {
		free(conditionRoot);
	}
}
//修改所有数据-----------------------------------------------------------
void updateAll(char *tableName,struct Setstruct *setRoot)
{
	char name[100];//保存需要更改数据的文件名
	char copy[100]="copy ";//保存复制name的文件的system操作命令
	char del[100]="del copy.txt";//数据更新完成后删除复制文件
	char update_name[100][100];//需更改的字段名
	char update_value[100][100];//更改的字段值
	char all_name[100][100];//所有字段名
	char old_value[100][100];//旧的字段值
	int flag;//判断需更改字段的标记
	int all_field=0;//所有字段个数
	int update_set=0;//需更改的个数
	int file_end=0;//判断文件是否读完，1表示已读完
	int i,j,k;
	FILE *fp;//打开复制文件
	FILE *fp2;//重写name文件
	struct Setstruct *Set_tmp=setRoot;//更改字段指针
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		strcpy(name,tableName);
		strcat(name,".txt");
		if(_access(name,0)!=-1)//若所需更改数据的表格存在
		{
			strcat(copy,name);
			strcat(copy," ");
			strcat(copy,"copy.txt");//copy[]:"copy name copy.txt"
			while(Set_tmp!=NULL)//将需要更改数据的字段以及字段值分别保存到update_name和update_value中
			{
				strcpy(update_name[update_set],Set_tmp->field);
				strcpy(update_value[update_set],Set_tmp->value);
				update_set++;
				Set_tmp=Set_tmp->next_sf;
			}
			system(copy);
			fp=fopen("copy.txt","r");//对复制文件只读
			fp2=fopen(name,"w");//对更改的表重写
			fscanf(fp,"%d",&all_field);//读出所有字段个数
			fprintf(fp2,"%d\n",all_field);//写入所有字段个数
			for(i=0;i<all_field;i++)//对name文件重写所有属性字段
			{
				fscanf(fp,"%s",all_name[i]);
				if(i==all_field-1)
				{
					fprintf(fp2,"%s\n",all_name[i]);
				}
				else
				{
					fprintf(fp2,"%s\t",all_name[i]);
				}
			}
			for(i=0;1;i++)
			{
				file_end=0;
				for(j=0;j<all_field;j++)//每次循环读取一行字段值，若碰到文件结束符，跳出循环
				{
					if(fscanf(fp,"%s",old_value[j])==EOF)
					{
						file_end=1;
						break;
					}
				}
				if(file_end==1)//若文件读完，代表更改数据完毕，跳出循环
				{
					break;
				}
				for(j=0;j<all_field;j++)
				{
					flag=0;
					for(k=0;k<update_set;k++)//找到需更改的字段将数据更新
					{
						if(strcmp(update_name[k],all_name[j])==0)
						{
							if(j==all_field-1)
							{
								fprintf(fp2,"%s\n",update_value[k]);
							}
							else
							{
								fprintf(fp2,"%s\t",update_value[k]);
							}
							flag=1;
							break;
						}
					}
					if(flag==0)//不需要更改数据的字段将原数据写入
					{
						if(j==all_field-1)
						{
							fprintf(fp2,"%s\n",old_value[j]);
						}
						else
						{
							fprintf(fp2,"%s\t",old_value[j]);
						}
					}
				}
			}
		fclose(fp2);
		fclose(fp);
		system(del);//删除复制文件
		printf("Update succeed!\n");
		}
		else
		{
			printf("The table doesn't exist!\n");
		}	
	}
	free(tableName);
	while(setRoot!=NULL)//释放set指针
	{
		struct Setstruct *Set_tmp=setRoot;
		setRoot=setRoot->next_sf;
		free(Set_tmp);
	}
	_chdir(rootDir);
	printf("MySQL>");
}

//修改选定属性的数据
void updateCdt(char *tableName,struct Setstruct *setRoot,struct Conditions *conditionRoot)
{
	char name[100];//保存需要更改数据的文件名
	char copy[100]="copy ";//保存复制name的文件的system操作命令
	char del[100]="del copy.txt";//数据更新完成后删除复制文件
	char update_name[100][100];//需更改的字段名
	char update_value[100][100];//更改的字段值
	char all_name[100][100];//所有字段名
	char old_value[100][100];//旧的字段值
	int condition_flag;//CdtSearch()条件式返回的值
	int flag;//判断需更改字段的标记
	int all_field=0;//所有字段个数
	int update_set=0;//需更改的个数
	int file_end=0;//判断文件是否读完，1表示已读完
	int i,j,k;
	FILE *fp;//打开复制文件
	FILE *fp2;//重写name文件
	struct Setstruct *Set_tmp=setRoot;//更改字段指针
	struct Conditions *Cdt_tmp=conditionRoot;//条件指针
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		strcpy(name,tableName);
		strcat(name,".txt");
		if(_access(name,0)!=-1)//若所需更改数据的表格存在
		{
			strcat(copy,name);
			strcat(copy," ");
			strcat(copy,"copy.txt");//copy[]:"copy name copy.txt"
			while(Set_tmp!=NULL)//将需要更改数据的字段以及字段值分别保存到update_name和update_value中
			{
				strcpy(update_name[update_set],Set_tmp->field);
				strcpy(update_value[update_set],Set_tmp->value);
				update_set++;
				Set_tmp=Set_tmp->next_sf;
			}
			system(copy);
			fp=fopen("copy.txt","r");//对复制文件只读
			fp2=fopen(name,"w");//对更改的表重写
			fscanf(fp,"%d",&all_field);//读出所有字段个数
			fprintf(fp2,"%d\n",all_field);//写入所有字段个数
			for(i=0;i<all_field;i++)//对name文件重写所有属性字段
			{
				fscanf(fp,"%s",all_name[i]);
				if(i==all_field-1)
				{
					fprintf(fp2,"%s\n",all_name[i]);
				}
				else
				{
					fprintf(fp2,"%s\t",all_name[i]);
				}
			}
			for(i=0;1;i++)
			{
				condition_flag=0;
				file_end=0;
				for(j=0;j<all_field;j++)//每次循环读取一行字段值，若碰到文件结束符，跳出循环
				{
					if(fscanf(fp,"%s",old_value[j])==EOF)
					{
						file_end=1;
						break;
					}
				}
				if(file_end==1)//若文件读完，代表更改数据完毕，跳出循环
				{
					break;
				}
				condition_flag=CdtSearch(conditionRoot,all_field,all_name,old_value);
				if(condition_flag==0)//未匹配成功，不是需要更改的行，将旧值重写入
				{
					for(j=0;j<all_field;j++)
					{
						if(j==all_field-1)
						{
							fprintf(fp2,"%s\n",old_value[j]);
						}
						else
						{
							fprintf(fp2,"%s\t",old_value[j]);
						}
					}
				}
				else//匹配到需更改的行
				{
					for(j=0;j<all_field;j++)
					{
						flag=0;
						for(k=0;k<update_set;k++)//找到需更改的字段将数据更新
						{
							if(strcmp(update_name[k],all_name[j])==0)
							{
								if(j==all_field-1)
								{
									fprintf(fp2,"%s\n",update_value[k]);
								}
								else
								{
									fprintf(fp2,"%s\t",update_value[k]);
								}
								flag=1;
								break;
							}
						}
						if(flag==0)//不需要更改数据的字段将原数据写入
						{
							if(j==all_field-1)
							{
								fprintf(fp2,"%s\n",old_value[j]);
							}
							else
							{
								fprintf(fp2,"%s\t",old_value[j]);
							}
						}
					}
				}
			}
		fclose(fp2);
		fclose(fp);
		system(del);//删除复制文件
		printf("Update succeed!\n");
		}
		else
		{
			printf("The table doesn't exist!\n");
		}	
	}
	free(tableName);
	freeCdt(conditionRoot);//释放condition指针
	while(setRoot!=NULL)//释放SET指针
	{
		struct Setstruct *Set_tmp=setRoot;
		setRoot=setRoot->next_sf;
		free(Set_tmp);
	}
	_chdir(rootDir);
	printf("MySQL>");
}

//无条件查询-------------------------------------------------------------
void selectNoCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot)
{
	char tableName[100][100];//保存表文件名字
	char fileName[100][100];//保存表名字
	int all_table=0;//所有表个数
	int all_field=0;//所有属性字段个数
	int flag=1;//判断表是否存在的标志
	int i,j;
	struct Selectedfields *field_tmp=fieldRoot;
	struct Selectedtables *table_tmp=tableRoot;
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		while(table_tmp!=NULL)//将所有需要查询的表名字保存在tableName
		{
			strcpy(fileName[all_table],table_tmp->table);
			strcpy(tableName[all_table],table_tmp->table);
			strcat(tableName[all_table],".txt");
			all_table++;
			table_tmp=table_tmp->next_st;
		}
		if(field_tmp==NULL)//'*'查询
		{
			for(i=0;i<all_table;i++)
			{
				if(_access(tableName[i],0)==-1)//表格不存在
				{
					printf("The table %s doesn't exist!\n",fileName[i]);
					flag=0;
					break;
				}
			}
			if(flag && (all_table==1))
			{
				FILE *fp;
				char field_value[100][100];//字段与属性值
				int i=0;
				int count_value=0;//元组个数(包括属性行)
				fp=fopen(tableName[0],"r");
				fscanf(fp,"%d",&all_field);//读取属性列个数
				while(fscanf(fp,"%s",field_value[i])!=EOF)
				{
					if(i==all_field-1)//输出一行的最后一个，计数器i重新为0，进行下一行的打印
					{
						printf("%-20s\n",field_value[i]);
						count_value++;
						i=0;
					}
					else
					{
						printf("%-20s",field_value[i]);
						i++;
					}
				}
				fclose(fp);
				printf("%d Records Selected!\n",count_value-1);
			}
			else if(flag && (all_table>1))
			{
				FILE *file_table[100];//表
				int all_value=0;//所有元组个数
				int count_field[100];//每张表字段个数
				int count_value[100];//每张表元组个数(包括属性行)
				char field_values[5][100][100];//保存每张表内字段以及字段值
				for(i=0;i<all_table;i++)//每张表只读
				{
					file_table[i]=fopen(tableName[i],"r");
				}
				for(i=0;i<all_table;i++)//读取每张表的属性列个数
				{
					fscanf(file_table[i],"%d",&count_field[i]);
				}
				for(i=0;i<all_table;i++)//分别打印查询的表
				{
					j=0;
					count_value[i]=0;
					printf("Select table %s:\n",tableName[i]);
					while(fscanf(file_table[i],"%s",field_values[i][j])!=EOF)
					{
						if(j==count_field[i]-1)
						{
							printf("%-20s\n",field_values[i][j]);
							count_value[i]++;
							j=0;
						}
						else
						{
							printf("%-20s",field_values[i][j]);
							j++;
						}
					}
				}
				for(i=0;i<all_table;i++)
				{
					all_value+=count_value[i]-1;
					fclose(file_table[i]);
				}
				printf("%d Records Selected!\n",all_value);//打印查询到的所有元组个数
			}
		}
		else//指定字段查询
		{
			if(all_table!=1)//无条件的指定字段查询只能是单表查询
			{
				printf("Select only one table!\n");
			}
			else
			{
				if(_access(tableName[0],0)==-1)//表格不存在
				{
					printf("The table %s doesn't exist!\n",tableName[0]);
				}
				else
				{
					FILE *fp;
					char select_field[100][100];//查询的字段名
					char all_name[100][100];//所有字段名
					char all_values[100][100];//所有的属性值
					int count_sel=0;//需查询的字段个数
					int count_value=0;//查询元组个数
					fp=fopen(tableName[0],"r");
					fscanf(fp,"%d",&all_field);//读取字段个数
					for(i=0;i<all_field;i++)//读取所有字段
					{
						fscanf(fp,"%s",all_name[i]);
					}
					while(field_tmp!=NULL)//读取需要查询的字段
					{
						strcpy(select_field[count_sel],field_tmp->field);
						count_sel++;
						field_tmp=field_tmp->next_sf;
					}
					for(i=0;i<count_sel;i++)//打印需要查询的字段
					{
						if(i==count_sel-1)
						{
							printf("%-20s\n",select_field[i]);
						}
						else
						{
							printf("%-20s",select_field[i]);
						}
					}
					i=0;
					while(fscanf(fp,"%s",all_values[i])!=EOF)//打印查询的属性值
					{
						for(j=0;j<count_sel;j++)
						{
							if(strcmp(all_name[(i%all_field)],select_field[j])==0)//匹配查询字段
							{
								if(j==count_sel-1)
								{
									printf("%-20s\n",all_values[i]);
									count_value++;
								}
								else
								{
									printf("%-20s",all_values[i]);	
								}
							}	
						}
						i++;	
					}
					fclose(fp);
					printf("%d Records Selected!\n",count_value);
				}
			}
		}
	}
	field_tmp = fieldRoot;
    table_tmp = tableRoot;
    while(fieldRoot != NULL)
    {
        field_tmp = fieldRoot;
        fieldRoot = fieldRoot->next_sf;
        free(field_tmp);
    }
    while(tableRoot != NULL)
    {
        table_tmp = tableRoot;
        tableRoot = tableRoot->next_st;
        free(table_tmp);
    }
    _chdir(rootDir);
    printf("MySQL>");
}

//笛卡尔乘积递归---------------------------------------------------------
void handle(int read_line[],int count_value[],int all_table,int index)
{  
	read_line[index]++;//行号加1
    if (read_line[index] > count_value[index])//当index指代的表读完
    {  
		read_line[index] = 1;//重新指回第一行
		index--;//返回前一个表
        if (index >= 0)//当还有表没读完
        {  
			handle(read_line,count_value,all_table,index);  
        }  
        index = all_table - 1;//重新指代最后一个表
    }  
} 
 
//有条件查询-------------------------------------------------------------
void selectCdt(struct Selectedfields *fieldRoot,struct Selectedtables *tableRoot,struct Conditions *conditionRoot)
{
	int all_table=0;//所有表个数
	int all_field=0;//所有属性字段个数
	int i,j,k;
	int flag=1;//判断表格存在的标志
	int condition_flag;//CdtSearch()条件式返回的值
	int file_end=0;//判断文件是否读完，1表示已读完
	char tableName[100][100];//保存表名字
	char fileName[100][100];//表文件的名字
	char select_name[100][100];//查询字段
	int count_sel=0;//查询字段个数
	struct Selectedfields *field_tmp=fieldRoot;
	struct Selectedtables *table_tmp=tableRoot;
	struct Conditions *Cdt_tmp=conditionRoot;
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		while(table_tmp!=NULL)//将所有需要查询的表名字保存在tableName
		{
			strcpy(tableName[all_table],table_tmp->table);
			strcpy(fileName[all_table],table_tmp->table);
			strcat(fileName[all_table],".txt");
			all_table++;
			table_tmp=table_tmp->next_st;
		}
		for(i=0;i<all_table;i++)
		{
			if(_access(fileName[i],0)==-1)//表格不存在
			{
				printf("The table %s doesn't exist!\n",fileName[i]);
				flag=0;
				break;
			}
		}
		if(flag && (all_table==1))
		{
			FILE *fp;
			char all_name[100][100];//所有字段
			char all_values[100][100];//所有属性值
			int count_value=0;//查询元组个数
			fp=fopen(fileName[0],"r");
			fscanf(fp,"%d",&all_field);//读取属性列个数
			for(i=0;i<all_field;i++)
			{
				fscanf(fp,"%s",all_name[i]);
			}
			while(field_tmp!=NULL)
			{
				strcpy(select_name[count_sel],field_tmp->field);
				count_sel++;
				field_tmp=field_tmp->next_sf;
			}
			for(i=0;i<count_sel;i++)
			{
				if(i==count_sel-1)
				{
					printf("%-20s\n",select_name[i]);
				}
				else
				{
					printf("%-20s",select_name[i]);
				}
			}
			for(i=0;1;i++)
			{
				condition_flag=0;
				file_end=0;
				for(j=0;j<all_field;j++)//每次循环读取一行字段值，若碰到文件结束符，跳出循环
				{
					if(fscanf(fp,"%s",all_values[j])==EOF)
					{
						file_end=1;
						break;
					}
				}
				if(file_end==1)//若文件读完，代表更改数据完毕，跳出循环
				{
					break;
				}
				condition_flag=CdtSearch(Cdt_tmp,all_field,all_name,all_values);
				if(condition_flag==1)//匹配到查询的行
				{
					for(j=0;j<all_field;j++)
					{
						for(k=0;k<count_sel;k++)//找到查询的字段将数据打印
						{
							if(strcmp(select_name[k],all_name[j])==0)
							{
								if(k==count_sel-1)
								{
									printf("%-20s\n",all_values[j]);
									count_value++;
								}
								else
								{
									printf("%-20s",all_values[j]);
								}
								break;
							}
						}
					}
				}
			}
			fclose(fp);
			printf("%d Records Selected!\n",count_value);
		}
		else if(flag && (all_table>1))
		{
			FILE *file_table[100];//表
			int all_value=1;//所有元组笛卡尔乘积个数
			int count_field[100];//每个表字段个数
			int count_value[100];//每个表元组个数
			int index;//指向表的下标
			int read_line[100]={1,1,1,1,1};//所读的行号
			char field_value[5][100][100];//保存所有字段以及属性值
			char Cdt_field[100][100];//当前查询行的字段及表名
			char Cdt_value[100][100];//当前查询行的属性值
			char select_table[100][100];//查询字段所在的表
			char print_name[100][100];//打印的字段
			int is_print[100];//判断是否可输出
			int count_print=0;//输出元组的个数
			int l,m;
			for(i=0;i<all_table;i++)//每张表只读
			{
				file_table[i]=fopen(fileName[i],"r");
			}
			while(field_tmp!=NULL)//要查询的字段，记录字段个数
			{
				strcpy(select_name[count_sel],field_tmp->field);
				strcpy(select_table[count_sel],field_tmp->table);
				count_sel++;
				field_tmp=field_tmp->next_sf;
			}
			for(i=0;i<all_table;i++)
			{
				fscanf(file_table[i],"%d",&count_field[i]);//读取每张表的字段个数
				j=0;
				k=all_field;
				all_field+=count_field[i];//所有字段个数
				count_value[i]=0;
				while(fscanf(file_table[i],"%s",field_value[i][j])!=EOF)
				{
					if(j<count_field[i])
					{
						strcpy(Cdt_field[k],field_value[i][j]);
						k++;
					}
					else
					{
						if(j%count_field[i]==0)//记录每张表元组个数
						{
							count_value[i]++;
						}
					}
					j++;
				}
				fclose(file_table[i]);
				all_value=all_value*count_value[i];//所有字段笛卡尔乘积后的个数
			}
			for(i=0;i<all_table;i++)//将前all_field个字段所在表的名字复制进去
			{
				for(j=0;j<count_field[i];j++)
				{
					strcpy(Cdt_field[k],tableName[i]);
					k++;
				}
			}
			for(i=0;i<all_field;i++)//初始化要输出的value的标志
			{
				is_print[i]=0;
			}
			for(i=0;i<count_sel;i++)//确定table.field字段
			{
				for(j=0;j<all_field;j++)
				{
					if(strcmp(select_name[i],Cdt_field[j])==0)
					{
						if(strcmp(select_table[i],Cdt_field[j+all_field])==0)//打印字段信息并在相应的位置上设置可输出属性值的标志
						{
							is_print[j]=1;
							strcpy(print_name[i],select_table[i]);
							strcat(print_name[i],".");
							strcat(print_name[i],select_name[i]);
							if(i==count_sel-1)
							{
								printf("%-20s\n",print_name[i]);
							}
							else
							{
								printf("%-20s",print_name[i]);
							}
						}
					}
				}
			}
			for(i=0;i<all_value;i++)//总共判断all_value次
			{
				index=all_table-1;//指向最后一个表
				k=0;
				for(j=0;j<all_table;j++)//读出一行value存入Cdt_value
				{
					for(l=0;l<count_field[j];l++)
					{
						strcpy(Cdt_value[k],field_value[j][read_line[j]*count_field[j]+l]);
						k++;
					}
				}
				condition_flag=CdtSearch(conditionRoot,all_field,Cdt_field,Cdt_value);
				if(condition_flag==1)//满足条件
				{
					m=0;
					for(l=0;l<all_field;l++)//输出is_print标志可输出的value
					{
						if(is_print[l]==1)
						{
							if(m==count_sel-1)
							{
								printf("%-20s\n",Cdt_value[l]);
								count_print++;
								break;
							}
							else
							{
								printf("%-20s",Cdt_value[l]);
							}
							m++;
						}
					}
				}
				handle(read_line,count_value,all_table,index);
			}
			printf("%d Records Selected!\n",count_print);
		}
	}
	freeCdt(conditionRoot);//释放condition指针
	field_tmp = fieldRoot;
    table_tmp = tableRoot;
    while(fieldRoot != NULL)
    {
        field_tmp = fieldRoot;
        fieldRoot = fieldRoot->next_sf;
        free(field_tmp);
    }
    while(tableRoot != NULL)
    {
        table_tmp = tableRoot;
        tableRoot = tableRoot->next_st;
        free(table_tmp);
    }
    _chdir(rootDir);
    printf("MySQL>");
}

//删除数据库-------------------------------------------------------------
void dropDB()
{
	_chdir(rootDir);
	if(_access(database,0)!=-1)//该数据库存在
	{
		char del[100]="rd ";//删除操作参数
		char DB[100][100];//保存已有的数据库名字
		int count_DB=0;//已有数据库个数
		int i;
		FILE *fp;//对database.dat的读操作
		FILE *fp2;//对database.dat的写操作
		strcat(del,database);
		fp=fopen("database.dat","r");
		while(fscanf(fp,"%s",DB[count_DB])!=EOF)//将数据库名字读出
		{
			count_DB++;
		}
		fp2=fopen("database.dat","w");//重写database.dat
		for(i=0;i<count_DB;i++)//把除了删除了数据库名字写入
		{
			if(strcmp(DB[i],database)!=0)
			{
				fprintf(fp2,"%s\n",DB[i]);
			}
		}
		fclose(fp2);
		fclose(fp);
		system(del);
		printf("Delete Database succeed!\n");
	}
	else
	{
		printf("The database doesn't exist!\n");
	}
	_chdir(rootDir);
    printf("MySQL>");
}

//删除表格---------------------------------------------------------------
void dropTable(char *tableName)
{
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		char name[100];
		strcpy(name,tableName);
		strcat(name,".txt");
		if(_access(name,0)!=-1)//该表格存在
		{
			char del[100]="del ";//删除操作参数
			char table_name[100][100];//保存已有的表格名字
			int count_table=0;//已有表格个数
			int i;
			FILE *fp;//对tables.dat的读操作
			FILE *fp2;//对tables.dat的写操作
			strcat(del,name);
			fp=fopen("tables.dat","r");
			while(fscanf(fp,"%s",table_name[count_table])!=EOF)//将表名字读出
			{
				count_table++;
			}
			fp2=fopen("tables.dat","w");
			for(i=0;i<count_table;i=i+4)//若不是要删除的表格，则将信息直接写入
			{
				if(strcmp(table_name[i],tableName)!=0)
				{
					fprintf(fp2,"%s\t",table_name[i]);
					fprintf(fp2,"%s\t",table_name[i+1]);
					fprintf(fp2,"%s\t",table_name[i+2]);
					fprintf(fp2,"%s\n",table_name[i+3]);
				}
			}
			fclose(fp2);
			fclose(fp);
			system(del);
			printf("Delete table Succeed!\n");
		}
		else
		{
			printf("The table doesn't exist!\n");
		}
	}
	_chdir(rootDir);
    printf("MySQL>");
}

//删除表格内所有数据-----------------------------------------------------
void deleteAll(char *tableName)
{
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		char name[100];
		strcpy(name,tableName);
		strcat(name,".txt");
		if(_access(name,0)!=-1)//该表格存在
		{
			FILE *fp;//对表格只读
			FILE *fp2;//对表格重写
			char field[100][100];//保存表的字段名
			int all_field;//所有字段个数
			int i;
			fp=fopen(name,"r");
			fscanf(fp,"%d",&all_field);//读出字段个数
			for(i=0;i<all_field;i++)//读出所有字段
			{
				fscanf(fp,"%s",field[i]);
			}
			fp2=fopen(name,"w");//重写
			fprintf(fp2,"%d\n",all_field);//写入字段个数
			for(i=0;i<all_field;i++)//写入所有字段
			{
				if(i==all_field-1)
				{
					fprintf(fp2,"%s\n",field[i]);
				}
				else
				{
					fprintf(fp2,"%s\t",field[i]);
				}
			}
			fclose(fp2);
			fclose(fp);
			printf("Delete data Succeed!\n");
		}
		else
		{
			printf("The table doesn't exist!\n");
		}
	}
	_chdir(rootDir);
    printf("MySQL>");
}

//删除表格内某个数据
void deleteCdt(char *tableName,struct Conditions *conditionRoot)
{
	_chdir(rootDir);
	if(strlen(database)==0)//未use数据库
	{
        printf("Please use a database first!\n");
	}
    else if(_chdir(database) == -1)//转路径失败
	{
        printf("Turn direction failed!\n");
	}
	else
	{
		char name[100];//删除数据的表文件名
		strcpy(name,tableName);
		strcat(name,".txt");
		if(_access(name,0)!=-1)//该表格存在
		{
			FILE *fp;//对表格只读
			FILE *fp2;//对表格重写
			char copy[100]="copy ";
			char del[100]="del copy.txt";
			char all_name[100][100];//保存表的字段名
			char all_value[100][100];//保存所有属性值
			int all_field;//所有字段个数
			int file_end=0;//表格读取完的标志
			int condition_flag=0;//判断是否满足条件
			int i,j;
			strcat(copy,name);
			strcat(copy," ");
			strcat(copy,"copy.txt");//copy[]:"copy tableName.txt copy.txt"
			system(copy);
			fp=fopen("copy.txt","r");//对复制文件只读
			fp2=fopen(name,"w");//对更改的表重写
			fscanf(fp,"%d",&all_field);//读出所有字段个数
			fprintf(fp2,"%d\n",all_field);//写入所有字段个数
			for(i=0;i<all_field;i++)//对name文件重写所有属性字段
			{
				fscanf(fp,"%s",all_name[i]);
				if(i==all_field-1)
				{
					fprintf(fp2,"%s\n",all_name[i]);
				}
				else
				{
					fprintf(fp2,"%s\t",all_name[i]);
				}
			}
			for(i=0;1;i++)
			{
				file_end=0;
				for(j=0;j<all_field;j++)//每次循环读取一行字段值，若碰到文件结束符，跳出循环
				{
					if(fscanf(fp,"%s",all_value[j])==EOF)
					{
						file_end=1;
						break;
					}
				}
				if(file_end==1)//若文件读完，代表更改数据完毕，跳出循环
				{
					break;
				}
				condition_flag=CdtSearch(conditionRoot,all_field,all_name,all_value);
				if(condition_flag==0)//未匹配成功，不是需要删除的行，将旧值重写入
				{
					for(j=0;j<all_field;j++)
					{
						if(j==all_field-1)
						{
							fprintf(fp2,"%s\n",all_value[j]);
						}
						else
						{
							fprintf(fp2,"%s\t",all_value[j]);
						}
					}
				}
			}
			fclose(fp2);
			fclose(fp);
			system(del);//删除复制文件
			printf("Delete data succeed!\n");
		}
		else
		{
			printf("The table doesn't exist!\n");
		}
	}
	free(tableName);
	freeCdt(conditionRoot);
	_chdir(rootDir);
    printf("MySQL>");
}
//-----------------------------------------------------------------------
void main()
{
    printf("***************************************\n");
    printf("*                                     *\n");
    printf("*         Welcome to MySQL!           *\n");
    printf("*                                     *\n");
    printf("***************************************\n");
    printf("MySQL>");
    _getcwd(rootDir, sizeof(rootDir));
    strcat(rootDir, "\\sql");
    //printf("%s\n",rootDir);
    while(1)
    {
		yyparse();
    }
    
}

void yyerror(const char *str)
{
    fprintf(stderr,"error:%s\n",str);
}
int yywrap()
{
    return 1;
}
