#include "gameengine.h"

#include <QDebug>
#include <QDateTime>
#include <QTimer>
#if QT_VERSION_MAJOR > 5
#include <QRandomGenerator>
#endif

const int GameEngine::m_linePatterns[9][5][2] = {
    {{1,0}, {1,1}, {1,2}, {1,3}, {1,4}}, // Line 1: Middle row
    {{0,0}, {0,1}, {0,2}, {0,3}, {0,4}}, // Line 2: Top row
    {{2,0}, {2,1}, {2,2}, {2,3}, {2,4}}, // Line 3: Bottom row
    {{1,0}, {1,1}, {2,2}, {1,3}, {1,4}}, // Line 4: V shape
    {{1,0}, {1,1}, {0,2}, {1,3}, {1,4}}, // Line 5: ^ shape
    {{0,0}, {0,1}, {1,2}, {0,3}, {0,4}}, // Line 6: Top with dip
    {{2,0}, {2,1}, {1,2}, {2,3}, {2,4}}, // Line 7: Bottom with bump
    {{0,0}, {1,1}, {0,2}, {1,3}, {0,4}}, // Line 8: Zigzag top
    {{2,0}, {1,1}, {2,2}, {1,3}, {2,4}}  // Line 9: Zigzag bottom
};

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
            list.append(generateRandomSymbol());
        }
        m_visibleRows.append(list);
    }
    
    ensureValidBoard();

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

int GameEngine::generateRandomSymbol()
{
    int threshold = m_scatterChange * 1000;
    int wildThreshold = m_wildCardChange * 1000;
    int r = 0;
#if QT_VERSION_MAJOR < 6
    r = qrand() % 1000;
#else
    r = QRandomGenerator::global()->bounded(0, 1000);
#endif

    if (r < threshold) {
        return 1;
    } else if (r < threshold + wildThreshold && m_inFreeSpins) {
        return 0; // Wild (only in free spins)
    } else {
#if QT_VERSION_MAJOR < 6
        return (qrand() % 4) + 2;
#else
        return QRandomGenerator::global()->bounded(2, 6);
#endif
    }
}

void GameEngine::ensureValidBoard()
{
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
        
        // If more than one bonus in this column, replace extras with random symbols (2-5)
        if(bonusCount > 1) {
            for(int row = 0; row < 3; row++) {
                if(m_visibleRows.at(row).at(col) == 1 && row != bonusRow) {
#if QT_VERSION_MAJOR < 6
                    m_visibleRows[row][col] = qrand() % 4 + 2; // Random value 2-5
#else
                    m_visibleRows[row][col] = QRandomGenerator::global()->bounded(2, 6); // Random value 2-5
#endif
                }
            }
        }
    }
}

void GameEngine::shuffle()
{
    m_shuffleCount++;
    if(m_shuffleCount == 0) {
        m_visibleRows.clear();
        for(int i = 0; i < 3; i++) {
            QList<int> list;
            for(int j = 0; j < 5; j++) {
                int sym = generateRandomSymbol();
                if (sym == 1) {
                    bool existingBonus = false;
                    for(int k = 0; k < i; k++) {
                        if (m_visibleRows[k][j] == 1) {
                            existingBonus = true;
                            break;
                        }
                    }
                    if (existingBonus) {
                        do {
                            sym = generateRandomSymbol();
                        } while (sym == 1);
                    }
                }
                list.append(sym);
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
                
                int sym = generateRandomSymbol();
                if (sym == 1) {
                    bool existingBonus = false;
                    for(int k = 0; k < i; k++) {
                        if (m_visibleRows[k][j] == 1) {
                            existingBonus = true;
                            break;
                        }
                    }
                    if (existingBonus) {
                        do {
                            sym = generateRandomSymbol();
                        } while (sym == 1);
                    }
                }
                
                // Apply sticky wilds
                if (m_inFreeSpins) {
                    for (const QPoint &p : m_stickyWilds) {
                        if (p.x() == i && p.y() == j) {
                            sym = 0; // Force sticky wild
                            break;
                        }
                    }
                }
                
                m_visibleRows[i][j] = sym;
            }
        }
    }

    if(m_shuffleCount < 15) {
        emit slotsSpinned();
        QTimer::singleShot(20 * m_shuffleCount, this, SLOT(shuffle()));
    }
    else {
        m_shuffleCount = 0;
        
        ensureValidBoard();
        
        // Re-apply sticky wilds after ensureValidBoard just in case
        if (m_inFreeSpins) {
            for (const QPoint &p : m_stickyWilds) {
                m_visibleRows[p.x()][p.y()] = 0;
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
    
    int winnings = 0;
    
    // Iterate through all 9 lines
    for (int i = 0; i < 9; i++) {
        // Check if this line is selected
        if (i >= m_selectedLines) continue;
        
        // Get the first symbol of the line
        int r0 = m_linePatterns[i][0][0];
        int c0 = m_linePatterns[i][0][1];
        int firstSymbol = m_visibleRows.at(r0).at(c0);
        
        // Determine the effective symbol for this line
        // If first is Wild (0), look ahead for non-wild
        int effectiveSymbol = firstSymbol;
        if (effectiveSymbol == 0) {
            for (int j = 1; j < 5; j++) {
                int r = m_linePatterns[i][j][0];
                int c = m_linePatterns[i][j][1];
                int sym = m_visibleRows.at(r).at(c);
                if (sym != 0) {
                    effectiveSymbol = sym;
                    break;
                }
            }
            // If all are wild, treat as highest paying symbol (e.g. 5)
            if (effectiveSymbol == 0) effectiveSymbol = 5;
        }
        
        // Check matches
        int matchCount = 1; // First symbol always matches itself (or is wild)
        
        for (int j = 1; j < 5; j++) {
            int r = m_linePatterns[i][j][0];
            int c = m_linePatterns[i][j][1];
            int sym = m_visibleRows.at(r).at(c);
            
            // Match if symbol is same as effective, OR symbol is Wild (0)
            if (sym == effectiveSymbol || sym == 0) {
                matchCount++;
            } else {
                break;
            }
        }
        
        // Calculate winnings if 3 or more matches
        if (matchCount >= 3) {
            int factor = matchCount - 1; // 3 matches -> index 2, 4 -> 3, 5 -> 4
            
            // Emit winning slots
            for (int j = 0; j < matchCount; j++) {
                emit winningSlot(m_linePatterns[i][j][0], m_linePatterns[i][j][1]);
            }
            
            // Calculate win amount
            // Paytable index: symbol (0-9), factor (0-4)
            // Note: factor 2 is for 3 matches, 3 for 4, 4 for 5.
            // Paytable stores values for 1-5 matches at indices 0-4.
            // But populatePayTable logic:
            // list.append(j == 4 ? (j + 1) * 4 : (j + 1) * 2);
            // j goes 0..4.
            // So index 2 is for 3 matches. Correct.
            
            int lineWin = m_payTable.at(effectiveSymbol).at(factor) * effectiveSymbol;
            winnings += lineWin;
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
    checkBonuses(winnings > 0);
    
    // Update sticky wilds if in free spins
    if (m_inFreeSpins) {
        updateStickyWilds();
    } else {
        m_stickyWilds.clear();
    }

    setPlayable(true);
}

void GameEngine::updateStickyWilds()
{
    for(int r = 0; r < 3; r++) {
        for(int c = 0; c < 5; c++) {
            if (m_visibleRows.at(r).at(c) == 0) { // Wild
                bool alreadySticky = false;
                for (const QPoint &p : m_stickyWilds) {
                    if (p.x() == r && p.y() == c) {
                        alreadySticky = true;
                        break;
                    }
                }
                if (!alreadySticky) {
                    m_stickyWilds.append(QPoint(r, c));
                }
            }
        }
    }
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

void GameEngine::checkBonuses(bool wonLastSpin)
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
    
    if(bonusReelsCount >= 3) {
        int spinsAwarded = 0;
        if(bonusReelsCount == 3) spinsAwarded = 5;
        else if(bonusReelsCount == 4) spinsAwarded = 10;
        else if(bonusReelsCount >= 5) spinsAwarded = 15;
        
        qDebug() << QString("BONUS! Awarded %1 free spins").arg(spinsAwarded);
        
        if (!m_inFreeSpins) {
            m_freeSpins = spinsAwarded;
            m_freeSpinsTotal = spinsAwarded;
            m_inFreeSpins = true;
            m_freeSpinsTotalWon = 0;
            
            emit bonusTriggered(spinsAwarded);
            emit freeSpinsChanged(m_freeSpins);
            
            setMessage(QString("BONUS! %1 FREE SPINS!").arg(spinsAwarded));
            
            // Start free spins after a short delay
            QTimer::singleShot(2000, this, SLOT(playFreeSpinRound()));
        } else {
            // Re-trigger free spins
            m_freeSpins += spinsAwarded;
            m_freeSpinsTotal += spinsAwarded;
            
            emit bonusTriggered(spinsAwarded);
            emit freeSpinsChanged(m_freeSpins);
            
            setMessage(QString("BONUS! +%1 FREE SPINS!").arg(spinsAwarded));
            
            // Continue free spins after a delay (longer if won)
            int delay = wonLastSpin ? 3000 : 1500;
            QTimer::singleShot(delay, this, SLOT(playFreeSpinRound()));
        }
    }
    else if(m_inFreeSpins && m_freeSpins > 0) {
        // Continue free spins
        int delay = wonLastSpin ? 3000 : 1500;
        QTimer::singleShot(delay, this, SLOT(playFreeSpinRound()));
    }
    else if(m_inFreeSpins && m_freeSpins == 0) {
        // Free spins complete
        int delay = wonLastSpin ? 3000 : 0;
        
        if (delay > 0) {
             QTimer::singleShot(delay, this, [this](){
                 m_inFreeSpins = false;
                 emit freeSpinsComplete(m_freeSpinsTotalWon);
                 setMessage(QString("Free spins complete! Won %1 total!").arg(m_freeSpinsTotalWon));
             });
        } else {
             m_inFreeSpins = false;
             emit freeSpinsComplete(m_freeSpinsTotalWon);
             setMessage(QString("Free spins complete! Won %1 total!").arg(m_freeSpinsTotalWon));
        }
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

void GameEngine::triggerTestSpins()
{
    qDebug() << "Triggering TEST free spins";
    int spinsAwarded = 5;
    
    m_freeSpins = spinsAwarded;
    m_freeSpinsTotal = spinsAwarded;
    m_inFreeSpins = true;
    m_freeSpinsTotalWon = 0;
    
    emit bonusTriggered(spinsAwarded);
    emit freeSpinsChanged(m_freeSpins);
    
    setMessage(QString("TEST MODE: %1 FREE SPINS!").arg(spinsAwarded));
    
    // Start free spins after a short delay
    QTimer::singleShot(1000, this, SLOT(playFreeSpinRound()));
}
