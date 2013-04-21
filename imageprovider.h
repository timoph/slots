#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#ifndef QT5BUILD
#include <QDeclarativeImageProvider>
class ImageProvider : public QDeclarativeImageProvider
#else
#include <QQuickImageProvider>
class ImageProvider : public QQuickImageProvider
#endif
{
public:
    explicit ImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // IMAGEPROVIDER_H
