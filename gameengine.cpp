#include "gameengine.h"

#include <QDebug>
#include <QDateTime>
#include <QTimer>
#if QT_VERSION_MAJOR > 5
#include <QRandomGenerator>
#endif

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
    m_freeSpins = 0;
    m_freeSpinsTotal = 0;
    m_inFreeSpins = false;
    m_freeSpinsTotalWon = 0;

    for(int i = 0; i < 3; i++) {
        QList<int> list;
        for(int j = 0; j < 5; j++) {
#if QT_VERSION_MAJOR < 6
            list.append(qrand() % 9 + 1);
#else
            list.append(QRandomGenerator::global()->bounded(1, 10));
#endif
        }
        m_visibleRows.append(list);
    }

    populatePayTable();
#if QT_VERSION_MAJOR < 6
    qsrand(QDateTime::currentMSecsSinceEpoch());
#endif
    
    // Emit initial values to QML
    QTimer::singleShot(0, this, SIGNAL(slotsSpinned()));
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

    // Don't allow manual spins during free spins
    if(m_inFreeSpins) {
        return;
    }

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
#if QT_VERSION_MAJOR < 6
                list.append(qrand() % 9 + 1);
#else
                list.append(QRandomGenerator::global()->bounded(1, 10));
#endif
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
#if QT_VERSION_MAJOR < 6
                m_visibleRows[i][j] = qrand() % 9 + 1;
#else
                m_visibleRows[i][j] = QRandomGenerator::global()->bounded(1, 10);
#endif
            }
        }
    }

    if(m_shuffleCount < 15) {
        emit slotsSpinned();
        QTimer::singleShot(20 * m_shuffleCount, this, SLOT(shuffle()));
    }
    else {
        m_shuffleCount = 0;
        
        // Ensure only one bonus per reel (column)
        // Bonus symbol is value 1
        for(int col = 0; col < 5; col++) {
            int bonusCount = 0;
            int bonusRow = -1;
            
            // Count bonuses in this column
            for(int row = 0; row < 3; row++) {
                if(m_visibleRows.at(row).at(col) == 1) {
                    bonusCount++;
                    if(bonusRow == -1) {
                        bonusRow = row;
                    }
                }
            }
            
            // If more than one bonus in this column, replace extras with random symbols (2-9)
            if(bonusCount > 1) {
                for(int row = 0; row < 3; row++) {
                    if(m_visibleRows.at(row).at(col) == 1 && row != bonusRow) {
#if QT_VERSION_MAJOR < 6
                        m_visibleRows[row][col] = qrand() % 8 + 2; // Random value 2-9
#else
                        m_visibleRows[row][col] = QRandomGenerator::global()->bounded(2, 10); // Random value 2-9
#endif
                    }
                }
            }
        }
        
        emit slotsSpinned();
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

int GameEngine::freeSpins() const
{
    return m_freeSpins;
}

void GameEngine::setFreeSpins(const int spins)
{
    if(spins != m_freeSpins) {
        m_freeSpins = spins;
        emit freeSpinsChanged(m_freeSpins);
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
                if(m_visibleRows.at(1).at(4) == no) { // x5
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
        
        // Track free spins winnings
        if(m_inFreeSpins) {
            m_freeSpinsTotalWon += winnings * m_bet;
        }
        
        setMessage(QString("You won %1 credits! yay!").arg(winnings * m_bet));
        emit win(winnings);
    }

    // Check for bonuses
    checkBonuses();

    setPlayable(true);
}

void GameEngine::populatePayTable()
{
    //TODO: make this saner
    // Create pay table for symbols 0-9
    for(int i = 0; i < 10; i++) {
        QList<int> list;
        for(int j = 0; j < 5; j++) {
            if(j == 0 || j == 1) {
                list.append(0);
            }
            else {
                // Values 2-5 are pictures (higher payouts)
                if(i >= 2 && i <= 5) {
                    list.append(j == 4 ? (j + 1) * 4 : (j + 1) * 2);
                }
                // Value 1 is bonus (no regular payout)
                else if(i == 1) {
                    list.append(0);
                }
                // Values 6-9 are numbers (lower payouts)
                else if(i >= 6 && i <= 9) {
                    // Number payouts: 6=1 (smallest), 7=2, 8=5, 9=7 (best number)
                    int numberValue = 0;
                    if(i == 6) numberValue = 1;      // 1
                    else if(i == 7) numberValue = 2; // 2
                    else if(i == 8) numberValue = 3; // 5
                    else if(i == 9) numberValue = 4; // 7
                    
                    list.append(j == 4 ? (j + 1) * numberValue : (j + 1) * (numberValue > 0 ? numberValue : 1));
                }
                else {
                    list.append(j == 4 ? (j + 1) * 4 : (j + 1) * 2);
                }
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

void GameEngine::checkBonuses()
{
    // Count how many reels (columns) have at least one bonus symbol
    // Bonus symbol is value 1
    
    int bonusReelsCount = 0;
    
    // Check each reel/column
    for(int col = 0; col < 5; col++) {
        bool hasBonus = false;
        // Check all rows in this column
        for(int row = 0; row < 3; row++) {
            if(m_visibleRows.at(row).at(col) == 1) {
                hasBonus = true;
                break;
            }
        }
        if(hasBonus) {
            bonusReelsCount++;
        }
    }
    
    qDebug() << QString("Found bonus in %1 reels").arg(bonusReelsCount);
    
    if(bonusReelsCount >= 3 && !m_inFreeSpins) {
        int spinsAwarded = 0;
        if(bonusReelsCount == 3) spinsAwarded = 5;
        else if(bonusReelsCount == 4) spinsAwarded = 10;
        else if(bonusReelsCount >= 5) spinsAwarded = 15;
        
        qDebug() << QString("BONUS! Awarded %1 free spins").arg(spinsAwarded);
        
        m_freeSpins = spinsAwarded;
        m_freeSpinsTotal = spinsAwarded;
        m_inFreeSpins = true;
        m_freeSpinsTotalWon = 0;
        
        emit bonusTriggered(spinsAwarded);
        emit freeSpinsChanged(m_freeSpins);
        
        setMessage(QString("BONUS! %1 FREE SPINS!").arg(spinsAwarded));
        
        // Start free spins after a short delay
        QTimer::singleShot(2000, this, SLOT(playFreeSpinRound()));
    }
    else if(m_inFreeSpins && m_freeSpins > 0) {
        // Continue free spins
        QTimer::singleShot(1500, this, SLOT(playFreeSpinRound()));
    }
    else if(m_inFreeSpins && m_freeSpins == 0) {
        // Free spins complete
        m_inFreeSpins = false;
        emit freeSpinsComplete(m_freeSpinsTotalWon);
        setMessage(QString("Free spins complete! Won %1 total!").arg(m_freeSpinsTotalWon));
    }
}

void GameEngine::playFreeSpinRound()
{
    if(m_freeSpins > 0 && m_inFreeSpins) {
        m_freeSpins--;
        emit freeSpinsChanged(m_freeSpins);
        
        setMessage(QString("Free spin %1/%2").arg(m_freeSpinsTotal - m_freeSpins).arg(m_freeSpinsTotal));
        
        // Play a spin without deducting credits
        emit spinStarted();
        shuffle();
    }
}
