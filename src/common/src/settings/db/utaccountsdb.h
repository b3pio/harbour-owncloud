#ifndef UTACCOUNTSDB_H
#define UTACCOUNTSDB_H

#include <QObject>
#include "accountsdbinterface.h"
#include "accountdb.h"
#include <lomiri-online-accounts-qt5/LomiriOnlineAccountsQt/Manager>

class UtAccountsDb : public AccountsDbInterface
{
    Q_OBJECT

    Q_PROPERTY(QVariantList accounts READ accountVariantList NOTIFY accountsChanged)

public:
    explicit UtAccountsDb(QObject *parent = nullptr);
    ~UtAccountsDb();
    Q_INVOKABLE void refresh() override;

public slots:
    QVector<AccountBase*> accounts() override;
    QVariantList accountVariantList() override;
    bool accountExists(const AccountBase* account) override;
    bool addAccount(AccountBase* account) override;
    bool updateAccount(AccountBase* account) override;
    bool removeAccount(AccountBase* account) override;

private:
    void refreshAccountType(const QString& desiredServiceId, QVector<AccountBase*>& accounts);

    OnlineAccounts::Manager* m_manager = nullptr;
    QVector<AccountBase*> m_accounts;
    AccountDb* m_webdavDb;
};

#endif // UTACCOUNTSDB_H
