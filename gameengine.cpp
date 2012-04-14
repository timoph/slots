#include "gameengine.h"

#include <QDebug>
#include <QDateTime>
#include <QTimer>

GameEngine::GameEngine(QObject *parent) :
    QObject(parent)
{
    m_bet = 1;
    m_selectedLines = 9;
    m_wildCardChange = 0.1;
    m_scatterChange = 0.05;
    m_credits = 100;
    m_message = "";
    m_isPlayable = true;
    m_shuffleCount = 0;

    for(int i = 0; i < 3; i++) {
        QList<int> list;
        for(int j = 0; j < 5; j++) {
            list.append(j);
        }
        m_visibleRows.append(list);
    }

    populatePayTable();
    qsrand(QDateTime::currentMSecsSinceEpoch());
}

int GameEngine::itemForPlace(const int row, const int column)
{
    if(m_visibleRows.count() > row) {
        if(m_visibleRows.at(row).count() > column) {
            return m_visibleRows.at(row).at(column);
        }
    }

    return -1; //error
}

void GameEngine::spin()
{
    qDebug() << __PRETTY_FUNCTION__;

    setMessage("");
    setPlayable(false);

    // check if enough credits
    int cost = m_selectedLines * m_bet;
    if(cost > m_credits) {
        qDebug() << "not enough credits";
        emit outOfCredits();
        setMessage(tr("Not enough credits"));
        setPlayable(true);
        return;
    }

    emit spinStarted();

    // gimme ya money
    setCredits(m_credits - cost);

    shuffle();
}

void GameEngine::shuffle()
{
    m_shuffleCount++;
    if(m_shuffleCount == 0) {
        m_visibleRows.clear();
        for(int i = 0; i < 3; i++) {
            QList<int> list;
            for(int j = 0; j < 5; j++) {
                list.append(qrand() % 5 + 1);
            }
            m_visibleRows.append(list);
        }
    }
    else {
        for(int i = 0; i < 3; i++) {
            for(int j = 0; j < 5; j++) {
                if(j == 0 && m_shuffleCount > 7) continue;
                else if(j == 1 && m_shuffleCount > 9) continue;
                else if(j == 2 && m_shuffleCount > 11) continue;
                else if(j == 3 && m_shuffleCount > 13) continue;

                m_visibleRows[i][j] = qrand() % 5 + 1;
            }
        }
    }

    emit slotsSpinned();

//        QString debugString;
//        for(int i = 0; i < 3; i++) {
//            for(int j = 0; j < 5; j++) {
//                debugString += QString(" %1 ").arg(m_visibleRows.at(i).at(j));
//            }
//            debugString += "\n";
//        }
//        qDebug() << debugString;

    if(m_shuffleCount < 15) {
        QTimer::singleShot(20 * m_shuffleCount, this, SLOT(shuffle()));
    }
    else {
        m_shuffleCount = 0;
        checkLines();
    }
}

int GameEngine::bet() const
{
    return m_bet;
}

void GameEngine::setBet(const int bet)
{
    if(bet != m_bet) {
        m_bet = bet;
        emit betChanged(m_bet);
    }
}

int GameEngine::selectedLines() const
{
    return m_selectedLines;
}

void GameEngine::setSelectedLines(const int lines)
{
    if(lines != m_selectedLines) {
        m_selectedLines = lines;
        emit selectedLinesChanged(m_selectedLines);
    }
}

bool GameEngine::isPlayable() const
{
    return m_isPlayable;
}

void GameEngine::setPlayable(bool is)
{
    if(is != m_isPlayable) {
        m_isPlayable = is;
        emit playableChanged(m_isPlayable);
    }
}

int GameEngine::credits() const
{
    return m_credits;
}

void GameEngine::setCredits(const int amount)
{
    if(m_credits != amount) {
        m_credits = amount;
        qDebug() << QString("player now has %1 credits").arg(m_credits);
        emit creditsChanged(m_credits);
    }
}

QString GameEngine::message() const
{
    return m_message;
}

void GameEngine::setMessage(const QString &msg)
{
    if(msg != m_message) {
        m_message = msg;
        emit messageChanged(m_message);
    }
}

void GameEngine::checkLines()
{
    qDebug() << __PRETTY_FUNCTION__;
    // 1st row
    /* winning lines
      11 12 13 14 15 - line 2
      11 22 13 24 15 - line 8
      11 12 23 14 15 - line 6
      */
    int no = m_visibleRows.at(0).at(0);
    int factor = 0;
    int winnings = 0;
    if(m_visibleRows.at(0).at(1) == no) {
        if(m_visibleRows.at(0).at(2) == no && m_selectedLines > 1) { // x3
            factor = 2;
            emit winningSlot(0, 0);
            emit winningSlot(0, 1);
            emit winningSlot(0, 2);
            if(m_visibleRows.at(0).at(3) == no) { // x4
                factor = 3;
                emit winningSlot(0, 3);
                if(m_visibleRows.at(0).at(4) == no) { // x5
                    emit winningSlot(0, 4);
                    factor = 4;
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(0).at(1) == no && m_selectedLines > 5) { // x3
            if(m_visibleRows.at(1).at(2) == no) {
                factor = 2;
                emit winningSlot(0, 0);
                emit winningSlot(0, 1);
                emit winningSlot(1, 2);
                if(m_visibleRows.at(0).at(3) == no) {
                    factor = 3;
                    emit winningSlot(0, 3);
                    if(m_visibleRows.at(0).at(4) == no) {
                        factor = 4;
                        emit winningSlot(0, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(1).at(1) == no && m_selectedLines > 7) {
            if(m_visibleRows.at(0).at(2) == no) { // x3
                factor = 2;
                emit winningSlot(0, 0);
                emit winningSlot(1, 1);
                emit winningSlot(0, 2);
                if(m_visibleRows.at(1).at(3) == no) {
                    factor = 3;
                    emit winningSlot(1, 3);
                    if(m_visibleRows.at(0).at(4) == no) {
                        factor = 4;
                        emit winningSlot(0, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }
    }

    // 2nd row
    /* winning lines
      21 22 23 24 25 - line 1
      21 22 13 24 25 - line 4
      21 22 33 24 25 - line 5
      */
    no = m_visibleRows.at(1).at(0);
    if(m_visibleRows.at(1).at(1) == no) {
        if(m_visibleRows.at(1).at(2) == no) { // x3
            factor = 2;
            emit winningSlot(1, 0);
            emit winningSlot(1, 1);
            emit winningSlot(1, 2);
            if(m_visibleRows.at(1).at(3) == no) { // x4
                factor = 3;
                emit winningSlot(1, 3);
                if(m_visibleRows.at(1).at(4) == 0) { // x5
                    factor = 4;
                    emit winningSlot(1, 4);
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(1).at(1) == no && m_selectedLines > 3) {
            if(m_visibleRows.at(2).at(2) == no) {
                factor = 2;
                emit winningSlot(1, 0);
                emit winningSlot(1, 1);
                emit winningSlot(2, 2);
                if(m_visibleRows.at(1).at(3) == no) {
                    factor = 3;
                    emit winningSlot(1, 3);
                    if(m_visibleRows.at(1).at(4) == no) {
                        factor = 4;
                        emit winningSlot(1, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(1).at(1) == no && m_selectedLines > 4) {
            if(m_visibleRows.at(0).at(2) == no) { // x3
                factor = 2;
                emit winningSlot(1, 0);
                emit winningSlot(1, 1);
                emit winningSlot(0, 2);
                if(m_visibleRows.at(1).at(3) == no) {
                    factor = 3;
                    emit winningSlot(1, 3);
                    if(m_visibleRows.at(1).at(4) == no) {
                        factor = 4;
                        emit winningSlot(1, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }
    }


    // 3rd row
    /* winning lines
      31 32 33 34 35 - line 3
      31 22 33 24 35 - line 9
      31 32 23 34 35 - line 7
      */
    no = m_visibleRows.at(2).at(0);
    if(m_visibleRows.at(2).at(1) == no && m_selectedLines > 2) {
        if(m_visibleRows.at(2).at(2) == no) { // x3
            factor = 2;
            emit winningSlot(2, 0);
            emit winningSlot(2, 1);
            emit winningSlot(2, 2);
            if(m_visibleRows.at(2).at(3) == no) { // x4
                factor = 3;
                emit winningSlot(2, 3);
                if(m_visibleRows.at(2).at(4) == no) { // x5
                    factor = 4;
                    emit winningSlot(2, 4);
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(1).at(1) == no && m_selectedLines > 8) { // x3
            if(m_visibleRows.at(2).at(2) == no) {
                factor = 2;
                emit winningSlot(2, 0);
                emit winningSlot(1, 1);
                emit winningSlot(2, 2);
                if(m_visibleRows.at(1).at(3) == no) {
                    factor = 3;
                    emit winningSlot(1, 3);
                    if(m_visibleRows.at(2).at(4) == no) {
                        factor = 4;
                        emit winningSlot(2, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }

        if(m_visibleRows.at(2).at(1) == no && m_selectedLines > 6) {
            if(m_visibleRows.at(1).at(2) == no) { // x3
                factor = 2;
                emit winningSlot(2, 0);
                emit winningSlot(2, 1);
                emit winningSlot(1, 2);
                if(m_visibleRows.at(2).at(3) == no) {
                    factor = 3;
                    emit winningSlot(2, 3);
                    if(m_visibleRows.at(2).at(4) == no) {
                        factor = 4;
                        emit winningSlot(2, 4);
                    }
                }
            }
            winnings += m_payTable.at(no).at(factor) * no;
            factor = 0;
        }
    }


    // if so - how much did it win
    qDebug() << QString("Won %1").arg(winnings);
    if(winnings > 0) {
        setCredits(m_credits + winnings * m_bet);
        setMessage(QString("You won %1 credits! yay!").arg(winnings * m_bet));
        emit win(winnings);
    }

    setPlayable(true);
}

void GameEngine::populatePayTable()
{
    //TODO: make this saner
    for(int i = 0; i < 8; i++) {
        QList<int> list;
        for(int j = 0; j < 5; j++) {
            if(j == 0 || j == 1) {
                list.append(0);
            }
            else {
                list.append(j == 4 ? (j + 1) * 4 : (j + 1) * 2);
            }
        }
        m_payTable.append(list);
    }

//    qDebug() << QString("%1 x %2 pay table generated").arg(m_payTable.at(0).count()).arg(m_payTable.count());
//    QString tableContents;
//    for(int i = 0; i < 8; i++) {
//        for(int j = 0; j < 5; j++) {
//            tableContents += QString("\t%1").arg(m_payTable.at(i).at(j));
//        }
//        tableContents += "\n";
//    }
//    qDebug() << tableContents;
}
