#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H


#ifdef QT5BUILD
#include <QQuickImageProvider>
class ImageProvider : public QQuickImageProvider
#else
#include <QDeclarativeImageProvider>
class ImageProvider : public QDeclarativeImageProvider
#endif
{
public:
    explicit ImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // IMAGEPROVIDER_H
