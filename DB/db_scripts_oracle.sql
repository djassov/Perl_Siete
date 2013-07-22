
-- ----------------------------
--  Table structure for `PLAZAS`
-- ----------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PLAZAS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE PLAZAS (
  id number(10) NOT NULL ,
  nombre varchar2(250) DEFAULT NULL,
  extension varchar2(20) DEFAULT NULL,
  estado number(3) DEFAULT '1',
  PRIMARY KEY (id)
)  ;

CREATE SEQUENCE PLAZAS_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER PLAZAS_seq_tr
 BEFORE INSERT ON PLAZAS FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT PLAZAS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Records of `PLAZAS`
-- ----------------------------
BEGIN
INSERT INTO PLAZAS  SELECT '1', '60', '.060', '1' FROM dual UNION ALL   SELECT '2', '30', '.030', '1' FROM dual UNION ALL   SELECT '3', '20', '.020', '1' FROM dual;
END;

-- ----------------------------
--  Table structure for `PROCESADOS`
-- ----------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PROCESADOS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE PROCESADOS (
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

CREATE SEQUENCE PROCESADOS_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER PROCESADOS_seq_tr
 BEFORE INSERT ON PROCESADOS FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT PROCESADOS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Table structure for `PROCESADOS_error`
-- ----------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PROCESADOS_error';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE PROCESADOS_error (
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

CREATE SEQUENCE PROCESADOS_error_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER PROCESADOS_error_seq_tr
 BEFORE INSERT ON PROCESADOS_error FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT PROCESADOS_error_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Table structure for `PROCESOS`
-- ----------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PROCESOS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE PROCESOS (
  id number(10) NOT NULL ,
  nombre varchar2(250) DEFAULT NULL,
  prefijo varchar2(250) DEFAULT NULL,
  plaza varchar2(20) DEFAULT NULL,
  path_dir varchar2(250) DEFAULT NULL,
  filename varchar2(250) DEFAULT NULL,
  header_tienda varchar2(20) DEFAULT '0',
  longitud_ht number(10) DEFAULT '0',
  header_recepcion varchar2(20) DEFAULT '1200',
  longitud_hr number(10) DEFAULT '0',
  articulo varchar2(20) DEFAULT '1212',
  longitud_articulo number(10) DEFAULT '0',
  lineas_minimas number(10) DEFAULT '0',
  softerror number(3) DEFAULT '0',
  path_PROCESADOS varchar2(250) DEFAULT NULL,
  PRIMARY KEY (id)
)  ;

CREATE SEQUENCE PROCESOS_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER PROCESOS_seq_tr
 BEFORE INSERT ON PROCESOS FOR EACH ROW WHEN (NEW.id IS NULL)
BEGIN
 SELECT PROCESOS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ----------------------------
--  Records of `PROCESOS`
-- ----------------------------
BEGIN
INSERT INTO PROCESOS  SELECT '1', 'Recepcion sin Pedido', 'RECEPRSO', '\.(\d\d\d)', '//132.148.160.202/e/workarea/contabilidad/RECEPRSO/', '^MC(\d\d)(\d\d)(\d\d)(\d\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados' FROM dual 
	UNION ALL   SELECT '2', 'Recepcion CDC', 'RECEPCDC', '\.(\d\d\d)', '//10.160.1.100/d/workarea/sics/contabilidad/', '^MC(\d\d)(\d\d)(\d\d\d\d)(\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados' FROM dual 
	UNION ALL   SELECT '3', 'Notas de Credito', 'NotasCredito', '\.(\d\d\d)', '//132.148.160.202/e/workarea/Mov_inventarios/NotasCredito', '^NCR_(\d\d\d\d)(\d\d)(\d\d)_(\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados' FROM dual 
	UNION ALL   SELECT '4', 'Caratulas de Inventario', 'CaratulasInv', '\.(\d\d\d)', '//132.148.160.202/workarea/CONTABILIDAD/', '^M(\d\d\d\d)(\d\d\d\d)(\d\d)(\d\d)\.(\d\d\d)$', '^0000', '17', '^1400', '16', '^1412', '52', '0', '1', 'procesados' FROM dual;
END;
