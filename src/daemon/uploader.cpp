#include "uploader.h"

#include <commands/sync/ncsynccommandunit.h>
#include <commands/webdav/mkdavdircommandentity.h>

#include <QDir>

Uploader::Uploader(QObject *parent,
                   const QString& targetDirectory,
                   NetworkMonitor* networkMonitor,
                   AccountBase* settings) :
    QObject(parent),
    m_targetDirectory(targetDirectory),
    m_networkMonitor(networkMonitor),
    m_settings(settings),
    m_webDavCommandQueue(new WebDavCommandQueue(this, settings))
{
    this->m_webDavCommandQueue->setImmediate(false);
    QObject::connect(this->m_webDavCommandQueue, &WebDavCommandQueue::runningChanged,
                     this, &Uploader::runningChanged);
}

void Uploader::triggerSync(const QString &localPath, const QString &remoteSubdir)
{
    if (!(this->m_webDavCommandQueue && this->m_settings && this->m_networkMonitor)) {
        qCritical() << "Invalid object existance (webDavQueue, settings, netMonitor), "
                    << "bailing out.";
        return;
    }

    qDebug() << "shouldDownload" << this->m_networkMonitor->shouldSync();
    qDebug() << "uploadAutomatically" << this->m_settings->uploadAutomatically();

    if (!(shouldSync())) {
        this->m_webDavCommandQueue->stop();
        return;
    }

    // detect if sync for "localPath" is in the queue already
    if (m_syncingPaths.contains(localPath)){
        qWarning() << "Syncing already:" << localPath;
        return;
    }

    QString remoteDir = this->m_targetDirectory + '/' + remoteSubdir + '/';
    qInfo() << "Trigger sync" << localPath << "to" << remoteDir;

    // create parent directory
    // NcSyncCommandUnit dont creating remote directories recursively
    // TODO: do it properly
    CommandEntity* mkdirRequest1 = this->m_webDavCommandQueue->makeDirectoryRequest(this->m_targetDirectory, false);
    CommandEntity* mkdirRequest2 = this->m_webDavCommandQueue->makeDirectoryRequest(remoteDir, false);

    NcSyncCommandUnit* syncDirectoriesUnit =
            new NcSyncCommandUnit(this->m_webDavCommandQueue,
                                  this->m_webDavCommandQueue,
                                  localPath,
                                  remoteDir);

    m_syncingPaths << localPath;

    connect(syncDirectoriesUnit, &CommandEntity::aborted, [localPath, this](){ m_syncingPaths.remove(localPath); });
    connect(syncDirectoriesUnit, &CommandEntity::done,    [localPath, this](){ m_syncingPaths.remove(localPath); });

    this->m_webDavCommandQueue->enqueue(mkdirRequest1);
    this->m_webDavCommandQueue->enqueue(mkdirRequest2);
    this->m_webDavCommandQueue->enqueue(syncDirectoriesUnit);
    this->m_webDavCommandQueue->run();
}

void Uploader::stopSync()
{
    if (!this->m_webDavCommandQueue) {
        qCritical() << "Invalid object existance (webDavQueue, settings, netMonitor), "
                    << "bailing out.";
        return;
    }
    this->m_webDavCommandQueue->stop();
}

bool Uploader::running()
{
    if (!this->m_webDavCommandQueue) {
        qCritical() << "Invalid object existance (webDavQueue), "
                    << "bailing out.";
        return false;
    }
    return this->m_webDavCommandQueue->isRunning();
}

bool Uploader::shouldSync()
{
    if (!(this->m_settings && this->m_networkMonitor)) {
        qCritical() << "Invalid object existance (settings, netMonitor), "
                    << "bailing out.";
        return false;
    }

    return (this->m_networkMonitor->shouldSync() && this->m_settings->uploadAutomatically());
}
