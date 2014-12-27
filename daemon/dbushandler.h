#ifndef DBUSHANDLER_H
#define DBUSHANDLER_H

#include <QDBusAbstractAdaptor>

class DBusHandler : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("dbus interface", "HarbourOwncloudDaemon")
    Q_PROPERTY(bool suspended READ suspended WRITE setSuspended NOTIFY suspendedChanged(bool))
    Q_PROPERTY(bool offline READ offline NOTIFY offlineChanged(bool))

public:
    explicit DBusHandler(QObject *parent = 0);
    ~DBusHandler();

public slots:
    void setSuspended(bool suspended);
    bool suspended() { return m_suspended; }

    void setOffline(bool offline);
    bool offline() { return m_offline; }

signals:
    void fileUploaded(QString filePath);
    void suspendedChanged(bool suspended);
    void offlineChanged(bool offline);

private:
    bool m_suspended;
    bool m_offline;
};

#endif // DBUSHANDLER_H
