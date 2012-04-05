#ifndef GAMEENGINE_H
#define GAMEENGINE_H

#include <QObject>

class GameEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int bet READ bet WRITE setBet NOTIFY betChanged)
    Q_PROPERTY(int lines READ selectedLines WRITE setSelectedLines NOTIFY selectedLinesChanged)
    Q_PROPERTY(int credits READ credits WRITE setCredits NOTIFY creditsChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    Q_PROPERTY(bool playable READ isPlayable WRITE setPlayable NOTIFY playableChanged)

public:
    explicit GameEngine(QObject *parent = 0);
    int bet() const;
    int selectedLines() const;
    int credits() const;
    bool isPlayable() const;
    Q_INVOKABLE int itemForPlace(const int row, const int  column);
    QString message() const;

signals:
    void win(int amount);
    void betChanged(int amount);
    void selectedLinesChanged(int count);
    void creditsChanged(int amount);
    void outOfCredits();
    void messageChanged(const QString &msg);
    void slotsSpinned();
    void playableChanged(bool is);
    void winningSlot(const int r, const int c);
    void spinStarted();
    
public slots:
    void setBet(const int bet);
    void setSelectedLines(const int lines);
    void setCredits(const int amount);
    void spin();
    void setMessage(const QString &msg);
    void setPlayable(bool is);

private slots:
    void checkLines();
    void shuffle();
//    void check1line();
//    void check2line();
//    void check3line();
//    void check4line();
//    void check5line();
//    void check6line();
//    void check7line();
//    void check8line();
//    void check9line();

// private functions
private:
    void populatePayTable();

// private variables
private:
    int m_shuffleCount;
    int m_bet; // default 1
    int m_selectedLines; // default 20
    int m_credits;
    float m_wildCardChange; // default 0.10
    float m_scatterChange; // default 0.05
    bool m_isPlayable;
    QString m_message;
    QList< QList<int> > m_visibleRows;
    QList< QList<int> > m_payTable;
};

#endif // GAMEENGINE_H
