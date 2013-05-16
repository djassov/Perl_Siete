-- ----------------------------
--  Table structure for `plazas`
-- ----------------------------

CREATE TABLE plazas (
  id number(10) NOT NULL ,
  nombre varchar2(250) DEFAULT NULL,
  extension varchar2(20) DEFAULT NULL,
  estado number(3) DEFAULT '1',
  PRIMARY KEY (id)
)  ;

CREATE SEQUENCE plazas_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER plazas_seq_tr
 BEFORE INSERT ON plazas FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT plazas_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/


-- ----------------------------
--  Table structure for `procesados`
-- ----------------------------

CREATE TABLE procesados (
  id number(10) NOT NULL ,
  proceso_id number(10) NOT NULL,
  proceso_nombre varchar2(250) DEFAULT NULL,
  plaza varchar2(250) DEFAULT NULL,
  nombre_archivo varchar2(250) DEFAULT NULL,
  fecha date DEFAULT NULL,
  header_tienda varchar2(250) DEFAULT NULL,
  header_recepcion varchar2(250) DEFAULT NULL,
  cantidad number(10) DEFAULT NULL,
  errores_articulo number(10) DEFAULT NULL,
  plaza_id number(10) DEFAULT NULL,
  PRIMARY KEY (id)
) ;

CREATE SEQUENCE procesados_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER procesados_seq_tr
 BEFORE INSERT ON procesados FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT procesados_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Table structure for `procesados_error`
-- ----------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE procesados_error';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE procesados_error (
  id number(10) NOT NULL ,
  proceso_id number(10) NOT NULL,
  proceso_nombre varchar2(250) DEFAULT NULL,
  plaza varchar2(250) DEFAULT NULL,
  nombre_archivo varchar2(250) DEFAULT NULL,
  fecha date DEFAULT NULL,
  header_tienda varchar2(250) DEFAULT NULL,
  header_recepcion varchar2(250) DEFAULT NULL,
  articulo varchar2(250) DEFAULT NULL,
  errores_header_tienda number(10) DEFAULT NULL,
  errores_header_recepcion number(10) DEFAULT NULL,
  errores_articulo number(10) DEFAULT NULL,
  plaza_id number(10) DEFAULT NULL,
  PRIMARY KEY (id)
) ;

CREATE SEQUENCE procesados_error_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER procesados_error_seq_tr
 BEFORE INSERT ON procesados_error FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT procesados_error_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Table structure for `procesos`
-- ----------------------------

CREATE TABLE procesos (
  id number(10) NOT NULL ,
  nombre varchar2(250) DEFAULT NULL,
  prefijo varchar2(250) DEFAULT NULL,
  plaza varchar2(10) DEFAULT NULL,
  path_dir varchar2(250) DEFAULT NULL,
  filename varchar2(250) DEFAULT NULL,
  header_tienda varchar2(10) DEFAULT '0',
  longitud_ht number(10) DEFAULT '0',
  header_recepcion varchar2(10) DEFAULT '1200',
  longitud_hr number(10) DEFAULT '0',
  articulo varchar2(10) DEFAULT '1212',
  longitud_articulo number(10) DEFAULT '0',
  lineas_minimas number(10) DEFAULT '0',
  softerror number(3) DEFAULT '0',
  path_procesados varchar2(250) DEFAULT NULL,
  PRIMARY KEY (id)
)  ;

CREATE SEQUENCE procesos_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER procesos_seq_tr
 BEFORE INSERT ON procesos FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT procesos_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/