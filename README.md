# sql

## 串联多列  

数据库  | 串联运算符 | 
--------|-----------|
Oracle、DB2、PostgreSQL | 两个竖杠 |
MySQL| CONCAT 
SQL Server| +

## 限定返回行数
数据库 | 解决方案 |
-------|---------|
DB2 | FETCH FIRST|
MySQL和PostgreSQL | LIMIT|
Oracle | ROWNUM |
SQL Server |TOP |

## 随机返回数据
数据库|解决方案|
------|-------|
SQL Server | newid() |
Oracle | dbms_random.value() |
其他数据库 | rand() |

## 将null值替换为实际值
### 使用COALESCE函数  
```
select coalesce(comm,0) from emp  
```
### 也可以使用case  
```
select case  
       when comm is not null then comm  
       else 0  
       end  
       from emp  
```

## 查找匹配项
LIKE模式匹配操作 
运算符 | 含义 |
-------|-----|
% | 匹配任意长度的连续字符串 |
_ | 匹配单个字符 |
注意：%xxx% 任何位置  
%xxx 以xxx开头  
xxx% 以xxx结尾  
## order by 
order by 对结果集进行排序，默认升序，也可以指定为降序  
降序排列 ：  

```
select * from emp where deptno=10  
        order by sal desc  
```
也可以不指定排序的别名，用第几列替代  
用逗号分隔不同的排序列实现多字段排序  

## 截取某个字段的某几位
数据库 | 解决方案 |
-------|---------|
SQL Server | substring(哪个字段,从第几个开始,从第二个参数开始截取几个字符) |
其他数据库 | substr(哪个字段,从第几个开始,(可选)到哪里结束) |

## 对null的排序处理
数据库 | 解决方案 |
-------|---------|
Oracle | null first or null last |
其他数据库 | 添加一个辅助列，来判断是否是null，再通过order by排序 |

## 叠加多个行集
### UNION ALL 
```
select ename as ename_and dname,deptno  
        from emp  
        where depto=10  
    union all  
        select '-------',null  
        from t1  
    union all  
        select dname,deptno  
        from dept  
```
必须数目相同，类型匹配 

### UNION
相当于对union all 的输出结果，在执行一次DISTINCT操作  
除非有必要，否则不要执行DISTINCT和UNION操作  

## 多表中相同的行
数据库 |解决方案 |
-------| -------|
MySQL和SQL Server | 使用多个条件将多个表连接起来 |
其他数据库 | 可以使用前两个数据库的方法，也可以用INTERSECT和IN |

 ### MySQL 和 SQL Server
 用多个条件  
```
 select e.empno,e.ename,e.job,e.sal,e.deptno  
        from emp e,V  
            where 
            e.ename=v,ename  
            and e.job=v.job  
            and e.sal=v.sal  
  ```
  用显示join字句  
  ```
  select e.empno,e.ename,e.job,e.sal,e.deptno  
        from emp e join V   
            on (  
        e.ename=v.name  
        and e.job=v.job   
        and e.sal=v.sal  
  )  
  ```
  ### DB2、Oracle和PostgreSQL 
  ```
   select e.empno,e.ename,e.job,e.sal,e.deptno  
   from emp  
   where (emp,job,sal) in (  
       select ename,job,sal from emp  
       intersect  
       select ename,job,sal from V  
   ) 
  ```
   ## 只查询存在于一个表中的数据
   数据库 |解决方案 |
   -------|--------|
   DB2和PosrgreSQL | 使用集合运算EXCEPT |
   Oracle | 使用集合运算MINUS |
   MySQL和SQL Server | 使用子查询得到其他表中已经有的值，外层查询会找出没有的.不会排除重复值，而且会受null值影响，所以要使用exists关键字|

 DB2和PosrgreSQL  
```
select deptno from dept  
except  
select deptno from emp
```
Oracle  
```
select deptno from dept  
minus  
select deptno from emp
```
MySQL和SQL Server
```
select deptno  
    from dept  
where deptno not exists (select deptno from emp)
```
