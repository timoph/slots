#include <QApplication>
#ifndef QT5BUILD
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>
#else
#include <QQuickView>
#include <QQmlContext>
#endif
#include <QUrl>

#include "gameengine.h"
#include "imageprovider.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
#ifndef QT5BUILD
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
#else
    QScopedPointer<QQuickView> view(new QQuickView);
#endif
    QScopedPointer<GameEngine> engine(new GameEngine);
    view->engine()->addImageProvider(QLatin1String("images"), new ImageProvider);
    view->rootContext()->setContextProperty("engine", engine.data());
    view->setSource(QUrl("qrc:/qml/main.qml"));
#ifndef QT5BUILD
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
#else
    view->setResizeMode(QQuickView::SizeRootObjectToView);
#endif
    view->show();

    QObject::connect(view->engine(), SIGNAL(quit()),
                     app.data(), SLOT(quit()));

    return app->exec();
}
