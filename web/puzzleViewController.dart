part of aufgabe3;

final PuzzleViewController = new _PuzzleViewController( );

class _PuzzleViewController {
    int blockSize = 50;

    Element $puzzle = querySelector( "#puzzle" );
    Situation currentSituation;
    int currentOrientation = 0;
    int lastHeight;
    int lastWidth;
    int lastExitX;
    int lastExitY;
    bool reverse = false;

    List<Element> steine = [];
    List<Element> rands = [];

    void show( Situation situation, [ bool reverse ] ) {
        currentSituation = situation;
        this.reverse = reverse;

        var height = situation.height;
        var width = situation.width;

        $puzzle.style.height = (height * blockSize).toString( ) + "px";
        $puzzle.style.width = (width * blockSize).toString( ) + "px";

        rotate( situation.orientation );

        if ( lastHeight != situation.height || lastWidth != situation.width || lastExitX != situation.exitX || lastExitY != situation.exitY ) {
            removeRands();
            for ( var i = 0; i < height; i++ ) {
                createRandAt( - 1, i );
                createRandAt( width, i );
            }
            for ( var i = - 1; i < width + 1; i++ ) {
                createRandAt( i, - 1 );
                createRandAt( i, height );
            }
            lastHeight = situation.height;
            lastWidth = situation.width;
            lastExitX = situation.exitX;
            lastExitY = situation.exitY;
        }

        for ( Stein stein in situation.steine ) {
            showStein( stein );
        }

        for ( int i = situation.steine.length; i < steine.length; i++ ) {
            steine[ i ].remove();
        }
        steine.length = situation.steine.length;
    }

    void rotate( Orientation orientation ) {
        Orientation oldOrientation = Orientation.values[ (( 360 * 100 + currentOrientation ) % 360 ) ~/ 90 ];

        if ( oldOrientation.index == orientation.index ) {
            return;
        } else if ( ( oldOrientation.index + 1 ) % 4 == orientation.index ) {
            currentOrientation = currentOrientation + 90;
        } else if ( ( oldOrientation.index - 1 + 4 ) % 4 == orientation.index ) {
            currentOrientation = currentOrientation - 90;
        } else if ( ( oldOrientation.index + 2 ) % 4 == orientation.index ) {
            currentOrientation = currentOrientation + 180;
        }

        if ( reverse ) {
            $puzzle.classes.add( "reverse" );
        } else {
            $puzzle.classes.remove( "reverse" );
        }

        $puzzle.style.transform = "rotate(${currentOrientation}deg)";
    }

    void removeRands() {
        for ( var rand in rands ) {
            rand.remove();
        }
        rands.clear();
    }

    void createRandAt( int x, int y ) {
        if ( x == currentSituation.exitX && y == currentSituation.exitY )
            return;
        var rand = new DivElement( );
        rand.classes.add( "rand" );
        rand.style.top = ( y * blockSize ).toString( ) + "px";
        rand.style.left = ( x * blockSize ).toString( ) + "px";
        $puzzle.append( rand );
        rands.add( rand );
    }

    void showStein( Stein stein ) {
        var element;
        if ( stein.id < steine.length ) {
            element = steine[ stein.id ];
        } else {
            steine.length = stein.id + 1;
            steine[ stein.id ] = element = new DivElement( );
            $puzzle.append( element );
        }

        if ( reverse ) {
            element.classes.add( "reverse" );
        } else {
            element.classes.remove( "reverse" );
        }

        element.classes..add( "stein" )..add( "stein${stein.id}");
        element.style.left = ( stein.x * blockSize ).toString( ) + "px";
        element.style.top = ( stein.y * blockSize ).toString( ) + "px";
        element.style.height = ( stein.height * blockSize ).toString( ) + "px";
        element.style.width = ( stein.width * blockSize ).toString( ) + "px";
    }
}