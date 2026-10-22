#!/usr/bin/env python3
"""把 qingshop-mall-schema.sql 中新增的列/索引同步到已有库（只增不删，保留数据）。
用法: python3 sync_schema.py [mysql 参数...]，默认 mysql -uroot ruoyi-vue-pro"""
import re,subprocess,sys,os
M=(sys.argv[1:] or ['mysql','-uroot'])+['-N','ruoyi-vue-pro']
s=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'qingshop-mall-schema.sql')).read()
q=lambda x: subprocess.run(M+['-e',x],capture_output=True,text=True).stdout
alters=[]
for t,body in re.findall(r'CREATE TABLE `(\w+)` \((.*?)\n\) ENGINE',s,re.S):
    have=dict(r.split('\t') for r in q(f"select column_name,column_type from information_schema.columns where table_schema='ruoyi-vue-pro' and table_name='{t}'").split('\n') if r)
    if not have: continue
    idx=set(q(f"select distinct index_name from information_schema.statistics where table_schema='ruoyi-vue-pro' and table_name='{t}'").split())
    for line in body.strip().split('\n'):
        line=line.strip().rstrip(',')
        k=re.match(r'(UNIQUE KEY|KEY) `(\w+)` (\(.*\))',line)
        if k:
            if k.group(2) not in idx: alters.append(f"ALTER TABLE `{t}` ADD {k.group(1)} `{k.group(2)}` {k.group(3)};")
            continue
        m=re.match(r'`(\w+)` (.*)$',line)
        if not m or 'AUTO_INCREMENT' in line: continue
        c,d=m.group(1),m.group(2); ty=d.split()[0]
        if c not in have: alters.append(f"ALTER TABLE `{t}` ADD COLUMN `{c}` {d};")
        elif ty in ('text','longtext') and have[c]!=ty: alters.append(f"ALTER TABLE `{t}` MODIFY COLUMN `{c}` {d};")
for a in alters: print(a)
if alters:
    r=subprocess.run(M+['-e','\n'.join(alters)],capture_output=True,text=True); print(r.stderr or 'OK')
