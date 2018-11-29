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
## 从一个表检索与另一个表不相关的行  
有时也被成为反连接  

数据库 | 解决方案 |
-------|---------|
Oracle 8i - | 可以使用专有的外链接语法 |
其他数据库 | 使用外链接过滤掉null值 |

Oracle 8i -  
```
select d.*  
    from d.deptno, e.deptno  
where d.deptno = e.deptno (+)  
    and e.deptno is null
```
其他数据库  
```
select d.*  
    from dept d left outer join emp e  
        (on d.deptno = e.deptno ) 
    where e.deptno is null
```
## 新增连接查询获得额外信息不丢失原有信息
### 解决方案一：外链接查询
其他数据库  
```
select e.ename,d.loc,eb.received  
    from emp e join dept d  
        on (e.deptno=d.deptno)  
    left join emp_bonus eb  
        on (e..empno=eb.empno)
order by 2
```
Oracle 8i -  
```
select e.ename,d.loc,eb.received  
    from emp e,dept d,emp_bonus eb  
where e.deptno=d.deptno  
    and e.empno=eb.empno(+)  
order by 2
```
外链接之所以能解决这个问题，是因为它不会过滤掉任何应该被返回的行  

### 解决方案二：标量子查询
这种方法适用于所有数据库

```
select e.ename,d.loc,
    (
        select eb.received from emp_bonus eb 
        where eb.empno=e.empno
    ) as received
from emp e,dept d  
where e.deptno=d.deptno
order by 2
```
## 识别并消除笛卡尔积
解决方案  
在from字句里对两个表进行连接查询，已得到正确的结果集
```
select e.ename,d.loc  
    from emp e,dept d  
where e.deptno=10  
    and d.deptno=e.deptno
```
## 使用连接查询与聚合函数避免重复数据
### 解决方案一：调用聚合函数时直接使用关键字DISTINCT，去除重复项再参与计算
MySQL和PostgreSQL
```
select deptno
        sum(distinct sal) as total_sal,
        sum(bonus) as total_bonus
    from (
        select e.empno,
                e.ename,
                e.sal,
                e.deptno,
                e.sal*case when eb.type=1 then .1
                             when eb.type=2 thwn .2
                             else .3
                        end as bonus 
            from emp r,emp_bonus eb
            where e.empno =eb.empno
                and e.deptno=10
    ) x
    group by deptno
```
DB2、Oracle和SQL Server
```
select distinct deptno,total_sal,total_bonus
    from (
        select e.empno,
                e.ename,
                sum(distinct e.sal) over
                (partition by e.deptno) as total_sal,
                e.deptno,
                sum(e.sal*case when eb.type=1 then .1
                                when eb.type=2 then .2 
                                else .3 end) over
                (partition by deptno) as total_bonus
                from emp e,emp_bonus eb
                where e.empno=eb.empno
                    and e.deptno=10
    ) x
```
### 解决方案二：进行连接查询之前先进行聚合运算

MySQL和PostgreSQL
```
select d.deptno, 
        d.total_sal,
        sum(
            e.sal*case when eb.type=1 then .1
                        when eb.type=2 then .2
                        else .3 end 
        ) as total_bonus
    from emp e,
    emp_bonus eb,
    (
        select deptno,sum(sal) as total_sal
            from emp
        where e.deptno,sum(sal) as total_sal
            from emp
        where deptno=10
        group by deptno
    ) d
where e.deptno=d.deptno
    and e.empno=eb.empno
group by d.depno,d.total_sal
```
 DB2、Oracle和SQL Server  
 ```
 select e.empno,
        e.ename,
        sum(distinct e.sal) over
        (partition by e.deptno) as total_sal,
        e.deptno,
        sum(e.sal*case when eb.type=1 then .1
                        when eb.type=2 then .2
                        else .3 end) over
        (partition by deptno) as total_bonus
    from emp e,emp_bonus eb 
where e.empno=eb.empno
    and e.deptno=10
 ``` 
## 全外连接
数据库 | 解决方案 |
-------|---------|
Oracle 8i -|专有语法实现外链接 |
其他数据库 | 显示外链接或者合并两个外链接的结果| 

### 除了8i -的数据库的显示外链接
```
select d.deptno,d.dname,e.ename
    from dept d full outer join emp e
        on (d.deptno=e.deptno)
```
### 除了8i -的数据库的两个外链接合并
```
select d.deptno,d.dname,e.ename
    from dept d right outer join emp e 
        on (d.deptno=e.deptno)
    union
select d.deptno,d.dname,e.ename
    from dept d left outer join emp e
        on (d.deptno=e.deptno)
```
### 8i -的专有语法
```
select d.deptno,d.dname,e.ename
    from dept d,emp e
where d.deptno=e.deptno(+)
    union
select d.deptno,d.dname,e.ename
    from dept d,emp e
where d.deptno(+)=e.deptno
```
## 血一样的教训
1、先写注释  

2、对好  
begin   

end  
3、用table往里挪一点表示分层  

4、设置变量属性 最前面用set开头  

5、if里面不能有算术表达式 只能算完之后把结果放进去比较判断 case也一样  
  
6、把带进来的参数用进去更规范，then中不能用表达式做判断，只能是一个指定的值
  ```
  CASE @showType        
        WHEN 1
        THEN @showType 
        ELSE 0
        END
```
7、如果是连表查询操作，where 条件中需要指定是主表的字段还是从表的，如果主表有就按照主表的，java后端接收参数才不会出错。