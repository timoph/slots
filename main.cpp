#include <QApplication>
#ifdef QT5BUILD
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickView>
#else
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>
#endif
#include <QUrl>

#include "gameengine.h"
#include "imageprovider.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
#ifdef QT5BUILD
    QScopedPointer<QQuickView> view(new QQuickView);
    view->setResizeMode(QQuickView::SizeRootObjectToView);
#else
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
#endif
    QScopedPointer<GameEngine> engine(new GameEngine);
    view->engine()->addImageProvider(QLatin1String("images"), new ImageProvider);
    view->rootContext()->setContextProperty("engine", engine.data());
    view->setSource(QUrl("qrc:/qml/main.qml"));

    //view->showFullScreen();
    view->show();

    QObject::connect(view->engine(), SIGNAL(quit()),
                     app.data(), SLOT(quit()));

    return app->exec();
}
