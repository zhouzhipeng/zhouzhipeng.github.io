-- javadoc index
drop table if exists  javadoc_index_member_base;
create table javadoc_index_member_base (
  member_doc_link  text,
  member_signature text,
  member_type      text,
  member_name      text,
  member_desc      text,
  full_type_name   text,
  create_time      timestamp,
  weight           integer
);

drop table if exists  javadoc_index_type_base;
create table javadoc_index_type_base (
  type_doc_link  text,
  full_type_name text,
  type_name      text,
  package_name   text,
  type_desc      text,
  create_time      timestamp,
  weight           integer
);



-- 请求log
drop table  if exists request_log;
create table request_log (
  id           text primary key,
  project_id   text,
  interface_id text,
  create_at    timestamp,
  update_at    timestamp,
  request_serialize text , --序列化后的Request对象
  response_serialize text , --序列化后的Response对象
  running_status integer, -- 运行状态: 0-处理中,1-执行完成,2-执行失败
  running_log  text, -- 运行日志
  debug_log  text -- 调试日志
);



-- 项目maven依赖
drop table if exists project_dependency;
create table project_dependency (
  id                text primary key,
  project_id        text unique,
  custom_maven      text,
  http_jars         text,
  local_path        text,
  status            integer,  -- 更新状态: 0:待处理， 1:更新中, 2: 更新完毕, 3: 更新异常
  comment           text, -- 备注
  create_at         timestamp,
  update_at         timestamp
);


-- 系统配置表

drop table  if exists conf;

CREATE TABLE Conf (
  k TEXT PRIMARY KEY,
  v jsonb
);
