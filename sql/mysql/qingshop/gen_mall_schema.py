#!/usr/bin/env python3
"""Generate MySQL 8 DDL from MyBatis-Plus @TableName DO classes (MIT source). Own work for QingShop."""
import re, os, sys, subprocess
ROOT=os.environ.get('QINGSHOP_ROOT', os.path.abspath(os.path.join(os.path.dirname(__file__),'..','..','..'))); MODS=['yudao-module-mall','yudao-module-member','yudao-module-pay']
# argv[1]: comma separated tables that already exist (skip); argv[2]: output file
have=set(x for x in sys.argv[1].split(',') if x) if len(sys.argv)>1 else set()
OUT=sys.argv[2] if len(sys.argv)>2 else os.path.join(os.path.dirname(os.path.abspath(__file__)),'qingshop-mall-schema.sql')
# 业务唯一键（订单号等），其余 *_id 外键列建普通索引；基于 Mapper 中 selectByXxx / where xxx_id 的查询模式
UNIQUE={'trade_order':['no'],'trade_after_sale':['no'],'pay_order_extension':['no'],'pay_refund':['no'],'pay_transfer':['no']}
def snake(s): return re.sub(r'(?<=[a-z0-9])([A-Z])', r'_\1', s).lower()
LONG=re.compile(r'(content|description|introduction|remark|memo|html|reason|config|param|body|result|data|picUrls|images|msg|extras|address|urls|values|ids)$', re.I)
def coltype(t, name, handler):
    base=re.sub(r'<.*>','',t).strip()
    if handler or base in ('List','Set','Map','Object') or base.endswith('[]'): return 'text'
    m={'Long':'bigint','long':'bigint','Integer':'int','int':'int','Short':'smallint','Byte':'tinyint','Boolean':'bit(1)','boolean':'bit(1)',
       'LocalDateTime':'datetime','Date':'datetime','LocalDate':'date','LocalTime':'time','BigDecimal':'decimal(24,6)','Double':'double','Float':'float'}
    if base in m: return m[base]
    if base=='String':
        if re.search(r'(property|properties)$',name,re.I): return 'longtext'
        return 'text' if LONG.search(name) else 'varchar(512)'
    return 'text'  # custom object without explicit handler (autoResultMap json)
def dflt(ty,col):
    # numeric/bit counters default 0 (MyBatis-Plus skips null on insert; code expects 0 e.g. coupon take_count). FK-like *_id stay NULL.
    if col.endswith('_id'): return ' NULL'
    if ty.startswith(('int','smallint','tinyint','decimal','double','float')): return ' NULL DEFAULT 0'
    if ty=='bit(1)': return " NULL DEFAULT b'0'"
    if ty=='bigint': return ' NULL DEFAULT 0'
    return ' NULL'
classes={}
for mod in MODS:
    for dp,_,fs in os.walk(os.path.join(ROOT,mod)):
        for f in fs:
            if f.endswith('.java') and '/src/main/' in dp:
                src=open(os.path.join(dp,f),encoding='utf-8').read()
                if '@TableName' in src or re.search(r'class \w+DO\b',src): classes[f[:-5]]=src
def parse(src):
    tn=re.search(r'@TableName\s*\(\s*(?:value\s*=\s*)?"([^"]+)"',src)
    m=re.search(r'public\s+(?:abstract\s+)?class\s+(\w+)(?:\s+extends\s+(\w+))?',src)
    body=src[src.index('{',m.end())+1:]
    depth=0; cur=''; fields=[]; ann=''
    i=0
    # walk top-level statements of class body
    for line in body.split('\n'):
        s=line.strip()
        if depth==0:
            if s.startswith('@'): ann+=' '+s
            fm=re.match(r'(?:private|protected|public)\s+(?!static)([\w<>,\s\[\]?.]+?)\s+(\w+)\s*(=.*)?;',s)
            if fm: fields.append((fm.group(1),fm.group(2),ann)); ann=''
            elif s and not s.startswith('@') and not s.startswith('//') and not s.startswith('*') and not s.startswith('/*'): ann=''
        depth+=line.count('{')-line.count('}')
        if depth<0: break
    return (tn.group(1) if tn else None), m.group(2), fields
out=['-- QingShop mall/member/pay schema, generated from DO classes by gen_mall_schema.py (no official SQL used)','SET NAMES utf8mb4;']
count=0
for cname,src in sorted(classes.items()):
    tn,parent,fields=parse(src)
    if not tn or tn in have: continue
    cols=[]; pk=None; seen=set()
    for t,n,ann in fields:
        if re.search(r'exist\s*=\s*false',ann): continue
        cm=re.search(r'@TableField\s*\(\s*(?:value\s*=\s*)?"([^"]+)"',ann) or re.search(r'@TableId\s*\(\s*(?:value\s*=\s*)?"([^"]+)"',ann)
        col=cm.group(1) if cm else snake(n)
        if col in seen: continue
        seen.add(col)
        if '@TableId' in ann or (n=='id' and pk is None):
            auto='' if re.search(r'IdType\.(INPUT|ASSIGN)',ann) else ' AUTO_INCREMENT'
            ty='bigint' if 'Long' in t else ('int' if 'Integer' in t else 'varchar(64)')
            if ty=='varchar(64)': auto=''
            cols.append(f'  `{col}` {ty} NOT NULL{auto}'); pk=col; continue
        cols.append(f'  `{col}` {coltype(t,n,"typeHandler" in ann)}{dflt(coltype(t,n,"typeHandler" in ann),col)}')
    chain=parent; tenant=False; base=False
    while chain:
        if chain=='TenantBaseDO': tenant=True; base=True; break
        if chain=='BaseDO': base=True; break
        p=classes.get(chain)
        if not p: break
        _,chain2,pf=parse(p)
        for t,n,ann in pf:
            c=snake(n)
            if c not in seen: seen.add(c); cols.append(f'  `{c}` {coltype(t,n,"typeHandler" in ann)} NULL')
        chain=chain2
    if base:
        for c,d in [('creator',"varchar(64) DEFAULT ''"),('create_time','datetime NOT NULL DEFAULT CURRENT_TIMESTAMP'),('updater',"varchar(64) DEFAULT ''"),('update_time','datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),("deleted","bit(1) NOT NULL DEFAULT b'0'")]:
            if c not in seen: cols.append(f'  `{c}` {d}')
    if pk and 'tenant_id' not in seen: cols.append("  `tenant_id` bigint NOT NULL DEFAULT 0")
    if pk: cols.append(f'  PRIMARY KEY (`{pk}`)')
    for c in UNIQUE.get(tn,[]):
        if c in seen: cols.append(f'  UNIQUE KEY `uk_{c}` (`{c}`)')
    for c in sorted(seen):
        if c.endswith('_id') and c!=pk and c!='tenant_id': cols.append(f'  KEY `idx_{c}` (`{c}`)')
    out.append(f'\n-- from {cname}\nDROP TABLE IF EXISTS `{tn}`;\nCREATE TABLE `{tn}` (\n'+',\n'.join(cols)+'\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;')
    count+=1
open(OUT,'w').write('\n'.join(out)+'\n')
print('tables',count)
