#include "filesystem.h"

#include <QDir>
#include <QFile>
#include <QUrl>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
{

}

bool FileSystem::exists(const QString& filename) const
{
    return QFile::exists(filename);
}

QString FileSystem::readFile(const QString& filename) const
{
    QFile file(filename);

    if(file.open(QIODevice::ReadOnly)) {
        return file.readAll();
    }

    return "";
}

QStringList FileSystem::listFiles(const QString& path) const
{
    QDir directory(path);
    return directory.entryList(QDir::Files | QDir::NoDot | QDir::NoDotDot);
}

QString FileSystem::toUrl(const QString& filename) const
{
    return QUrl::fromLocalFile(filename).toString();
}
