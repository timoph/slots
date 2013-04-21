#include "imageprovider.h"

ImageProvider::ImageProvider() :
#ifndef QT5BUILD
    QDeclarativeImageProvider(QDeclarativeImageProvider::Pixmap)
#else
    QQuickImageProvider(QQuickImageProvider::Pixmap)
#endif
{
}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize)
    Q_UNUSED(size)
//    int width = 50;
//    int height = 50;

//    if (size)
//        *size = QSize(width, height);
    //QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
    //               requestedSize.height() > 0 ? requestedSize.height() : height);


    switch(id.toInt()) {
    case 0:
        return QPixmap(":/images/stone1.jpg");
        break;
    case 1:
        return QPixmap(":/images/axe1.jpg");
        break;
    case 2:
        return QPixmap(":/images/saw1.jpg");
        break;
    case 3:
        return QPixmap(":/images/hammer1.jpg");
        break;
    case 4:
        return QPixmap(":/images/spade1.jpg");
        break;
    case 5:
        return QPixmap(":/images/coins3.jpg");
        break;
    default:
        break;
    }

    return QPixmap();
}
