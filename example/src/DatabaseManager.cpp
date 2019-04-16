/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#include "DatabaseManager.h"
#include <QStringList>
#include <QDir>
#include <QVariant>
#include <QBuffer>
#include <QFile>
#include <QDesktopServices>
#include <QDebug>

// ---------------------------------------------------------------------------
// RentItem
// ---------------------------------------------------------------------------
RentItem::RentItem(QObject* parent) : QObject(parent)
{
    m_id = 0;
}

RentItem::~RentItem()
{
}

int RentItem::index() const
{
    return m_id;
}

void RentItem::setIndex(const int id)
{
    m_id = id;
}

QString RentItem::name() const
{
    return m_name;
}

void RentItem::setName(const QString name)
{
    m_name = name;
}

int RentItem::cost() const
{
    return m_cost;
}

void RentItem::setCost(const int cost)
{
    m_cost = cost;
}


// ---------------------------------------------------------------------------
// Rent
// ---------------------------------------------------------------------------
Rent::Rent(QObject* parent) : QObject(parent)
{
    m_id = 0;
    m_itemId = 0;
    m_renterId = 0;
}
Rent::~Rent()
{
}

int Rent::index() const
{
    return m_id;
}

void Rent::setIndex(const int index)
{
    m_id = index;
}

int Rent::itemId() const
{
    return m_itemId;
}

int Rent::rentBlockIndex() const
{
    return m_rentBlockIndex;
}

void Rent::setRentBlockIndex(const int index)
{
    m_rentBlockIndex = index;
}

void Rent::setItemId(const int itemId)
{
    m_itemId = itemId;
}

int Rent::renterId() const
{
    return m_renterId;
}

void Rent::setRenterId(const int renterId)
{
    m_renterId = renterId;
}

int Rent::date() const
{
    return m_date;
}

void Rent::setDate(const int date)
{
    m_date = date;
}


// ---------------------------------------------------------------------------
// Renter
// ---------------------------------------------------------------------------
Renter::Renter(QObject* parent) : QObject(parent)
{
    m_id = 0;
}
Renter::~Renter()
{
}

int Renter::index() const
{
    return m_id;
}

void Renter::setIndex(const int index)
{
    m_id = index;
}

QString Renter::name() const
{
    return m_name;
}

void Renter::setName(const QString name)
{
    m_name = name;
}

QString Renter::phone() const
{
    return m_phone;
}

void Renter::setPhone(const QString phone)
{
    m_phone = phone;
}



// ---------------------------------------------------------------------------
// DatabaseManager
// ---------------------------------------------------------------------------
DatabaseManager::DatabaseManager(QObject *parent) :
    QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    close();
}

void DatabaseManager::open()
{
    openDB();
    initDB();
}

void DatabaseManager::close()
{
    if (db.isOpen())
        db.close();
}

bool DatabaseManager::openDB()
{
    // Find QSLite driver
    db = QSqlDatabase::addDatabase("QSQLITE");
    // http://doc.trolltech.com/sql-driver.html#qsqlite

    QString path(QDir::home().path());
    path.append(QDir::separator()).append("rentbook2.0.db.sqlite");
    path = QDir::toNativeSeparators(path);
    db.setDatabaseName(path);

    // Open databasee
    return db.open();
}

bool DatabaseManager::initDB()
{
    bool ret = true;

    // Create 4 tables
    if (createIdTable()) {
        createRentItemTable();
        createRentTable();
        createRenterTable();
    }

    // Check that tables exists
    if (db.tables().count() != 4)
        ret = false;

    return ret;
}

void DatabaseManager::deleteDB()
{
    db.close();

    QString path(QDir::home().path());
    path.append(QDir::separator()).append("rentbook2.0.db.sqlite");
    path = QDir::toNativeSeparators(path);

    QFile::remove(path);
}

QSqlError DatabaseManager::lastError()
{
    return db.lastError();
}

bool DatabaseManager::createIdTable()
{
    // Create table
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table id "
                         "(id integer primary key)");
    }
    return ret;
}

bool DatabaseManager::createRentTable()
{
    // Create table
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table rent "
                         "(id integer primary key, "
                         "block integer, "
                         "itemid integer, "
                         "renterid integer, "
                         "date integer)");

    }
    return ret;
}

bool DatabaseManager::createRenterTable()
{
    // Create table
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table renter "
                         "(id integer primary key, "
                         "name varchar(50), "
                         "phone varchar(20), "
                         "popular integer)");

    }
    return ret;
}

bool DatabaseManager::createRentItemTable()
{
    // Create table
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table rentitem "
                         "(id integer primary key, " // this is autoincrement field http://www.sqlite.org/autoinc.html
                         "name varchar(20), "
                         "picture BLOB, "
                         "cost integer)");

    }
    return ret;
}

int DatabaseManager::nextId()
{
    int ret = 0;
    if (db.isOpen()) {
        QSqlQuery query("select id from id");
        if (query.next()) {
            // Get last used id
            ret = query.value(0).toInt();
            // Increase that
            ret++;
            // Store new value
            query.exec(QString("update id set id=%1 where id=%2").arg(ret).arg(ret - 1));
        }
        else {
            // Set first id to zero
            query.exec("insert into id values(1)");
            ret = 1;
        }
    }

    return ret;
}


QVariant DatabaseManager::updateRentItem(const QVariant& id,
                                         const QVariant& name,
                                         const QVariant& cost)
{
    bool ret = false;
    QSqlQuery query;
    ret = query.prepare("UPDATE rentitem SET name = :name, cost = :cost where id = :id");
    if (ret) {
        query.bindValue(":name", name);
        query.bindValue(":cost", cost);
        query.bindValue(":id", id);
        ret = query.exec();
    }
    return QVariant(ret);
}

void DatabaseManager::deleteRentItem(const int id)
{
    QSqlQuery query;
    query.exec(QString("delete from rentitem where id = %1").arg(id));
}

QVariant DatabaseManager::insertRentItem(const QVariant& name,
                                         const QVariant& cost)
{
    RentItem item;
    item.m_name = name.toString();
    item.m_cost = cost.toInt();

    bool ret = false;
    int retVal = -1;
    if (db.isOpen()) {
        //item->id = nextId(); // We demostrates autoincrement in this case

        // http://www.sqlite.org/autoinc.html
        // NULL = is the keyword for the autoincrement to generate next value

        QSqlQuery query;
        ret = query.prepare("INSERT INTO rentitem (name, cost) "
                            "VALUES (:name, :cost)");
        if (ret) {
            query.bindValue(":name", item.m_name);
            query.bindValue(":cost", item.m_cost);
            ret = query.exec();
        }

        // Get database given autoincrement value
        if (ret) {
            // http://www.sqlite.org/c3ref/last_insert_rowid.html  
            item.m_id = query.lastInsertId().toInt();
            retVal = item.m_id;
        }
    }
    return QVariant(retVal);
}

QList<QObject*> DatabaseManager::rentItems(const QVariant& useCache)
{
    bool cache = useCache.toBool();

    if (cache && m_rentItemsCache.length()>0) {
        //qDebug() << "Using Cache";
        //qDebug() << "Rent items count :"  << m_rentItemsCache.length();
        return m_rentItemsCache;
    } else {
        //qDebug() << "Filling Cache";
        m_rentItemsCache.clear();
        QSqlQuery query("select * from rentitem");
        while (query.next()) {
            RentItem* item = new RentItem();
            item->m_id = query.value(0).toInt();
            item->m_name = query.value(1).toString();
            item->m_cost = query.value(3).toInt();
            m_rentItemsCache.append(item);
        }
        //qDebug() << "Rent items count :"  << m_rentItemsCache.length();
        return m_rentItemsCache;
    }
}


void DatabaseManager::insertRent(const int year, const int month, const int day,
                                 const int rentBlock, const int rentItemId, const int renterId)
{
    QDate date;
    date.setDate(year,month,day);

    if (db.isOpen()) {
        Rent* rent = new Rent();
        rent->m_id = nextId();
        rent->m_rentBlockIndex = rentBlock;
        rent->m_itemId = rentItemId;
        rent->m_renterId = renterId;

        rent->m_date = date.toJulianDay();

        QSqlQuery query;
        query.exec(QString("insert into rent values(%1,%2,'%3',%4,%5)").arg(rent->m_id).arg(rent->m_rentBlockIndex).arg(
                       rent->m_itemId).arg(rent->m_renterId).arg(rent->m_date));
        delete rent;
    }
}

void DatabaseManager::deleteRent(const int id)
{
    if (db.isOpen()) {
        QSqlQuery query;
        query.exec(QString("delete from rent where id = %1").arg(id));
    }
}

void DatabaseManager::deleteRentBlock(const int id)
{
    if (db.isOpen()) {
        QSqlQuery query;
        query.exec(QString("delete from rent where block = %1").arg(id));
    }
}

QList<QObject*> DatabaseManager::rents()
{
    QList<QObject*> result;
    QSqlQuery query("select * from rent");
    while (query.next()) {
        Rent* item = new Rent();
        item->m_id = query.value(0).toInt();
        item->m_rentBlockIndex = query.value(1).toInt();
        item->m_itemId = query.value(2).toInt();
        item->m_renterId = query.value(3).toInt();
        item->m_date = query.value(4).toInt();
        result.append(item);
    }
    return result;
}

QList<QObject*> DatabaseManager::dateRents(const int year, const int month, const int day)
{
    QList<QObject*> result;
    QDate date;
    date.setDate(year,month,day);

    QSqlQuery query(QString("select * from rent where date = %1").arg(date.toJulianDay()));
    while (query.next()) {
        Rent* item = new Rent();
        item->m_id = query.value(0).toInt();
        item->m_rentBlockIndex = query.value(1).toInt();
        item->m_itemId = query.value(2).toInt();
        item->m_renterId = query.value(3).toInt();
        item->m_date = query.value(4).toInt();
        result.append(item);
    }
    return result;
}

bool DatabaseManager::isFreeRentDate(const int rentItemId, const int year, const int month, const int day)
{
    QDate date;
    date.setDate(year,month,day);

    QSqlQuery query(QString("select * from rent where date = %1 and itemid = %2").arg(date.toJulianDay()).arg(rentItemId));
    while (query.next()) {
        return false;
    }
    return true;
}

qint64 DatabaseManager::lastBookedRentBlockDate(const int rentBlockId)
{
    qint64 ret = -1;
    QSqlQuery query(QString("select * from rent where block = %1").arg(rentBlockId));
    while (query.next()) {
        if(query.last()) {
            int julian = query.value(4).toInt();
            QDate date = QDate::fromJulianDay(julian);
            QDateTime dt(date);
            ret = dt.toMSecsSinceEpoch();
        }
    }
    return ret;
}

qint64 DatabaseManager::firstBookedRentBlockDate(const int rentBlockId)
{
    qint64 ret = -1;
    QSqlQuery query(QString("select * from rent where block = %1").arg(rentBlockId));
    while (query.next()) {
        if (query.first()) {
            int julian = query.value(4).toInt();
            QDate date = QDate::fromJulianDay(julian);
            QDateTime dt(date);
            ret = dt.toMSecsSinceEpoch();
            break;
        }
    }
    return ret;
}

int DatabaseManager::insertRenter(const QVariant& name,
                                  const QVariant& phone)
{
    int renterId = -1;
    if (db.isOpen()) {
        QSqlQuery query;
        bool ret = query.prepare("INSERT INTO renter (id, name, phone, popular) "
                                 "VALUES (:id, :name, :phone, :popular)");
        if (ret) {
            renterId = nextId();
            query.bindValue(":id", renterId);
            query.bindValue(":name", name);
            query.bindValue(":phone", phone);
            query.bindValue(":popular", false);
            query.exec();
        }
    }
    return renterId;
}

void DatabaseManager::updateRenter(const int renterId,
                                   const QVariant& name,
                                   const QVariant& phone)
{
    QSqlQuery query;
    bool ret = query.prepare("UPDATE renter SET name = :name, phone = :phone where id = :id");
    if (ret) {
        query.bindValue(":name", name);
        query.bindValue(":phone", phone);
        query.bindValue(":id", renterId);
        ret = query.exec();
    }
}


QObject* DatabaseManager::renter(const int id)
{
    Renter* renter = new Renter(this);
    QSqlQuery query(QString("select * from renter where id = %1").arg(id));
    if (query.next()) {
        renter->m_id = query.value(0).toInt();
        renter->m_name = query.value(1).toString();
        renter->m_phone = query.value(2).toString();
        renter->m_popular = query.value(3).toInt();
    }
    return renter;
}

