-- MySQL Script generated by MySQL Workbench
-- Wed Apr 18 04:54:42 2018
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema AUCTIONS
-- -----------------------------------------------------
-- Английски аукцион (вариант 11).
-- 
-- 
-- 
-- Задача и развитие:
-- 
-- Администратор выставляет (снимает, блокирует) на торги лоты. Поддерживаются оба вида аукционов: прямой и обратный. 
-- Клиент может участвовать в аукционах, оплачивать покупки, предлагать администратору лоты для продажи. Администратор управляет клиентами и лотами.
-- 
-- 
-- 
-- Описание:
-- 
-- У нас есть система, где имеются АДМИНИСТРАТОРЫ (имеют поля: логин, зашифрованный пароль, имя и e-mail), которые управляют работой аукционов и производят с ними различные действия (выставление лота, снятие лота, блокировка, изменение статуса и т.д.), и КЛИЕНТЫ (имеют поля: логин, зашифрованный пароль, имя, e-mail и баланс личного счёта).
-- 
-- КЛИЕНТЫ могут загрузить ЛОТЫ (характеризуется владельцем, стартовой ценой, названием и описанием) для продажи, выставить лот на АУКЦИОН (характеризуется продаваемым лотом, ТИПОМ аукциона, текущим СОСТОЯНИЕМ, текущей лидирующей ставкой и временем начала/окончания; если аукцион завершился неудачно или продавец по каким-либо причинам снял лот с аукциона, то лот можно выставить повторно на НОВЫЙ аукцион), 
-- сделать СТАВКУ (характеризуется клиентом, аукционом и денежной суммой) в каком-то АУКЦИОНЕ и произвести ПЛАТЁЖ (включается в себя отправителя, получателя, размером перевода и датой превода). 
-- 
-- 
-- 
-- Примечание: выбор дополнительных собственных индексов (сумма денежного перевода, стартовая цена лота, название лота, логинами и т.д.) объясняется ожиданием поиска по заданным полям. Все таблицы имеют первичный ключ автоинкрементирующийся ключ - ID.

-- -----------------------------------------------------
-- Schema AUCTIONS
--
-- Английски аукцион (вариант 11).
-- 
-- 
-- 
-- Задача и развитие:
-- 
-- Администратор выставляет (снимает, блокирует) на торги лоты. Поддерживаются оба вида аукционов: прямой и обратный. 
-- Клиент может участвовать в аукционах, оплачивать покупки, предлагать администратору лоты для продажи. Администратор управляет клиентами и лотами.
-- 
-- 
-- 
-- Описание:
-- 
-- У нас есть система, где имеются АДМИНИСТРАТОРЫ (имеют поля: логин, зашифрованный пароль, имя и e-mail), которые управляют работой аукционов и производят с ними различные действия (выставление лота, снятие лота, блокировка, изменение статуса и т.д.), и КЛИЕНТЫ (имеют поля: логин, зашифрованный пароль, имя, e-mail и баланс личного счёта).
-- 
-- КЛИЕНТЫ могут загрузить ЛОТЫ (характеризуется владельцем, стартовой ценой, названием и описанием) для продажи, выставить лот на АУКЦИОН (характеризуется продаваемым лотом, ТИПОМ аукциона, текущим СОСТОЯНИЕМ, текущей лидирующей ставкой и временем начала/окончания; если аукцион завершился неудачно или продавец по каким-либо причинам снял лот с аукциона, то лот можно выставить повторно на НОВЫЙ аукцион), 
-- сделать СТАВКУ (характеризуется клиентом, аукционом и денежной суммой) в каком-то АУКЦИОНЕ и произвести ПЛАТЁЖ (включается в себя отправителя, получателя, размером перевода и датой превода). 
-- 
-- 
-- 
-- Примечание: выбор дополнительных собственных индексов (сумма денежного перевода, стартовая цена лота, название лота, логинами и т.д.) объясняется ожиданием поиска по заданным полям. Все таблицы имеют первичный ключ автоинкрементирующийся ключ - ID.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `AUCTIONS` DEFAULT CHARACTER SET utf8 ;
USE `AUCTIONS` ;

-- -----------------------------------------------------
-- Table `AUCTIONS`.`USER`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AUCTIONS`.`USER` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `LOGIN` VARCHAR(15) NOT NULL,
  `PASSWORD` VARCHAR(40) NOT NULL,
  `NAME` VARCHAR(15) NOT NULL,
  `EMAIL` VARCHAR(25) NOT NULL,
  `USER_TYPE` ENUM('client', 'provider', 'admin') NOT NULL DEFAULT 'client',
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `LOGIN_UNIQUE` (`LOGIN` ASC),
  UNIQUE INDEX `EMAIL_UNIQUE` (`EMAIL` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AUCTIONS`.`AUCTION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AUCTIONS`.`AUCTION` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `START_DATETIME` DATETIME NOT NULL,
  `STATE` ENUM('planned', 'running', 'finished') NOT NULL DEFAULT 'planned',
  PRIMARY KEY (`ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AUCTIONS`.`TRANSACTION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AUCTIONS`.`TRANSACTION` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CLIENT-PURCHASER_ID` INT UNSIGNED NOT NULL,
  `VALUE` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`ID`),
  INDEX `fk_TRANSACTION_USER1_idx` (`CLIENT-PURCHASER_ID` ASC),
  CONSTRAINT `fk_TRANSACTION_USER1`
    FOREIGN KEY (`CLIENT-PURCHASER_ID`)
    REFERENCES `AUCTIONS`.`USER` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AUCTIONS`.`REGISTRATION`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AUCTIONS`.`REGISTRATION` (
  `REGISTRATION_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `AUCTION_ID` INT UNSIGNED NOT NULL,
  `TRANSACTION_ID` INT UNSIGNED NULL,
  INDEX `fk_REGISTERED_FLOWER_LOT_AUCTION1_idx` (`AUCTION_ID` ASC),
  PRIMARY KEY (`REGISTRATION_ID`),
  INDEX `fk_REGISTERED_FLOWER_LOT_TRANSACTION1_idx` (`TRANSACTION_ID` ASC),
  CONSTRAINT `fk_REGISTERED_FLOWER_LOT_AUCTION1`
    FOREIGN KEY (`AUCTION_ID`)
    REFERENCES `AUCTIONS`.`AUCTION` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REGISTERED_FLOWER_LOT_TRANSACTION1`
    FOREIGN KEY (`TRANSACTION_ID`)
    REFERENCES `AUCTIONS`.`TRANSACTION` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AUCTIONS`.`FLOWER_LOT`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AUCTIONS`.`FLOWER_LOT` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `FLOWER_PROVIDER_ID` INT UNSIGNED NOT NULL,
  `FLOWER_NAME` VARCHAR(25) NOT NULL,
  `NUMBER_OF_FLOWERS` INT UNSIGNED NOT NULL,
  `START_PRICE` INT UNSIGNED NOT NULL,
  `ADDITIONAL_INFO` BLOB NULL,
  `REGISTRATION_ID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`ID`),
  INDEX `FLOWER_NAME_IND` (`FLOWER_NAME` ASC),
  INDEX `fk_FLOWER_LOT_FLOWER_PROVIDER1_idx` (`FLOWER_PROVIDER_ID` ASC),
  INDEX `fk_FLOWER_LOT_REGISTRATION1_idx` (`REGISTRATION_ID` ASC),
  CONSTRAINT `fk_FLOWER_LOT_FLOWER_PROVIDER1`
    FOREIGN KEY (`FLOWER_PROVIDER_ID`)
    REFERENCES `AUCTIONS`.`USER` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FLOWER_LOT_REGISTRATION1`
    FOREIGN KEY (`REGISTRATION_ID`)
    REFERENCES `AUCTIONS`.`REGISTRATION` (`REGISTRATION_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
