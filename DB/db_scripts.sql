/*
 Navicat Premium Data Transfer

 Source Server         : Seven
 Source Server Type    : MySQL
 Source Server Version : 50144
 Source Host           : localhost
 Source Database       : apps

 Target Server Type    : MySQL
 Target Server Version : 50144
 File Encoding         : utf-8

 Date: 05/22/2013 18:21:21 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `plazas`
-- ----------------------------
DROP TABLE IF EXISTS `plazas`;
CREATE TABLE `plazas` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(250) DEFAULT NULL,
  `extension` varchar(20) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- ----------------------------
--  Records of `plazas`
-- ----------------------------
BEGIN;
INSERT INTO `plazas` VALUES ('1', '60', '.060', '1'), ('2', '30', '.030', '1'), ('3', '20', '.020', '1');
COMMIT;

-- ----------------------------
--  Table structure for `procesados`
-- ----------------------------
DROP TABLE IF EXISTS `procesados`;
CREATE TABLE `procesados` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `proceso_id` int(10) NOT NULL,
  `proceso_nombre` varchar(250) DEFAULT NULL,
  `plaza` varchar(250) DEFAULT NULL,
  `nombre_archivo` varchar(250) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `header_tienda` varchar(250) DEFAULT NULL,
  `header_recepcion` varchar(250) DEFAULT NULL,
  `cantidad` int(10) DEFAULT NULL,
  `errores_articulo` int(10) DEFAULT NULL,
  `plaza_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
--  Table structure for `procesados_error`
-- ----------------------------
DROP TABLE IF EXISTS `procesados_error`;
CREATE TABLE `procesados_error` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `proceso_id` int(10) NOT NULL,
  `proceso_nombre` varchar(250) DEFAULT NULL,
  `plaza` varchar(250) DEFAULT NULL,
  `nombre_archivo` varchar(250) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `header_tienda` varchar(250) DEFAULT NULL,
  `header_recepcion` varchar(250) DEFAULT NULL,
  `articulo` varchar(250) DEFAULT NULL,
  `errores_header_tienda` int(10) DEFAULT NULL,
  `errores_header_recepcion` int(10) DEFAULT NULL,
  `errores_articulo` int(10) DEFAULT NULL,
  `plaza_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
--  Table structure for `procesos`
-- ----------------------------
DROP TABLE IF EXISTS `procesos`;
CREATE TABLE `procesos` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(250) DEFAULT NULL,
  `prefijo` varchar(250) DEFAULT NULL,
  `plaza` varchar(20) DEFAULT NULL,
  `path_dir` varchar(250) DEFAULT NULL,
  `filename` varchar(250) DEFAULT NULL,
  `header_tienda` varchar(20) DEFAULT '0',
  `longitud_ht` int(10) DEFAULT '0',
  `header_recepcion` varchar(20) DEFAULT '1200',
  `longitud_hr` int(10) DEFAULT '0',
  `articulo` varchar(20) DEFAULT '1212',
  `longitud_articulo` int(10) DEFAULT '0',
  `lineas_minimas` int(10) DEFAULT '0',
  `softerror` tinyint(1) DEFAULT '0',
  `path_procesados` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

-- ----------------------------
--  Records of `procesos`
-- ----------------------------
BEGIN;
INSERT INTO `procesos` VALUES ('1', 'Recepcion sin Pedido', 'RECEPRSO', '\\.(\\d\\d\\d)', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/RECEPRSO', '^MC(\\d\\d)(\\d\\d)(\\d\\d)(\\d\\d\\d\\d\\d)\\.(\\d\\d\\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/RECEPRSO'), ('2', 'Recepcion CDC', 'RECEPCDC', '\\.(\\d\\d\\d)', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/RECEPCDC', '^MC(\\d\\d)(\\d\\d)(\\d\\d\\d\\d)(\\d\\d\\d\\d)\\.(\\d\\d\\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/RECEPCDC'), ('3', 'Notas de Credito', 'NotasCredito', '\\.(\\d\\d\\d)', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/NotasCredito', '^NCR_(\\d\\d\\d\\d)(\\d\\d)(\\d\\d)_(\\d\\d\\d\\d)\\.(\\d\\d\\d)$', '^0000', '17', '^1200', '97', '^1212', '52', '0', '1', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/NotasCredito'), ('4', 'Caratulas de Inventario', 'CaratulasInv', '\\.(\\d\\d\\d)', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/Caratulas', '^M(\\d\\d\\d\\d)(\\d\\d\\d\\d)(\\d\\d)(\\d\\d)\\.(\\d\\d\\d)$', '^0000', '17', '^1400', '16', '^1412', '52', '0', '1', '/Users/sandrarivera/Desktop/Jasso/Proyectos/Git/Perl_Siete/archivos/Caratulas');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
