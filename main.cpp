#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeEngine>
#include <QUrl>

#include "gameengine.h"
#include "imageprovider.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
    QScopedPointer<GameEngine> engine(new GameEngine);
    view->engine()->addImageProvider(QLatin1String("images"), new ImageProvider);
    view->rootContext()->setContextProperty("engine", engine.data());
    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->show();

    QObject::connect(view->engine(), SIGNAL(quit()),
                     app.data(), SLOT(quit()));

    return app->exec();
}
