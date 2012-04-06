#include "imageprovider.h"

ImageProvider::ImageProvider() :
    QDeclarativeImageProvider(QDeclarativeImageProvider::Pixmap)
{
}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    int width = 50;
    int height = 50;

    QString fillColor = "black";

    switch(id.toInt()) {
    case 1:
        fillColor = "red";
        break;
    case 2:
        fillColor = "blue";
        break;
    case 3:
        fillColor = "green";
        break;
    case 4:
        fillColor = "yellow";
        break;
    case 5:
        fillColor = "cyan";
        break;
    default:
        break;
    }

    if (size)
        *size = QSize(width, height);
    QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
                   requestedSize.height() > 0 ? requestedSize.height() : height);
    //pixmap.fill(QColor(id).rgba());
    pixmap.fill(QColor(fillColor).rgba());
    return pixmap;
}
