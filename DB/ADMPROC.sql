/*
 Navicat Premium Data Transfer

 Source Server         : 7-Eleven Desarrollo(Oracle)
 Source Server Type    : Oracle
 Source Server Version : 102030
 Source Host           : 132.148.160.115
 Source Schema         : ADMPROC

 Target Server Type    : Oracle
 Target Server Version : 102030
 File Encoding         : utf-8

 Date: 07/22/2013 15:14:48 PM
*/

-- ----------------------------
--  Table structure for PLAZAS
-- ----------------------------
DROP TABLE "ADMPROC"."PLAZAS";
CREATE TABLE "PLAZAS" (   "ID" NUMBER(10,0) NOT NULL, "NOMBRE" VARCHAR2(250BYTE) DEFAULT NULL, "EXTENSION" VARCHAR2(20BYTE) DEFAULT NULL, "ESTADO" NUMBER(3,0) DEFAULT '1');

-- ----------------------------
--  Records of PLAZAS
-- ----------------------------
INSERT INTO "ADMPROC"."PLAZAS" VALUES ('1', '60', '.060', '1');
INSERT INTO "ADMPROC"."PLAZAS" VALUES ('2', '30', '.030', '1');
INSERT INTO "ADMPROC"."PLAZAS" VALUES ('3', '20', '.020', '1');
INSERT INTO "ADMPROC"."PLAZAS" VALUES ('4', '10', '.010', '1');
COMMIT;

-- ----------------------------
--  Table structure for PROCESADOS
-- ----------------------------
DROP TABLE "ADMPROC"."PROCESADOS";
CREATE TABLE "PROCESADOS" (   "ID" NUMBER(10,0) NOT NULL, "PROCESO_ID" NUMBER(10,0) NOT NULL, "PROCESO_NOMBRE" VARCHAR2(250BYTE) DEFAULT NULL, "PLAZA" VARCHAR2(250BYTE) DEFAULT NULL, "NOMBRE_ARCHIVO" VARCHAR2(250BYTE) DEFAULT NULL, "FECHA" DATE DEFAULT NULL, "HEADER_TIENDA" VARCHAR2(250BYTE) DEFAULT NULL, "HEADER_RECEPCION" VARCHAR2(250BYTE) DEFAULT NULL, "CANTIDAD" NUMBER(10,0) DEFAULT NULL, "ERRORES_ARTICULO" NUMBER(10,0) DEFAULT NULL, "PLAZA_ID" NUMBER(10,0) DEFAULT NULL);

-- ----------------------------
--  Table structure for PROCESADOS_ERROR
-- ----------------------------
DROP TABLE "ADMPROC"."PROCESADOS_ERROR";
CREATE TABLE "PROCESADOS_ERROR" (   "ID" NUMBER(10,0) NOT NULL, "PROCESO_ID" NUMBER(10,0) NOT NULL, "PROCESO_NOMBRE" VARCHAR2(250BYTE) DEFAULT NULL, "PLAZA" VARCHAR2(250BYTE) DEFAULT NULL, "NOMBRE_ARCHIVO" VARCHAR2(250BYTE) DEFAULT NULL, "FECHA" DATE DEFAULT NULL, "HEADER_TIENDA" VARCHAR2(250BYTE) DEFAULT NULL, "HEADER_RECEPCION" VARCHAR2(250BYTE) DEFAULT NULL, "ARTICULO" VARCHAR2(250BYTE) DEFAULT NULL, "ERRORES_HEADER_TIENDA" NUMBER(10,0) DEFAULT NULL, "ERRORES_HEADER_RECEPCION" NUMBER(10,0) DEFAULT NULL, "ERRORES_ARTICULO" NUMBER(10,0) DEFAULT NULL, "PLAZA_ID" NUMBER(10,0) DEFAULT NULL);

-- ----------------------------
--  Table structure for PROCESOS
-- ----------------------------
DROP TABLE "ADMPROC"."PROCESOS";
CREATE TABLE "PROCESOS" (   "ID" NUMBER(10,0) NOT NULL, "NOMBRE" VARCHAR2(250BYTE) DEFAULT NULL, "PREFIJO" VARCHAR2(250BYTE) DEFAULT NULL, "PLAZA" VARCHAR2(20BYTE) DEFAULT NULL, "PATH_DIR" VARCHAR2(250BYTE) DEFAULT NULL, "FILENAME" VARCHAR2(250BYTE) DEFAULT NULL, "HEADER_TIENDA" VARCHAR2(20BYTE) DEFAULT '0', "LONGITUD_HT" NUMBER(10,0) DEFAULT '0', "HEADER_RECEPCION" VARCHAR2(20BYTE) DEFAULT '1200', "LONGITUD_HR" NUMBER(10,0) DEFAULT '0', "ARTICULO" VARCHAR2(20BYTE) DEFAULT '1212', "LONGITUD_ARTICULO" NUMBER(10,0) DEFAULT '0', "LINEAS_MINIMAS" NUMBER(10,0) DEFAULT '0', "SOFTERROR" NUMBER(3,0) DEFAULT '0', "PATH_PROCESADOS" VARCHAR2(250BYTE) DEFAULT NULL);

-- ----------------------------
--  Records of PROCESOS
-- ----------------------------
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('1', 'Recepcion sin Pedido', 'RECEPRSO', '\.(\d\d\d)', '//132.148.160.202/e/workarea/contabilidad/RECEPRSO/', '^MC(\d\d)(\d\d)(\d\d)(\d\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('2', 'Recepcion CDC', 'RECEPCDC', '\.(\d\d\d)', '//10.160.1.100/d/workarea/sics/contabilidad/', '^MC(\d\d)(\d\d)(\d\d\d\d)(\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('3', 'Notas de Credito', 'NotasCredito', '\.(\d\d\d)', '//132.148.160.202/e/workarea/Mov_inventarios/NotasCredito', '^NCR_(\d\d\d\d)(\d\d)(\d\d)_(\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('4', 'Caratulas de Inventario', 'CaratulasInv', '\.(\d\d\d)', '//132.148.160.202/workarea/CONTABILIDAD/', '^M(\d\d\d\d)(\d\d\d\d)(\d\d)(\d\d)\.(\d\d\d)$', '^0000', '17', '^1400', '16', '^1412', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('5', 'Cambios de Precio', 'CambioPrecio', '\.(\d\d\d)', '//132.148.160.202/e/workarea/mov_inventarios/notascredito', '^NCR_(\d\d\d\d)(\d\d)(\d\d)_(\d\d\d\d)\.(\d\d\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('6', 'Mercancia Especial', 'MercanciaEsp', '\.(\d\d\d)', '//132.148.160.202/e/workarea/Contabilidad/TFMERCANCIA', '^M(\d\d\d\d)(\d\d\d\d)(\d\d)(\d\d)\.(\d\d\d)$', '^0000', '17', '^1400', '16', '^1412', '52', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('7', 'Transferencias', 'Transferencias', '\.(\d\d\d)', '//132.148.160.202/E/workarea/Mov_inventarios/TRANSFERENCIAS', '^TRANSF_(\d\d\d\d)(\d\d)(\d\d)_(\d\d\d\d).(\d\d\d)', '^0000', '17', '^2400', '39', '^2403', '53', '0', '1', 'procesados');
INSERT INTO "ADMPROC"."PROCESOS" VALUES ('8', 'Merma', 'Merma', '\.(\d\d\d)', '//132.148.160.202/E/workarea/Contabilidad/BACKMERMA', '^MU(\d\d)(\d\d\d\d)(\d\d)(\d\d).(\d\d\d)', '^0000', '17', '^2000', '20', '^2001', '55', '0', '1', 'procesados');
COMMIT;

-- ----------------------------
--  Primary key structure for table PLAZAS
-- ----------------------------
ALTER TABLE "ADMPROC"."PLAZAS" ADD CONSTRAINT "SYS_C00103273" PRIMARY KEY("ID");

-- ----------------------------
--  Checks structure for table PLAZAS
-- ----------------------------
ALTER TABLE "ADMPROC"."PLAZAS" ADD CONSTRAINT "SYS_C00103272" CHECK ("ID" IS NOT NULL) ENABLE;

-- ----------------------------
--  Triggers structure for table PLAZAS
-- ----------------------------
CREATE TRIGGER ""."PLAZAS_SEQ_TR" BEFORE INSERT ON "ADMPROC"."PLAZAS" REFERENCING OLD AS "OLD" NEW AS "NEW" FOR EACH ROW WHEN (NEW.id IS NULL) BEGIN
 SELECT PLAZAS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;

/


-- ----------------------------
--  Primary key structure for table PROCESADOS
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESADOS" ADD CONSTRAINT "SYS_C00102982" PRIMARY KEY("ID");

-- ----------------------------
--  Checks structure for table PROCESADOS
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESADOS" ADD CONSTRAINT "SYS_C00102980" CHECK ("ID" IS NOT NULL) ENABLE ADD CONSTRAINT "SYS_C00102981" CHECK ("PROCESO_ID" IS NOT NULL) ENABLE;

-- ----------------------------
--  Triggers structure for table PROCESADOS
-- ----------------------------
CREATE TRIGGER ""."PROCESADOS_SEQ_TR" BEFORE INSERT ON "ADMPROC"."PROCESADOS" REFERENCING OLD AS "OLD" NEW AS "NEW" FOR EACH ROW WHEN (NEW.id IS NULL) BEGIN
 SELECT PROCESADOS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;

/


-- ----------------------------
--  Primary key structure for table PROCESADOS_ERROR
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESADOS_ERROR" ADD CONSTRAINT "SYS_C00103276" PRIMARY KEY("ID");

-- ----------------------------
--  Checks structure for table PROCESADOS_ERROR
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESADOS_ERROR" ADD CONSTRAINT "SYS_C00103274" CHECK ("ID" IS NOT NULL) ENABLE ADD CONSTRAINT "SYS_C00103275" CHECK ("PROCESO_ID" IS NOT NULL) ENABLE;

-- ----------------------------
--  Triggers structure for table PROCESADOS_ERROR
-- ----------------------------
CREATE TRIGGER ""."PROCESADOS_ERROR_SEQ_TR" BEFORE INSERT ON "ADMPROC"."PROCESADOS_ERROR" REFERENCING OLD AS "OLD" NEW AS "NEW" FOR EACH ROW WHEN (NEW.id IS NULL) BEGIN
 SELECT PROCESADOS_error_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;

/


-- ----------------------------
--  Primary key structure for table PROCESOS
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESOS" ADD CONSTRAINT "SYS_C00103278" PRIMARY KEY("ID");

-- ----------------------------
--  Checks structure for table PROCESOS
-- ----------------------------
ALTER TABLE "ADMPROC"."PROCESOS" ADD CONSTRAINT "SYS_C00103277" CHECK ("ID" IS NOT NULL) ENABLE;

-- ----------------------------
--  Triggers structure for table PROCESOS
-- ----------------------------
CREATE TRIGGER ""."PROCESOS_SEQ_TR" BEFORE INSERT ON "ADMPROC"."PROCESOS" REFERENCING OLD AS "OLD" NEW AS "NEW" FOR EACH ROW WHEN (NEW.id IS NULL) BEGIN
 SELECT PROCESOS_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;

/


