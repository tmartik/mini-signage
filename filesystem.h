#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>

class FileSystem : public QObject
{
    Q_OBJECT
public:
    explicit FileSystem(QObject *parent = nullptr);

    Q_INVOKABLE bool exists(const QString& filename) const;
    Q_INVOKABLE QString readFile(const QString& filename) const;
    Q_INVOKABLE QStringList listFiles(const QString& path) const;
    Q_INVOKABLE QString toUrl(const QString& filename) const;

};

#endif // FILESYSTEM_H
