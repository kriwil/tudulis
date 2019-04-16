/**
 * Copyright (c) 2011 Nokia Corporation.
 */

#ifndef DATABASEMANAGER_H_
#define DATABASEMANAGER_H_

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QPixmap>
#include <QDate>
#include <QVariant>

// ---------------------------------------------------------------------------
// RentItem
// ---------------------------------------------------------------------------
class RentItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int index READ index WRITE setIndex)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(int cost READ cost WRITE setCost)

public:
    RentItem(QObject* parent=0);
    ~RentItem();

    int index() const;
    void setIndex(const int);

    QString name() const;
    void setName(const QString);

    int cost() const;
    void setCost(const int);

public:
    int m_id;
    QString m_name;
    int m_cost;
};

// ---------------------------------------------------------------------------
// Rent
// ---------------------------------------------------------------------------
class Rent : public QObject // Rent data
{
    Q_OBJECT
    Q_PROPERTY(int index READ index WRITE setIndex)
    Q_PROPERTY(int itemId READ itemId WRITE setItemId)
    Q_PROPERTY(int renterId READ renterId WRITE setRenterId)
    Q_PROPERTY(int date READ date WRITE setDate)
    Q_PROPERTY(int rentBlockIndex READ rentBlockIndex WRITE setRentBlockIndex)

public:
    Rent(QObject* parent=0);
    ~Rent();

    int index() const;
    void setIndex(const int);

    int rentBlockIndex() const;
    void setRentBlockIndex(const int);

    int itemId() const;
    void setItemId(const int);

    int renterId() const;
    void setRenterId(const int);

    int date() const;
    void setDate(const int);

public:
    int m_id;
    int m_itemId;
    int m_renterId;
    int m_date;
    int m_rentBlockIndex;
};

// ---------------------------------------------------------------------------
// Renter
// ---------------------------------------------------------------------------
class Renter : public QObject // Who has rent the item
{
    Q_OBJECT
    Q_PROPERTY(int index READ index WRITE setIndex)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QString phone READ phone WRITE setPhone)

public:
    Renter(QObject* parent=0);
    ~Renter();

    int index() const;
    void setIndex(const int);

    QString name() const;
    void setName(const QString);

    QString phone() const;
    void setPhone(const QString);

public:
    int m_id;
    QString m_name;
    QString m_phone;
    bool m_popular;
};

// ---------------------------------------------------------------------------
// DatabaseManager
// ---------------------------------------------------------------------------
class DatabaseManager: public QObject
{
    Q_OBJECT

public:
    DatabaseManager(QObject *parent = 0);
    ~DatabaseManager();

public:
    Q_INVOKABLE void open();
    Q_INVOKABLE void close();
    Q_INVOKABLE void deleteDB();


    // for RentItemTable
    Q_INVOKABLE QVariant insertRentItem(const QVariant& name,
                                        const QVariant& cost);
    Q_INVOKABLE QList<QObject*> rentItems(const QVariant& useCache);
    Q_INVOKABLE QVariant updateRentItem(const QVariant& id,
                                        const QVariant& name,
                                        const QVariant& cost);
    Q_INVOKABLE void deleteRentItem(const int id);


    // for RentTable
    Q_INVOKABLE void insertRent(const int year, const int month, const int day,
                                const int rentBlock, const int rentItemId, const int renterId);
    Q_INVOKABLE void deleteRent(const int id);
    Q_INVOKABLE void deleteRentBlock(const int id);
    Q_INVOKABLE qint64 lastBookedRentBlockDate(const int rentBlockId);
    Q_INVOKABLE qint64 firstBookedRentBlockDate(const int rentBlockId);
    Q_INVOKABLE QList<QObject*> rents();
    Q_INVOKABLE QList<QObject*> dateRents(const int year,
                                          const int month,
                                          const int day);
    Q_INVOKABLE bool isFreeRentDate(const int rentItemId,
                                    const int year,
                                    const int month,
                                    const int day);


    // for RenterTable
    Q_INVOKABLE int insertRenter(const QVariant& name,
                                 const QVariant& phone);
    Q_INVOKABLE void updateRenter(const int renterId,
                                  const QVariant& name,
                                  const QVariant& phone);
    Q_INVOKABLE QObject* renter(const int id);


    Q_INVOKABLE int nextId();
    QSqlError lastError();

private:
    bool openDB();
    bool initDB();
    bool createIdTable();
    bool createRentItemTable();
    bool createRentTable();
    bool createRenterTable();

private:
    QSqlDatabase db;

    QList<QObject*>     m_rentItemsCache;
};

#endif /* DATABASEMANAGER_H_ */
