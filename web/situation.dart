part of aufgabe3;

class Situation {
    Situation previous;
    int width;
    int height;
    List<Stein> steine = [];
    Orientation orientation = Orientation.north;
    int exitX;
    int exitY;

    Situation( );

    Situation.from( Situation situation ) {
        previous = situation;
        width = situation.width;
        height = situation.height;
        for ( Stein stein in situation.steine ) {
            steine.add( new Stein.from( stein ) );
        }
        orientation = situation.orientation;
        exitX = situation.exitX;
        exitY = situation.exitY;
    }

    bool applyGravity( ) {
        if ( orientation == Orientation.north )
            return _applyGravityNorth( );
        else if ( orientation == Orientation.south )
            return _applyGravitySouth( );
        else if ( orientation == Orientation.east )
            return _applyGravityEast( );
        else if ( orientation == Orientation.west )
            return _applyGravityWest( );
        throw new StateError( "Ungültige Orientation!" );
    }

    /// Steine fallen nach unten
    bool _applyGravityNorth( ) {
        steine.sort( ( a, b ) => b.y - a.y );
        // Unterster Stein nach oben in die Liste, weil dieser zuerst fällt

        var found = false;

        steinLoop:
        for ( Stein stein in steine ) {
            // Durch alle Steine iterieren
            for ( int y = stein.y2 + 1; y < height; y++ ) {
                // Einen Block unter dem aktuellen Stein anfangen und bis zum unteren Ende des ganzen Feldes gehen
                for ( int x = stein.x; x <= stein.x2; x++ ) {
                    // Von der X-Position am linken Ende des Steins bis zur X-Position des rechten Endes
                    if ( ! isFeldFrei( x, y ) ) // Prüfen ob das Feld frei ist
                        continue steinLoop;
                }
                stein.y2 =
                        y; // Wenn das der Fall ist, Stein auf diese Position nach unten verschieben
            }
            if ( exitY - 1 == stein.y2 && exitX == stein.x &&
                    exitX == stein.x2 ) {
                stein.y = exitY;
                print( "Lösung gefunden North" );
                found = true;
            }
        }
        return found;
    }

    /// Steine fallen nach oben
    bool _applyGravitySouth( ) {
        steine.sort( ( a, b ) => a.y - b
                .y ); // Oberster Stein nach oben in die Liste, weil dieser zuerst fällt

        var found = false;

        steinLoop:
        for ( Stein stein in steine ) {
            // Durch alle Steine iterieren
            for ( int y = stein.y - 1; y >= 0; y-- ) {
                // Einen Block über dem aktuellen Stein anfangen und bis zum oberen Ende des ganzen Feldes gehen
                for ( int x = stein.x; x <= stein.x2; x++ ) {
                    // Von der X-Position am linken Ende des Steins bis zur X-Position des rechten Endes
                    if ( ! isFeldFrei( x, y ) ) // Prüfen ob das Feld frei ist
                        continue steinLoop;
                }
                stein.y =
                        y; // Wenn das der Fall ist, Stein auf diese Position nach unten verschieben
            }
            if ( exitY + 1 == stein.y && exitX == stein.x &&
                    exitX == stein.x2 ) {
                stein.y2 = exitY;
                print( "Lösung gefunden South" );
                found = true;
            }
        }
        return found;
    }

    /// Steine fallen nach links
    bool _applyGravityEast( ) {
        steine.sort( ( a, b ) => a.x - b
                .x ); // Der Stein, der am weitesten links ist, nach oben in die Liste, weil dieser zuerst fällt

        var found = false;

        steinLoop:
        for ( Stein stein in steine ) {
            // Durch alle Steine iterieren
            for ( int x = stein.x - 1; x >= 0; x-- ) {
                // Einen Block links neben dem aktuellen Stein anfangen und bis zum linken Ende des ganzen Feldes gehen
                for ( int y = stein.y; y <= stein.y2; y++ ) {
                    // Von der Y-Position am oberen Ende des Steins bis zur Y-Position des unteren Endes
                    if ( ! isFeldFrei( x, y ) ) // Prüfen ob das Feld frei ist
                        continue steinLoop;
                }
                stein.x = x; // Wenn das der Fall ist, Stein auf diese Position nach links verschieben
            }
            if ( exitX + 1 == stein.x && exitY == stein.y &&
                    exitY == stein.y2 ) {
                stein.x2 = exitX;
                print( "Lösung gefunden East" );
                found = true;
            }
        }
        return found;
    }

    /// Steine fallen nach rechts
    bool _applyGravityWest( ) {
        steine.sort( ( a, b ) => b.x - a
                .x ); // Der Stein, der am weitesten rechts ist, nach oben in die Liste, weil dieser zuerst fällt

        var found = false;

        steinLoop:
        for ( Stein stein in steine ) {
            // Durch alle Steine iterieren
            for ( int x = stein.x2 + 1; x < width; x++ ) {
                // Einen Block rechts neben dem aktuellen Stein anfangen und bis zum rechten Ende des ganzen Feldes gehen
                for ( int y = stein.y; y <= stein.y2; y++ ) {
                    // Von der Y-Position am oberen Ende des Steins bis zur Y-Position des unteren Endes
                    if ( ! isFeldFrei( x, y ) ) // Prüfen ob das Feld frei ist
                        continue steinLoop;
                }
                stein.x2 =
                        x; // Wenn das der Fall ist, Stein auf diese Position nach links verschieben
            }
            if ( exitX - 1 == stein.x2 && exitY == stein.y &&
                    exitY == stein.y2 ) {
                stein.x = exitX;
                print( "Lösung gefunden West" );
                found = true;
            }
        }
        return found;
    }

    bool isFeldFrei( int x, int y ) {
        for ( Stein stein in steine ) {
            if ( stein.x <= x && stein.x2 >= x && stein.y <= y &&
                    stein.y2 >= y ) {
                return false;
            }
        }
        return true;
    }

    SituationHash hash( ) {
        int hash1 = 0;
        steine.sort( ( a, b ) => b.id - a.id );
        for ( var i = 0; i < 4 && i < steine.length; i++ ) {
            hash1 = hash1 << 8 | (steine[i].x << 4 | steine[i].y);
        }

        int hash2 = 0;
        for ( var i = 4; i < 8 && i < steine.length; i++ ) {
            hash2 = hash2 << 8 | (steine[i].x << 4 | steine[i].y);
        }

        int hash3 = 0;
        for ( var i = 8; i < 12 && i < steine.length; i++ ) {
            hash3 = hash3 << 8 | (steine[i].x << 4 | steine[i].y);
        }

        return new SituationHash( hash1, hash2, hash3 );
    }

    String toString( ) {
        List<List<String>> twoDArr = [];
        for ( int y = 0; y < height; y++ ) {
            twoDArr.add( [] );
            for ( int x = 0; x < width; x++ ) {
                twoDArr[y].add( " " );
            }
        }

        for ( int i = 0; i < steine.length; i++ ) {
            for ( int x = steine[i].x; x <= steine[i].x2; x++ ) {
                for ( int y = steine[i].y; y <= steine[i].y2; y++ ) {
                    if ( y < 0 || y >= twoDArr.length )
                        continue;
                    if ( x < 0 || x >= twoDArr[y].length )
                        continue;
                    twoDArr[y][x] = steine[i].id.toString( );
                }
            }
        }

        String string = "┌";
        for ( int i = 0; i < width; i++ ) {
            if ( exitY == - 1 && exitX == i ) {
                string += " ";
            } else {
                string += "─";
            }
        }
        string += "┐\n";

        for ( int y = 0; y < height; y++ ) {
            if ( exitY == y && exitX == - 1 ) {
                string += " ";
            } else {
                string += "│";
            }
            for ( int x = 0; x < width; x++ ) {
                string += twoDArr[y][x];
            }
            if ( exitY == y && exitX == width ) {
                string += " \n";
            } else {
                string += "│\n";
            }
        }
        string += "└";
        for ( int i = 0; i < width; i++ ) {
            if ( exitY == height && exitX == i ) {
                string += " ";
            } else {
                string += "─";
            }
        }
        string += "┘\n";

        return string;
    }
}

enum Orientation {
    north,
    west,
    south,
    east
}

class SituationHash {
    int hash1;
    int hash2;
    int hash3;

    SituationHash( this.hash1, this.hash2, this.hash3 );

    @override
    int get hashCode {
        return hash1 + hash2 + hash3;
    }

    @override
    bool operator ==( other ) {
        return hash1 == other.hash1 && hash2 == other.hash2 && hash3 == other.hash3;
    }


}